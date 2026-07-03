#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
import re
import shutil
import struct
import subprocess
import tarfile
import tempfile
from pathlib import Path

MAGIC = b"SPK1"
SXR_MAGIC = b"SXR1"
SKYOS_VERSION = "1.0.1.0.SKYCNQU"
SKYOS_INTERNAL_VERSION = "10002"
SKYOS_SYSTEM_ID = "skyos-10002"


def _check_name(value, label):
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9+.-]*", value):
        raise ValueError(f"invalid {label}: {value}")


def _check_version(value, label):
    if not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9+.:~-]*", value):
        raise ValueError(f"invalid {label}: {value}")


def _check_numeric(value, label):
    if not re.fullmatch(r"[0-9]+", str(value)):
        raise ValueError(f"{label} must be numeric internal version")


def validate_depends(depends):
    for value in re.findall(r"\((?:>=|<=|>|<|=)\s*([^)]+)\)", depends or ""):
        _check_numeric(value.strip(), "dependency version")


def validate_sxr_depends(depends):
    if not depends:
        return
    for item in depends.split(","):
        name = item.strip().split(" ", 1)[0]
        if name:
            _check_name(name, "SXR dependency")
    validate_depends(depends)


def _split_csv(value):
    if not value:
        return []
    if isinstance(value, (list, tuple)):
        return [str(v).strip() for v in value if str(v).strip()]
    return [v.strip() for v in str(value).split(",") if v.strip()]


def _meta_string(meta, key):
    value = meta.get(key)
    if isinstance(value, list):
        return ", ".join(str(v) for v in value)
    if isinstance(value, dict):
        return json.dumps(value, ensure_ascii=False, sort_keys=True)
    if value is True:
        return "yes"
    if value is False:
        return "no"
    return value or ""


def package_filename(name, version):
    return f"{name}_{version}_skyos-i386.spk"


def sxr_filename(name, version):
    return f"{name}_{version}_skyos-i386.sxr"


def read_metadata(path):
    data = Path(path).read_bytes()
    magic = MAGIC if data.startswith(MAGIC) else SXR_MAGIC if data.startswith(SXR_MAGIC) else None
    if magic:
        if len(data) < 8:
            raise ValueError("truncated package header")
        header_len = struct.unpack("<I", data[4:8])[0]
        header_start = 8
        header_end = header_start + header_len
        if header_end > len(data):
            raise ValueError("invalid package header length")
        meta = json.loads(data[header_start:header_end].decode("utf-8"))
        meta["_format"] = "sxr-binary-v1" if magic == SXR_MAGIC else meta.get("Format", "spk-binary-v2")
        return meta

    fields = {}
    text = data.decode("utf-8", errors="ignore")
    for line in text.splitlines():
        match = re.match(r"^([^:]+):\s*(.*)$", line)
        if match:
            fields[match.group(1)] = match.group(2)
    fields["_format"] = "legacy-text"
    return fields


def _add_tree_to_tar(tar, source, root):
    source = Path(source)
    for item in sorted(source.rglob("*")):
        if item.is_file():
            arcname = Path(root) / item.relative_to(source)
            tar.add(item, arcname=str(arcname).replace("\\", "/"))


def _compile_python_tree(source, build_dir):
    source = Path(source)
    build_dir = Path(build_dir)
    py_root = build_dir / "python-src"
    pyc_root = build_dir / "python-bytecode"
    shutil.copytree(source, py_root, dirs_exist_ok=True)
    for py_file in py_root.rglob("*.py"):
        rel = py_file.relative_to(py_root)
        out = pyc_root / rel.with_suffix(".pyc")
        out.parent.mkdir(parents=True, exist_ok=True)
        import py_compile
        py_compile.compile(str(py_file), cfile=str(out), doraise=True)
    return py_root, pyc_root


def _find_tool(candidates):
    for name in candidates:
        found = shutil.which(name)
        if found:
            return found
    for name in candidates:
        for root in (Path("H:/msys64/usr/bin"), Path("H:/msys64/mingw32/bin"), Path("C:/msys64/usr/bin")):
            path = root / name
            if path.exists():
                return str(path)
    return None


def _compile_c_sources(sources, build_dir):
    cc = os.environ.get("CC") or _find_tool(["i686-elf-gcc", "gcc", "clang", "gcc.exe", "clang.exe"])
    if not cc:
        raise ValueError("C compiler not found; install gcc/clang or set CC")
    out_dir = Path(build_dir) / "native-objects"
    out_dir.mkdir(parents=True, exist_ok=True)
    for src in sources:
        src = Path(src)
        if not src.exists():
            raise FileNotFoundError(src)
        out = out_dir / (src.stem + ".o")
        cmd = [cc, "-m32", "-ffreestanding", "-fno-pic", "-nostdlib", "-c", str(src), "-o", str(out)]
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if proc.returncode != 0:
            raise ValueError(f"C compile failed for {src}:\n{proc.stderr.strip()}")
    return out_dir


