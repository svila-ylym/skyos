# SPK / SAPP 开发详解

本文档说明 SkyOS 的 SPK 包格式、SAPP 软件源、打包、发布、后台管理和 SkyOS 侧安装流程。

## 1. 核心概念

- **SPK**：SkyOS 软件包文件，扩展名为 `.spk`。
- **SAPP**：SkyOS 包管理器和软件源机制。
- **包池**：`.spk` 文件放在 `repo/pool/main/`。
- **索引**：软件源索引放在 `repo/dists/skyos/main/binary-i386/Packages`。
- **默认源**：

```text
deb http://skyapps.skyu.cc.cd skyos main
```

本地服务器默认监听 `8080`，公网可以把 `skyapps.skyu.cc.cd:80` 反向代理到该端口。

## 2. SPK 二进制格式

SPK v1 是一个二进制容器：

```text
offset  size      description
0       4         magic: ASCII "SPK1"
4       4         JSON header length, little-endian uint32
8       N         UTF-8 JSON metadata
8 + N   rest      gzip-compressed tar payload
```

也就是：

```text
SPK1 + <4字节小端 JSON 长度> + JSON 元数据 + tar.gz 载荷
```

`sappserver/spk.py inspect` 只需要读取头部和 JSON 元数据，不需要解压整个包。

## 3. 元数据字段

示例：

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

规则：

- `Package` 是包名。
- `Version` 是显示给用户看的版本名。
- `InternalVersion` 是数字内部版本，用于依赖比较。
- `CompatibleInternalVersion` 是兼容的 SkyOS 内部版本。
- `Depends` 中的版本比较必须使用内部版本，例如 `base-tools (>= 10002)`。
- `Format` 当前固定为 `spk-binary-v1`。

## 4. 载荷路径

普通文件包使用 `--source`：

```text
hello-root/
  bin/hello.txt
  README.txt
```

打包后载荷路径为：

```text
bin/hello.txt
README.txt
```

Python 项目使用 `--python-source`，工具会把源码和 `.pyc` 字节码放入：

```text
opt/<package>/src/
opt/<package>/pyc/
```

注意：这里的 Python “编译”是 CPython 字节码编译，不是 SkyOS 原生机器码编译。

## 5. 创建普通 SPK

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

## 6. 创建 Python SPK

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

## 7. 查看、索引、校验

查看包元数据：

```powershell
python sappserver\spk.py inspect sappserver\repo\pool\main\hello_1.0.1.0.SKYCNQU_skyos-i386.spk
```

重建索引：

```powershell
python sappserver\spk.py index --repo sappserver\repo --no-samples
```

校验仓库：

```powershell
python sappserver\spk.py validate --repo sappserver\repo
```

`validate` 会检查索引存在、包文件存在、`Size` 匹配、`SHA256` 匹配。

## 8. SAPP 仓库结构

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

`Packages` 索引示例：

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

## 9. 依赖规则

```text
Depends: base-tools (>= 10002)
Depends: base-tools (>= 10002), net-tools (>= 10002)
```

依赖版本必须写内部版本。正确写法是 `10002`，不是 `1.0.1.0.SKYCNQU`。

## 10. SAPP 服务器

启动：

```powershell
python sappserver\sapp_manage_server.py --repo sappserver\repo --bind 0.0.0.0 --port 8080
```

路由：

```text
/                                  公开包列表
/admin/login                       后台登录
/admin                             管理后台
/api/packages                      公开包 JSON
/api/stats                         后台下载统计 JSON
/dists/skyos/main/binary-i386/Packages
/pool/main/*.spk
```

默认后台账号：

```text
username: admin
password: skyos
```

可用环境变量覆盖：

```powershell
$env:SAPP_ADMIN_USER="admin"
$env:SAPP_ADMIN_PASSWORD="your-password"
python sappserver\sapp_manage_server.py --repo sappserver\repo --bind 0.0.0.0 --port 8080
```

下载统计文件：

```text
sappserver/repo/.sapp/download-stats.json
```

## 11. SkyOS 侧流程

```text
sapp source
sapp update
sapp list
sapp search hello
sapp install hello
sapp remove hello
```

当前内核阶段能显示包名、版本、内部版本、依赖、二进制 `.spk` 文件名、大小和安装状态。完整 HTTP body 保存、tar.gz 解包和真实文件落盘仍属于后续运行时/安装器工作。

## 12. 发布流程

1. 编写包内容。
2. 使用 `spk.py pack` 生成 `.spk`。
3. 放入 `sappserver/repo/pool/main/`。
4. 运行 `python sappserver/spk.py index --repo sappserver/repo --no-samples`。
5. 运行 `python sappserver/spk.py validate --repo sappserver/repo`。
6. 启动 SAPP 服务器。
7. 公网把 `http://skyapps.skyu.cc.cd` 指向仓库服务。
8. SkyOS 中运行 `sapp update` 和 `sapp install <package>`。
