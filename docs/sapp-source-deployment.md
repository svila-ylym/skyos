# SAPP Source Deployment Guide

SPK/SAPP developer guide: `docs/spk-sapp-developer-guide.en.md`.

Chinese package authoring guide: `docs/sapp-package-authoring.zh-CN.md`.

## Quick Start

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

URLs:

```text
http://127.0.0.1:8080/       public package list
http://127.0.0.1:8080/admin  admin panel
```

SkyOS source entry:

```text
deb http://skyapps.skyu.cc.cd skyos main
```

For local testing you can use `http://<server-ip>:8080`. For public use, keep `http://skyapps.skyu.cc.cd` as the default source and reverse-proxy port 80 to this server on port 8080.

## Repository Commands

```sh
cd sappserver
python spk.py index --repo repo
python spk.py validate --repo repo
```

The shell and PowerShell wrappers call the same binary SPK tooling.

## Single-Port Routes

- `/`: public package list.
- `/admin`: management panel.
- `/api/packages`: package list JSON.
- `/dists/skyos/main/binary-i386/Packages`: package index.
- `/pool/main/*.spk`: binary package downloads.

## Layout

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
