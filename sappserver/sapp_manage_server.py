#!/usr/bin/env python3
import argparse
import hashlib
import hmac
import html
import http.server
import json
import os
import re
import secrets
import sys
import tempfile
import time
import urllib.parse
from pathlib import Path

import spk

SKYOS_VERSION = spk.SKYOS_VERSION
SKYOS_INTERNAL_VERSION = spk.SKYOS_INTERNAL_VERSION
SKYOS_SYSTEM_ID = spk.SKYOS_SYSTEM_ID


def parse_index(index_file):
    if not index_file.exists():
        return []
    content = index_file.read_text(encoding="ascii", errors="strict")
    packages = []
    for entry in re.split(r"(?:\r?\n){2,}", content):
        if not entry.strip():
            continue
        fields = {}
        for line in entry.splitlines():
            match = re.match(r"^([^:]+):\s*(.*)$", line)
            if match:
                fields[match.group(1)] = match.group(2)
        if fields.get("Package"):
            packages.append(fields)
    return packages


def read_urlencoded(body):
    text = body.decode("utf-8", errors="replace")
    return {k: v[0] if v else "" for k, v in urllib.parse.parse_qs(text, keep_blank_values=True).items()}


def parse_multipart(body, content_type):
    match = re.search(r"boundary=(?:\"([^\"]+)\"|([^;]+))", content_type or "")
    if not match:
        raise ValueError("missing multipart boundary")
    boundary = ("--" + (match.group(1) or match.group(2))).encode("utf-8")
    fields = {}
    files = {}
    for raw in body.split(boundary):
        raw = raw.strip()
        if not raw or raw == b"--":
            continue
        if raw.endswith(b"--"):
            raw = raw[:-2].rstrip()
        header_blob, sep, payload = raw.partition(b"\r\n\r\n")
        if not sep:
            continue
        headers = header_blob.decode("utf-8", errors="replace").split("\r\n")
        disposition = ""
        for header in headers:
            if header.lower().startswith("content-disposition:"):
                disposition = header.split(":", 1)[1].strip()
        name_match = re.search(r'name="([^"]+)"', disposition)
        if not name_match:
            continue
        name = name_match.group(1)
        filename_match = re.search(r'filename="([^"]*)"', disposition)
        if filename_match:
            filename = os.path.basename(filename_match.group(1))
            files[name] = (filename, payload.rstrip(b"\r\n"))
        else:
            fields[name] = payload.rstrip(b"\r\n").decode("utf-8", errors="replace")
    return fields, files


def cookie_value(cookie_header, name):
    for part in (cookie_header or "").split(";"):
        key, _, value = part.strip().partition("=")
        if key == name:
            return value
    return ""


class SappServer(http.server.ThreadingHTTPServer):
    daemon_threads = True

    def load_stats(self):
        if not self.stats_file.exists():
            return {"downloads": {}}
        try:
            data = json.loads(self.stats_file.read_text(encoding="utf-8"))
            if not isinstance(data.get("downloads"), dict):
                data["downloads"] = {}
            return data
        except Exception:
            return {"downloads": {}}

    def save_stats(self, stats):
        self.stats_file.parent.mkdir(parents=True, exist_ok=True)
        tmp = self.stats_file.with_suffix(".tmp")
        tmp.write_text(json.dumps(stats, ensure_ascii=False, indent=2), encoding="utf-8")
        tmp.replace(self.stats_file)

    def record_download(self, filename, size, client):
        stats = self.load_stats()
        downloads = stats.setdefault("downloads", {})
        item = downloads.setdefault(filename, {"count": 0, "bytes": 0, "last_at": "", "last_client": ""})
        item["count"] = int(item.get("count", 0)) + 1
        item["bytes"] = int(item.get("bytes", 0)) + int(size)
        item["last_at"] = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime())
        item["last_client"] = client
        self.save_stats(stats)