def _compile_nasm_sources(sources, build_dir):
    nasm = os.environ.get("NASM") or _find_tool(["nasm", "nasm.exe"])
    if not nasm:
        raise ValueError("NASM not found; install nasm or set NASM")
    out_dir = Path(build_dir) / "native-objects"
    out_dir.mkdir(parents=True, exist_ok=True)
    for src in sources:
        src = Path(src)
        if not src.exists():
            raise FileNotFoundError(src)
        out = out_dir / (src.stem + ".o")
        cmd = [nasm, "-f", "elf32", str(src), "-o", str(out)]
        proc = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        if proc.returncode != 0:
            raise ValueError(f"NASM compile failed for {src}:\n{proc.stderr.strip()}")
    return out_dir


def _add_json_to_tar(tar, data, arcname, temp_root):
    path = Path(temp_root) / arcname.replace("/", "_")
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2, sort_keys=True) + "\n", encoding="utf-8")
    tar.add(path, arcname=arcname)


def build_package(output, name, version=SKYOS_VERSION, internal_version=SKYOS_INTERNAL_VERSION,
                  system=SKYOS_SYSTEM_ID, compatible_internal_version=SKYOS_INTERNAL_VERSION,
                  depends="", description="", source=None, python_source=None, c_source=None,
                  nasm_source=None, entry_point="", commands=None, runtime="", package_type="app",
                  sxr_depends="", gui=False, installer=False, icon=None, allow_read=None,
                  allow_write=None):
    _check_name(name, "package name")
    _check_version(version, "version")
    _check_numeric(internal_version, "InternalVersion")
    _check_numeric(compatible_internal_version, "CompatibleInternalVersion")
    validate_depends(depends)
    validate_sxr_depends(sxr_depends)
    if not re.fullmatch(r"[A-Za-z0-9_.+-]+", system):
        raise ValueError("invalid system id")
    c_source = c_source or []
    nasm_source = nasm_source or []
    commands = _split_csv(commands)
    allow_read = _split_csv(allow_read)
    allow_write = _split_csv(allow_write)
    if not runtime:
        if c_source or nasm_source:
            runtime = "native-i386"
        elif python_source:
            runtime = "python-bytecode"
        else:
            runtime = "soj"
    if installer:
        package_type = "installer"
        gui = True
    if gui and package_type == "app":
        package_type = "gui-app"
    if entry_point and not commands:
        commands = [name]

    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    meta = {
        "Package": name,
        "Version": version,
        "InternalVersion": str(internal_version),
        "Architecture": "i386",
        "System": system,
        "CompatibleInternalVersion": str(compatible_internal_version),
        "Depends": depends,
        "SXR-Depends": sxr_depends,
        "Description": description or f"SkyOS package {name}",
        "Format": "spk-binary-v2",
        "Runtime": runtime,
        "EntryPoint": entry_point,
        "Commands": commands,
        "PackageType": package_type,
        "GUI": bool(gui),
        "Installer": bool(installer),
        "Executable": bool(entry_point or commands),
        "TuringComplete": True,
        "Permissions": {
            "read": allow_read,
            "write": allow_write,
        },
    }

    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        payload = td / "payload.tar.gz"
        with tarfile.open(payload, "w:gz") as tar:
            if source:
                _add_tree_to_tar(tar, source, ".")
            if python_source:
                py_src, pyc_src = _compile_python_tree(python_source, td / "python-build")
                _add_tree_to_tar(tar, py_src, f"opt/{name}/src")
                _add_tree_to_tar(tar, pyc_src, f"opt/{name}/pyc")
            if c_source:
                obj_root = _compile_c_sources(c_source, td / "c-build")
                _add_tree_to_tar(tar, obj_root, f"opt/{name}/obj")
            if nasm_source:
                obj_root = _compile_nasm_sources(nasm_source, td / "nasm-build")
                _add_tree_to_tar(tar, obj_root, f"opt/{name}/obj")
            if icon:
                icon = Path(icon)
                if not icon.exists():
                    raise FileNotFoundError(icon)
                tar.add(icon, arcname=f"usr/share/icons/{name}/{icon.name}")
            _add_json_to_tar(tar, meta, "SPK-MANIFEST.json", td)
        payload_bytes = payload.read_bytes()

    header = json.dumps(meta, ensure_ascii=False, sort_keys=True).encode("utf-8")
    output.write_bytes(MAGIC + struct.pack("<I", len(header)) + header + payload_bytes)
    return output


