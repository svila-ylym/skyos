# SkyApps Repository

For the full deployment guide, see `docs/sapp-source-deployment.md`.

Default source:

```text
http://skyapps.skyu.cc.cd
```

SkyOS reads the default source conceptually from:

```text
/etc/sapp/sources.list
```

Current built-in content:

```text
deb http://skyapps.skyu.cc.cd skyos main
```

## Suggested Server Layout

```text
/
  dists/
    skyos/
      main/
        binary-i386/
          Packages
  pool/
    main/
      base-tools_0.1_skyos-i386.spk
      net-tools_0.1_skyos-i386.spk
      editor-vi_0.1_skyos-i386.spk
```

## Packages Index Example

```text
Package: base-tools
Version: 0.1
Architecture: i386
Filename: pool/main/base-tools_0.1_skyos-i386.spk
Size: 1024
SHA256: TODO
Description: Base SkyOS shell tools

Package: net-tools
Version: 0.1
Architecture: i386
Filename: pool/main/net-tools_0.1_skyos-i386.spk
Size: 1024
SHA256: TODO
Description: Network command tools
```

## Minimal Deployment

1. Point DNS for `skyapps.skyu.cc.cd` to your web server.
2. Enable HTTPS for that hostname.
3. Serve static files using the layout above.
4. Place the `Packages` index at:

```text
http://skyapps.skyu.cc.cd/dists/skyos/main/binary-i386/Packages
```

5. Place package files under:

```text
http://skyapps.skyu.cc.cd/pool/main/
```

## Current SkyOS Limitation

`sapp` and `wget` commands are present, but remote HTTPS transfer is a command
stub until the e1000, IPv4, TCP, DNS, and TLS stack is implemented.