class SappHandler(http.server.BaseHTTPRequestHandler):
    server_version = "SkyOS-SappServer/1.2"

    @property
    def repo(self):
        return self.server.repo

    @property
    def pool(self):
        return self.server.pool

    @property
    def index_file(self):
        return self.server.index_file

    def log_message(self, fmt, *args):
        sys.stderr.write("[%s] %s\n" % (self.log_date_time_string(), fmt % args))

    def is_authenticated(self):
        token = cookie_value(self.headers.get("Cookie"), "sapp_session")
        return bool(token and token in self.server.sessions)

    def require_admin(self):
        if self.is_authenticated():
            return True
        self.redirect("/admin/login")
        return False

    def do_GET(self):
        parsed = urllib.parse.urlparse(self.path)
        if parsed.path == "/":
            self.render_public()
        elif parsed.path == "/admin/login":
            self.render_login()
        elif parsed.path == "/admin/logout":
            self.logout()
        elif parsed.path == "/admin":
            if self.require_admin():
                self.render_admin()
        elif parsed.path == "/api/packages":
            self.send_json(parse_index(self.index_file))
        elif parsed.path == "/api/stats":
            if self.require_admin():
                self.send_json(self.server.load_stats())
        elif parsed.path.startswith("/dists/") or parsed.path.startswith("/pool/"):
            self.serve_repo_file(parsed.path)
        else:
            self.send_error(404)

    def do_POST(self):
        length = int(self.headers.get("Content-Length", "0"))
        body = self.rfile.read(length)
        content_type = self.headers.get("Content-Type", "")
        try:
            if self.path == "/admin/login":
                self.login(read_urlencoded(body))
                return
            if not self.require_admin():
                return
            if self.path == "/admin/create":
                self.create_package(read_urlencoded(body))
                self.render_admin("包已保存，并已重建 Packages 索引。")
            elif self.path == "/admin/upload":
                _fields, files = parse_multipart(body, content_type)
                self.upload_package(files)
                self.render_admin("二进制 SPK 已上传，并已重建 Packages 索引。")
            elif self.path == "/admin/delete":
                self.delete_package(read_urlencoded(body))
                self.render_admin("包已删除，并已重建 Packages 索引。")
            elif self.path == "/admin/reindex":
                self.rebuild_index()
                self.render_admin("Packages 索引已重建。")
            else:
                self.send_error(404)
        except Exception as exc:
            self.render_admin(f"错误：{exc}", status=500)

    def login(self, form):
        user_ok = hmac.compare_digest(form.get("username", ""), self.server.admin_user)
        pass_ok = hmac.compare_digest(form.get("password", ""), self.server.admin_password)
        if not (user_ok and pass_ok):
            self.render_login("用户名或密码错误。", status=401)
            return
        token = secrets.token_urlsafe(32)
        self.server.sessions[token] = {"user": self.server.admin_user, "created": time.time()}
        self.send_response(303)
        self.send_header("Location", "/admin")
        self.send_header("Set-Cookie", f"sapp_session={token}; Path=/; HttpOnly; SameSite=Lax")
        self.end_headers()

    def logout(self):
        token = cookie_value(self.headers.get("Cookie"), "sapp_session")
        if token:
            self.server.sessions.pop(token, None)
        self.send_response(303)
        self.send_header("Location", "/admin/login")
        self.send_header("Set-Cookie", "sapp_session=; Path=/; Max-Age=0; HttpOnly; SameSite=Lax")
        self.end_headers()

    def rebuild_index(self):
        spk.build_index(self.repo, no_samples=True)

    def create_package(self, form):
        name = form.get("name", "").strip()
        version = form.get("version", "").strip() or SKYOS_VERSION
        internal = form.get("internalVersion", "").strip() or SKYOS_INTERNAL_VERSION
        system = form.get("system", "").strip() or SKYOS_SYSTEM_ID
        compatible = form.get("compatibleInternalVersion", "").strip() or SKYOS_INTERNAL_VERSION
        depends = form.get("depends", "").strip()
        description = form.get("description", "").strip()
        payload = form.get("payload", "").replace("\r\n", "\n").strip()

        self.pool.mkdir(parents=True, exist_ok=True)
        output = self.pool / spk.package_filename(name, version)
        with tempfile.TemporaryDirectory() as temp:
            source = None
            if payload:
                source = Path(temp) / "payload"
                source.mkdir()
                (source / "README.txt").write_text(payload + "\n", encoding="utf-8")
            spk.build_package(
                output=output,
                name=name,
                version=version,
                internal_version=internal,
                system=system,
                compatible_internal_version=compatible,
                depends=depends,
                description=description,
                source=source,
            )
        self.rebuild_index()

    def upload_package(self, files):
        upload = files.get("package")
        if not upload:
            raise ValueError("请选择一个 .spk 文件上传")
        original_name, data = upload
        if not data:
            raise ValueError("上传文件为空")
        with tempfile.NamedTemporaryFile(delete=False) as temp:
            temp.write(data)
            temp_path = Path(temp.name)
        try:
            meta = spk.read_metadata(temp_path)
            name = meta.get("Package")
            version = meta.get("Version")
            if not name or not version:
                match = re.fullmatch(r"([A-Za-z0-9][A-Za-z0-9+.-]*)_([A-Za-z0-9][A-Za-z0-9+.:~-]*)_skyos-i386\.spk", original_name)
                if not match:
                    raise ValueError("SPK 缺少 Package/Version 元数据，且文件名不符合规则")
                name, version = match.groups()
            self.pool.mkdir(parents=True, exist_ok=True)
            target = self.pool / spk.package_filename(name, version)
            target.write_bytes(data)
        finally:
            temp_path.unlink(missing_ok=True)
        self.rebuild_index()

    def delete_package(self, form):
        filename = form.get("file", "").strip()
        if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9+.-]*_[A-Za-z0-9][A-Za-z0-9+.:~-]*_skyos-i386\.spk", filename):
            raise ValueError("包文件名不正确")
        path = self.pool / filename
        if path.exists():
            path.unlink()
        self.rebuild_index()

    def serve_repo_file(self, request_path):
        parts = [p for p in request_path.lstrip("/").split("/") if p]
        if ".." in parts:
            self.send_error(400)
            return
        file_path = self.repo.joinpath(*parts)
        if not file_path.is_file():
            self.send_error(404)
            return
        data = file_path.read_bytes()
        if file_path.suffix == ".spk" and request_path.startswith("/pool/"):
            self.server.record_download(request_path.lstrip("/"), len(data), self.client_address[0])
        content_type = "application/octet-stream" if file_path.suffix == ".spk" else "text/plain; charset=us-ascii"
        self.send_response(200)
        self.send_header("Content-Type", content_type)
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def send_json(self, value):
        data = json.dumps(value, ensure_ascii=False, indent=2).encode("utf-8")
        self.send_response(200)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)

    def redirect(self, location):
        self.send_response(303)
        self.send_header("Location", location)
        self.end_headers()

    def repo_base_url(self):
        host = self.headers.get("Host") or f"{self.server.bind_address}:{self.server.server_port}"
        return f"http://{host}"

    def render_public(self):
        packages = parse_index(self.index_file)
        rows = []
        for pkg in packages:
            filename = pkg.get("Filename", "")
            rows.append(
                "<tr>"
                f"<td>{html.escape(pkg.get('Package', ''))}</td>"
                f"<td>{html.escape(pkg.get('Version', ''))}</td>"
                f"<td>{html.escape(pkg.get('InternalVersion', ''))}</td>"
                f"<td>{html.escape(pkg.get('Depends', ''))}</td>"
                f"<td>{html.escape(pkg.get('Description', ''))}</td>"
                f"<td><a href='/{html.escape(filename)}'>下载</a></td>"
                "</tr>"
            )
        body = f"""
<section class="toolbar">
  <div>
    <h1>SkyOS SAPP 软件源</h1>
    <p>当前公开仓库：<code>deb {html.escape(self.repo_base_url())} skyos main</code></p>
  </div>
  <a class="button" href="/admin">进入后台</a>
</section>
<section>
  <table>
    <thead><tr><th>包名</th><th>版本名</th><th>内部版本</th><th>前置包</th><th>说明</th><th>文件</th></tr></thead>
    <tbody>{''.join(rows) or '<tr><td colspan="6">暂无包。</td></tr>'}</tbody>
  </table>
</section>
"""
        self.render_layout("SkyOS SAPP 软件源", body)

    def render_login(self, message="", status=200):
        msg = f"<p class='message error'>{html.escape(message)}</p>" if message else ""
        body = f"""
<section class="login">
  <h1>SAPP 后台登录</h1>
  {msg}
  <form method="post" action="/admin/login">
    <label>用户名<input name="username" autocomplete="username" required autofocus></label>
    <label>密码<input name="password" type="password" autocomplete="current-password" required></label>
    <button>登录</button>
  </form>
</section>
"""
        self.render_layout("SAPP 后台登录", body, status=status)

    def render_admin(self, message="", status=200):
        packages = parse_index(self.index_file)
        stats = self.server.load_stats().get("downloads", {})
        rows = []
        total_downloads = 0
        total_bytes = 0
        for pkg in packages:
            filename = os.path.basename(pkg.get("Filename", ""))
            stat_key = pkg.get("Filename", f"pool/main/{filename}")
            stat = stats.get(stat_key, {})
            count = int(stat.get("count", 0))
            bytes_sent = int(stat.get("bytes", 0))
            total_downloads += count
            total_bytes += bytes_sent
            rows.append(
                "<tr>"
                f"<td>{html.escape(pkg.get('Package', ''))}</td>"
                f"<td>{html.escape(pkg.get('Version', ''))}</td>"
                f"<td>{html.escape(pkg.get('InternalVersion', ''))}</td>"
                f"<td>{html.escape(pkg.get('Depends', ''))}</td>"
                f"<td>{html.escape(pkg.get('Size', ''))}</td>"
                f"<td>{count}</td>"
                f"<td>{bytes_sent}</td>"
                f"<td>{html.escape(stat.get('last_at', ''))}</td>"
                "<td>"
                f"<a href='/pool/main/{html.escape(filename)}'>下载</a>"
                "<form method='post' action='/admin/delete' class='inline'>"
                f"<input type='hidden' name='file' value='{html.escape(filename)}'>"
                "<button class='danger'>删除</button>"
                "</form>"
                "</td>"
                "</tr>"
            )
        msg = f"<p class='message'>{html.escape(message)}</p>" if message else ""
        body = f"""
<section class="toolbar">
  <div>
    <h1>SAPP 管理后台</h1>
    <p>已登录：<code>{html.escape(self.server.admin_user)}</code>，公开列表在 <code>/</code>，后台在 <code>/admin</code>。</p>
  </div>
  <div class="actions"><a class="button secondary" href="/">公开列表</a><a class="button secondary" href="/admin/logout">退出登录</a></div>
</section>
{msg}
<section class="metrics">
  <div><strong>{len(packages)}</strong><span>包数量</span></div>
  <div><strong>{total_downloads}</strong><span>SPK 下载次数</span></div>
  <div><strong>{total_bytes}</strong><span>累计下载字节</span></div>
</section>
<section>
  <h2>新建二进制 SPK</h2>
  <form method="post" action="/admin/create">
    <div class="grid three">
      <label>包名<input name="name" required placeholder="hello"></label>
      <label>版本名<input name="version" required value="{SKYOS_VERSION}"></label>
      <label>兼容系统号<input name="system" value="{SKYOS_SYSTEM_ID}"></label>
    </div>
    <div class="grid three">
      <label>内部版本<input name="internalVersion" required value="{SKYOS_INTERNAL_VERSION}"></label>
      <label>兼容内部版本<input name="compatibleInternalVersion" required value="{SKYOS_INTERNAL_VERSION}"></label>
      <label>前置包<input name="depends" placeholder="base-tools (>= 10015)"></label>
    </div>
    <label>说明<textarea name="description" rows="2" placeholder="这个包的用途"></textarea></label>
    <label>包内 README 内容，可留空<textarea name="payload" rows="4"></textarea></label>
    <button>保存包并重建索引</button>
  </form>
</section>
<section>
  <h2>上传二进制 SPK</h2>
  <form method="post" action="/admin/upload" enctype="multipart/form-data" class="upload">
    <input type="file" name="package" accept=".spk" required>
    <button>上传并重建索引</button>
  </form>
</section>
<section>
  <div class="toolbar compact">
    <h2>包与下载监控</h2>
    <form method="post" action="/admin/reindex"><button class="secondary">重建索引</button></form>
  </div>
  <table>
    <thead><tr><th>包名</th><th>版本名</th><th>内部版本</th><th>前置包</th><th>大小</th><th>下载次数</th><th>累计字节</th><th>最近下载</th><th>操作</th></tr></thead>
    <tbody>{''.join(rows) or '<tr><td colspan="9">暂无包。</td></tr>'}</tbody>
  </table>
</section>
"""
        self.render_layout("SAPP 管理后台", body, status=status)

    def render_layout(self, title, body, status=200):
        page = f"""<!doctype html>
<html lang="zh-CN">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>{html.escape(title)}</title>
<style>
:root{{color-scheme:light;--bg:#f5f7fb;--panel:#fff;--line:#d8dee8;--text:#1f2937;--muted:#5b6472;--blue:#1f6feb;--red:#b42318}}
body{{margin:0;background:var(--bg);color:var(--text);font-family:Arial,"Microsoft YaHei",sans-serif;font-size:14px;line-height:1.5}}
main{{max-width:1180px;margin:0 auto;padding:24px}}
section{{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:16px;margin-bottom:16px}}
h1{{font-size:24px;margin:0 0 4px}} h2{{font-size:18px;margin:0 0 12px}} p{{margin:0;color:var(--muted)}}
.toolbar{{display:flex;align-items:center;justify-content:space-between;gap:16px}} .toolbar.compact{{padding:0;border:0;margin:0 0 12px;background:transparent}}
.actions{{display:flex;gap:8px;flex-wrap:wrap}} .grid{{display:grid;gap:12px;margin-bottom:12px}} .grid.three{{grid-template-columns:repeat(3,minmax(0,1fr))}}
.login{{max-width:380px;margin:8vh auto}} .login form{{display:grid;gap:12px}}
.metrics{{display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:12px;background:transparent;border:0;padding:0}}
.metrics div{{background:var(--panel);border:1px solid var(--line);border-radius:8px;padding:14px}} .metrics strong{{display:block;font-size:24px}} .metrics span{{color:var(--muted)}}
label{{display:block;color:var(--muted);font-size:13px}} input,textarea{{width:100%;box-sizing:border-box;margin-top:4px;padding:8px;border:1px solid #c7d0da;border-radius:6px;font:inherit;color:var(--text);background:#fff}}
button,.button{{display:inline-block;padding:8px 12px;border:1px solid var(--blue);background:var(--blue);color:#fff;border-radius:6px;text-decoration:none;cursor:pointer;font:inherit}}
button.secondary,.button.secondary{{background:#fff;color:var(--blue)}} button.danger{{border-color:var(--red);background:var(--red);margin-left:8px}}
table{{width:100%;border-collapse:collapse;background:#fff}} th,td{{padding:9px 8px;border-bottom:1px solid #e5e7eb;text-align:left;vertical-align:top}} th{{font-size:12px;color:var(--muted);font-weight:600}}
code{{background:#eef2f7;padding:2px 5px;border-radius:4px}} .message{{background:#e8f5e9;border:1px solid #b7dfb9;color:#1b5e20;padding:10px;border-radius:6px;margin-bottom:16px}} .message.error{{background:#ffebe9;border-color:#ffb3ad;color:#842029}}
.inline{{display:inline}} .upload{{display:flex;gap:12px;align-items:center}} .upload input{{margin:0;max-width:520px}}
@media (max-width:760px){{main{{padding:12px}}.toolbar,.upload{{align-items:flex-start;flex-direction:column}}.grid.three,.metrics{{grid-template-columns:1fr}}table{{display:block;overflow-x:auto;white-space:nowrap}}}}
</style>
</head>
<body><main>{body}</main></body>
</html>"""
        data = page.encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Content-Length", str(len(data)))
        self.end_headers()
        self.wfile.write(data)