def build_sxr(output, name, version=SKYOS_VERSION, internal_version=SKYOS_INTERNAL_VERSION,
              abi="skyos-i386", description="", source=None):
    _check_name(name, "SXR name")
    _check_version(version, "version")
    _check_numeric(internal_version, "InternalVersion")
    output = Path(output)
    output.parent.mkdir(parents=True, exist_ok=True)
    meta = {
        "Package": name,
        "Version": version,
        "InternalVersion": str(internal_version),
        "Architecture": "i386",
        "ABI": abi,
        "Description": description or f"SkyOS runtime/library {name}",
        "Format": "sxr-binary-v1",
        "PackageType": "sxr-library",
        "Runtime": "sxr",
    }
    with tempfile.TemporaryDirectory() as td:
        td = Path(td)
        payload = td / "payload.tar.gz"
        with tarfile.open(payload, "w:gz") as tar:
            if source:
                _add_tree_to_tar(tar, source, ".")
            _add_json_to_tar(tar, meta, "SXR-MANIFEST.json", td)
        payload_bytes = payload.read_bytes()
    header = json.dumps(meta, ensure_ascii=False, sort_keys=True).encode("utf-8")
    output.write_bytes(SXR_MAGIC + struct.pack("<I", len(header)) + header + payload_bytes)
    return output


def build_index(repo, no_samples=False):
    repo = Path(repo)
    pool = repo / "pool/main"
    index_dir = repo / "dists/skyos/main/binary-i386"
    pool.mkdir(parents=True, exist_ok=True)
    index_dir.mkdir(parents=True, exist_ok=True)

    sample_packages = [
        ("base-tools", "Base SkyOS shell tools", ""),
        ("net-tools", "Network commands for SkyOS", "base-tools (>= 10002)"),
        ("editor-vi", "SkyOS vi editor package", "base-tools (>= 10002)"),
        ("sapp-utils", "Sapp package manager utilities", "base-tools (>= 10002), net-tools (>= 10002)"),
    ]
    if not no_samples:
        has_packages = any(pool.glob("*.spk"))
        for name, desc, deps in sample_packages:
            path = pool / package_filename(name, SKYOS_VERSION)
            should_write = not has_packages or not path.exists()
            if path.exists():
                try:
                    should_write = read_metadata(path).get("_format") not in ("spk-binary-v1", "spk-binary-v2")
                except Exception:
                    should_write = True
            if should_write:
                build_package(path, name=name, depends=deps, description=desc)

    entries = []
    for file in sorted(list(pool.glob("*.spk")) + list(pool.glob("*.sxr"))):
        match = re.fullmatch(r"([A-Za-z0-9][A-Za-z0-9+.-]*)_([A-Za-z0-9][A-Za-z0-9+.:~-]*)_skyos-i386\.(spk|sxr)", file.name)
        if not match:
            raise ValueError(f"unsupported package filename: {file.name}")
        fallback_name, fallback_version, _ = match.groups()
        meta = read_metadata(file)
        name = meta.get("Package") or fallback_name
        version = meta.get("Version") or fallback_version
        internal = meta.get("InternalVersion") or SKYOS_INTERNAL_VERSION
        compatible = meta.get("CompatibleInternalVersion") or SKYOS_INTERNAL_VERSION
        system = meta.get("System") or SKYOS_SYSTEM_ID
        depends = meta.get("Depends") or ""
        sxr_depends = meta.get("SXR-Depends") or ""
        description = meta.get("Description") or f"SkyOS package {name}"
        validate_depends(depends)
        validate_sxr_depends(sxr_depends)
        _check_numeric(internal, "InternalVersion")
        _check_numeric(compatible, "CompatibleInternalVersion")
        digest = hashlib.sha256(file.read_bytes()).hexdigest()
        lines = [
            f"Package: {name}",
            f"Version: {version}",
            f"InternalVersion: {internal}",
            "Architecture: i386",
            f"System: {system}",
            f"CompatibleInternalVersion: {compatible}",
        ]
        if depends:
            lines.append(f"Depends: {depends}")
        if sxr_depends:
            lines.append(f"SXR-Depends: {sxr_depends}")
        lines.extend([
            f"Filename: pool/main/{file.name}",
            f"Size: {file.stat().st_size}",
            f"SHA256: {digest}",
            f"Format: {meta.get('Format') or meta.get('_format') or 'spk-binary-v1'}",
        ])
        for key in ("Runtime", "EntryPoint", "Commands", "PackageType", "Permissions", "TuringComplete"):
            value = _meta_string(meta, key)
            if value:
                lines.append(f"{key}: {value}")
        lines.append(f"Description: {description}")
        entries.append("\n".join(lines))

    if not entries:
        raise ValueError(f"no .spk or .sxr packages found under {pool}")

    (index_dir / "Packages").write_text("\n\n".join(entries) + "\n", encoding="ascii", errors="ignore")
    (repo / "dists/skyos").mkdir(parents=True, exist_ok=True)
    (repo / "dists/skyos/Release").write_text(
        "Origin: SkyOS\nLabel: SkyApps\nSuite: skyos\nCodename: skyos\nArchitectures: i386\nComponents: main\n",
        encoding="ascii",
    )


