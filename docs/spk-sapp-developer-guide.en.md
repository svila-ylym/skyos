# SPK / SAPP Developer Guide

This document explains the SkyOS SPK package format, SAPP repository, packaging workflow, publishing workflow, admin server, and SkyOS-side installation model.

## 1. Core Concepts

- **SPK**: SkyOS software package file. The extension is `.spk`.
- **SAPP**: SkyOS package manager and repository mechanism.
- **Package pool**: `.spk` files are stored under `repo/pool/main/`.
- **Index**: The package index is stored at `repo/dists/skyos/main/binary-i386/Packages`.
- **Default source**:

```text
deb http://skyapps.skyu.cc.cd skyos main
```

The local development server listens on `8080`. For public deployment, reverse-proxy `skyapps.skyu.cc.cd:80` to that service.

## 2. SPK Binary Format

SPK v1 is a binary container:

```text
offset  size      description
0       4         magic: ASCII "SPK1"
4       4         JSON header length, little-endian uint32
8       N         UTF-8 JSON metadata
8 + N   rest      gzip-compressed tar payload
```

In short:

```text
SPK1 + <4-byte little-endian JSON length> + JSON metadata + tar.gz payload
```

`sappserver/spk.py inspect` reads the header and JSON metadata without extracting the full package.

## 3. Metadata Fields

Example:

```json
{
  "Package": "hello",
  "Version": "1.0.1.0.SKYCNQU",
  "InternalVersion": "10002",
  "Architecture": "i386",
  "System": "skyos-10002",
  "CompatibleInternalVersion": "10002",
  "Depends": "base-tools (>= 10002)",
  "Description": "Hello package for SkyOS",
  "Format": "spk-binary-v1"
}
```

Rules:

- `Package` is the package name.
- `Version` is the user-facing display version.
- `InternalVersion` is the numeric internal version used for dependency comparison.
- `CompatibleInternalVersion` is the compatible SkyOS internal version.
- Version comparisons in `Depends` must use internal versions, such as `base-tools (>= 10002)`.
- `Format` is currently `spk-binary-v1`.

## 4. Payload Layout

Regular file packages use `--source`:

```text
hello-root/
  bin/hello.txt
  README.txt
```

Payload paths become:

```text
bin/hello.txt
README.txt
```

Python projects use `--python-source`. The tool stores source and `.pyc` bytecode under:

```text
opt/<package>/src/
opt/<package>/pyc/
```

Note: Python compilation here means CPython bytecode compilation, not native SkyOS machine-code compilation.

## 5. Creating a Regular SPK

```powershell
mkdir cache\hello-root\bin
"hello from SkyOS SPK" | Out-File -Encoding ascii cache\hello-root\bin\hello.txt

python sappserver\spk.py pack `
  --name hello `
  --version 1.0.1.0.SKYCNQU `
  --internal-version 10002 `
  --compatible-internal-version 10002 `
  --system skyos-10002 `
  --depends "base-tools (>= 10002)" `
  --description "Hello package for SkyOS" `
  --source cache\hello-root `
  --output sappserver\repo\pool\main\hello_1.0.1.0.SKYCNQU_skyos-i386.spk
```

## 6. Creating a Python SPK

```powershell
python sappserver\spk.py pack `
  --name skycalc `
  --version 1.0.1.0.SKYCNQU `
  --internal-version 10002 `
  --compatible-internal-version 10002 `
  --system skyos-10002 `
  --depends "base-tools (>= 10002)" `
  --description "Minimal Python interactive calculator for SkyOS" `
  --python-source cache\skycalc `
  --output sappserver\repo\pool\main\skycalc_1.0.1.0.SKYCNQU_skyos-i386.spk
```

## 7. Inspection, Indexing, Validation

Inspect package metadata:

```powershell
python sappserver\spk.py inspect sappserver\repo\pool\main\hello_1.0.1.0.SKYCNQU_skyos-i386.spk
```

Rebuild the index:

```powershell
python sappserver\spk.py index --repo sappserver\repo --no-samples
```

Validate the repository:

```powershell
python sappserver\spk.py validate --repo sappserver\repo
```

`validate` checks that the index exists, package files exist, `Size` matches, and `SHA256` matches.

## 8. SAPP Repository Layout

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
      hello_1.0.1.0.SKYCNQU_skyos-i386.spk
      skycalc_1.0.1.0.SKYCNQU_skyos-i386.spk
```

Example `Packages` entry:

```text
Package: hello
Version: 1.0.1.0.SKYCNQU
InternalVersion: 10002
Architecture: i386
System: skyos-10002
CompatibleInternalVersion: 10002
Depends: base-tools (>= 10002)
Filename: pool/main/hello_1.0.1.0.SKYCNQU_skyos-i386.spk
Size: 379
SHA256: <sha256>
Format: spk-binary-v1
Description: Hello package for SkyOS
```

## 9. Dependency Rules

```text
Depends: base-tools (>= 10002)
Depends: base-tools (>= 10002), net-tools (>= 10002)
```

Dependency versions must use internal versions. Use `10002`, not `1.0.1.0.SKYCNQU`.

## 10. SAPP Server

Start the server:

```powershell
python sappserver\sapp_manage_server.py --repo sappserver\repo --bind 0.0.0.0 --port 8080
```

Routes:

```text
/                                  public package list
/admin/login                       admin login
/admin                             management panel
/api/packages                      public package JSON
/api/stats                         admin download statistics JSON
/dists/skyos/main/binary-i386/Packages
/pool/main/*.spk
```

Default admin account:

```text
username: admin
password: skyos
```

Override with environment variables:

```powershell
$env:SAPP_ADMIN_USER="admin"
$env:SAPP_ADMIN_PASSWORD="your-password"
python sappserver\sapp_manage_server.py --repo sappserver\repo --bind 0.0.0.0 --port 8080
```

Download statistics are stored at:

```text
sappserver/repo/.sapp/download-stats.json
```

## 11. SkyOS-side Workflow

```text
sapp source
sapp update
sapp list
sapp search hello
sapp install hello
sapp remove hello
```

At the current kernel stage, SAPP can show package names, versions, internal versions, dependencies, binary `.spk` filenames, sizes, and install state. Full HTTP body storage, tar.gz extraction, and real filesystem installation are later runtime/installer work.

## 12. Publishing Workflow

1. Write package content.
2. Use `spk.py pack` to generate `.spk`.
3. Put it under `sappserver/repo/pool/main/`.
4. Run `python sappserver/spk.py index --repo sappserver/repo --no-samples`.
5. Run `python sappserver/spk.py validate --repo sappserver/repo`.
6. Start the SAPP server.
7. Point `http://skyapps.skyu.cc.cd` to the repository service.
8. In SkyOS, run `sapp update` and `sapp install <package>`.