def main():
    root = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser(description="SkyOS SAPP single-port repository and admin server")
    parser.add_argument("--repo", default=str(root / "repo"))
    parser.add_argument("--bind", default="127.0.0.1")
    parser.add_argument("--port", type=int, default=8080)
    parser.add_argument("--admin-user", default=os.environ.get("SAPP_ADMIN_USER", "admin"))
    parser.add_argument("--admin-password", default=os.environ.get("SAPP_ADMIN_PASSWORD", "skyos"))
    args = parser.parse_args()

    repo = Path(args.repo).resolve()
    pool = repo / "pool/main"
    index_file = repo / "dists/skyos/main/binary-i386/Packages"
    stats_file = repo / ".sapp" / "download-stats.json"
    pool.mkdir(parents=True, exist_ok=True)
    index_file.parent.mkdir(parents=True, exist_ok=True)
    if not index_file.exists():
        spk.build_index(repo)

    server = SappServer((args.bind, args.port), SappHandler)
    server.repo = repo
    server.pool = pool
    server.index_file = index_file
    server.stats_file = stats_file
    server.bind_address = args.bind
    server.admin_user = args.admin_user
    server.admin_password = args.admin_password
    server.sessions = {}
    print("SAPP 单端口服务器已启动：")
    print(f"  公开列表: http://{args.bind}:{args.port}/")
    print(f"  管理后台: http://{args.bind}:{args.port}/admin")
    print(f"  登录账号: {args.admin_user}")
    print(f"  仓库目录: {repo}")
    print("按 Ctrl+C 停止。")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print()
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