def validate_repo(repo):
    repo = Path(repo)
    index = repo / "dists/skyos/main/binary-i386/Packages"
    if not index.exists() or not index.read_text(encoding="ascii", errors="strict").strip():
        raise ValueError(f"Packages index missing or empty: {index}")
    for entry in re.split(r"(?:\r?\n){2,}", index.read_text(encoding="ascii")):
        if not entry.strip():
            continue
        fields = {}
        for line in entry.splitlines():
            match = re.match(r"^([^:]+):\s*(.*)$", line)
            if match:
                fields[match.group(1)] = match.group(2)
        path = repo / fields["Filename"]
        if not path.exists():
            raise ValueError(f"indexed package missing: {fields['Filename']}")
        if int(fields["Size"]) != path.stat().st_size:
            raise ValueError(f"size mismatch: {fields['Filename']}")
        if hashlib.sha256(path.read_bytes()).hexdigest().lower() != fields["SHA256"].lower():
            raise ValueError(f"sha256 mismatch: {fields['Filename']}")


def main():
    parser = argparse.ArgumentParser(description="SkyOS SPK binary package tool")
    sub = parser.add_subparsers(dest="cmd", required=True)
    p = sub.add_parser("pack", help="build binary .spk from files")
    p.add_argument("--name", required=True)
    p.add_argument("--version", default=SKYOS_VERSION)
    p.add_argument("--internal-version", default=SKYOS_INTERNAL_VERSION)
    p.add_argument("--system", default=SKYOS_SYSTEM_ID)
    p.add_argument("--compatible-internal-version", default=SKYOS_INTERNAL_VERSION)
    p.add_argument("--depends", default="")
    p.add_argument("--description", default="")
    p.add_argument("--source")
    p.add_argument("--python-source")
    p.add_argument("--c-source", action="append", default=[])
    p.add_argument("--nasm-source", action="append", default=[])
    p.add_argument("--entry", default="")
    p.add_argument("--command", action="append", default=[])
    p.add_argument("--runtime", default="")
    p.add_argument("--package-type", default="app")
    p.add_argument("--sxr-depends", default="")
    p.add_argument("--gui", action="store_true")
    p.add_argument("--installer", action="store_true")
    p.add_argument("--icon")
    p.add_argument("--allow-read", default="")
    p.add_argument("--allow-write", default="")
    p.add_argument("--output", required=True)
    p = sub.add_parser("sxr", help="build SXR runtime/library package")
    p.add_argument("--name", required=True)
    p.add_argument("--version", default=SKYOS_VERSION)
    p.add_argument("--internal-version", default=SKYOS_INTERNAL_VERSION)
    p.add_argument("--abi", default="skyos-i386")
    p.add_argument("--description", default="")
    p.add_argument("--source")
    p.add_argument("--output", required=True)
    p = sub.add_parser("inspect", help="print package metadata")
    p.add_argument("spk")
    p = sub.add_parser("index", help="rebuild repository Packages index")
    p.add_argument("--repo", default=str(Path(__file__).resolve().parent / "repo"))
    p.add_argument("--no-samples", action="store_true")
    p = sub.add_parser("validate", help="validate repository")
    p.add_argument("--repo", default=str(Path(__file__).resolve().parent / "repo"))
    args = parser.parse_args()

    try:
        if args.cmd == "pack":
            build_package(args.output, args.name, args.version, args.internal_version, args.system,
                          args.compatible_internal_version, args.depends, args.description,
                          source=args.source, python_source=args.python_source,
                          c_source=args.c_source, nasm_source=args.nasm_source,
                          entry_point=args.entry, commands=args.command, runtime=args.runtime,
                          package_type=args.package_type, sxr_depends=args.sxr_depends,
                          gui=args.gui, installer=args.installer, icon=args.icon,
                          allow_read=args.allow_read, allow_write=args.allow_write)
        elif args.cmd == "sxr":
            build_sxr(args.output, args.name, args.version, args.internal_version, args.abi,
                      args.description, source=args.source)
        elif args.cmd == "inspect":
            path = Path(args.spk)
            if not path.exists():
                raise FileNotFoundError(f"SPK file not found: {path}")
            print(json.dumps(read_metadata(path), ensure_ascii=False, indent=2))
        elif args.cmd == "index":
            build_index(args.repo, no_samples=args.no_samples)
        elif args.cmd == "validate":
            validate_repo(args.repo)
    except Exception as exc:
        raise SystemExit(f"spk: error: {exc}")


if __name__ == "__main__":
    main()
