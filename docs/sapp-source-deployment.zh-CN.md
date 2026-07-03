# SAPP 源部署指南

包编写教程见 `docs/spk-sapp-developer-guide.zh-CN.md` 和 `docs/sapp-package-authoring.zh-CN.md`。

## 快速启动

Linux:

```sh
cd sappserver
chmod +x *.sh
./sapp-onekey.sh --bind 0.0.0.0 --port 8080
```

Windows:

```powershell
cd H:\SkyOS\sappserver
.\manage-sapp-source.ps1 -BindAddress 0.0.0.0 -Port 8080
```

访问：

```text
http://127.0.0.1:8080/       公开包列表
http://127.0.0.1:8080/admin  管理后台
```

SkyOS 源配置：

```text
deb http://skyapps.skyu.cc.cd skyos main
```

本地调试可以用 `http://<server-ip>:8080`；公网默认域名保持 `http://skyapps.skyu.cc.cd`，由反向代理把 80 端口转发到本服务的 8080 端口。

## 仓库生成和校验

```sh
cd sappserver
python spk.py index --repo repo
python spk.py validate --repo repo
```

脚本等价入口：

```sh
./create-sapp-source.sh
./create-sapp-source.sh --keep-pool
./create-sapp-source.sh --validate-only
```

Windows:

```powershell
.\create-sapp-source.ps1
.\create-sapp-source.ps1 -KeepPool
.\create-sapp-source.ps1 -ValidateOnly
```

## 单端口路由

- `/`：公开包列表。
- `/admin`：中文管理后台。
- `/api/packages`：JSON 包列表。
- `/dists/skyos/main/binary-i386/Packages`：索引文件。
- `/pool/main/*.spk`：二进制包下载。

## 仓库结构

```text
repo/
  dists/
    skyos/
      Release
      main/
        binary-i386/
          Packages
  pool/
    main/
      base-tools_1.0.3.0.GSOSYGP_skyos-i386.spk
```

## 发布流程

1. 用 `spk.py pack` 或 `/admin` 生成二进制 `.spk`。
2. 放入 `repo/pool/main`。
3. 运行 `python spk.py index --repo repo --no-samples`。
4. 运行 `python spk.py validate --repo repo`。
5. 启动 `sapp_manage_server.py` 或把 `repo` 目录部署到 Web 服务。
6. 在 SkyOS 中使用 `sapp update` 和 `sapp install <包名>`。
