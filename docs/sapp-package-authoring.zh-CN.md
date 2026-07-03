# SAPP 包编写、打包和发布教程

## 1. 当前推荐语言

当前推荐用 Python 编写可分发包内容，并用 `sappserver/spk.py` 打包成 `.spk`。原因是 SkyOS 的用户态 ABI、ELF 加载、动态库和原生编译工具链还在完善中，直接把 C/C++/ASM 编译成可运行 SkyOS 原生程序会复杂很多。

这里的“编译 Python”指把 `.py` 编译成 CPython 字节码 `.pyc`，再和源码一起放进二进制 SPK。它不是机器码编译；后续 SkyOS 需要 Python 运行时或加载器执行这些包。

## 2. 版本规则

当前 SkyOS：

```text
Version: 1.0.3.0.GSOSYGP
InternalVersion: 10015
System: skyos-10015
```

规则：
- `Version` 是显示给用户看的版本名。
- `InternalVersion` 是数字内部版本。
- `Depends` 和兼容判断必须使用内部版本，例如 `base-tools (>= 10015)`。
- 包文件名使用 `<包名>_<版本名>_skyos-i386.spk`。

示例：

```text
hello_1.0.3.0.GSOSYGP_skyos-i386.spk
```

## 3. 二进制 SPK 格式

SPK v1 格式：

```text
SPK1 + JSON 元数据长度 + JSON 元数据 + tar.gz 载荷
```

元数据字段：

```text
Package
Version
InternalVersion
Architecture
System
CompatibleInternalVersion
Depends
Description
Format
```

## 4. 打包普通文件

准备目录：

```text
hello-root/
  bin/
    hello
  etc/
    hello.conf
```

打包：

```sh
cd sappserver
python spk.py pack \
  --name hello \
  --version 1.0.3.0.GSOSYGP \
  --internal-version 10015 \
  --compatible-internal-version 10015 \
  --system skyos-10015 \
  --depends "base-tools (>= 10015)" \
  --description "Hello command for SkyOS" \
  --source ../hello-root \
  --output repo/pool/main/hello_1.0.3.0.GSOSYGP_skyos-i386.spk
```

## 5. 打包 Python 项目

项目示例：

```text
hello-python/
  main.py
  lib/
    message.py
```

打包：

```sh
cd sappserver
python spk.py pack \
  --name hello-python \
  --version 1.0.3.0.GSOSYGP \
  --internal-version 10015 \
  --depends "base-tools (>= 10015)" \
  --description "Python demo package" \
  --python-source ../hello-python \
  --output repo/pool/main/hello-python_1.0.3.0.GSOSYGP_skyos-i386.spk
```

包内路径：

```text
opt/hello-python/src/   Python 源码
opt/hello-python/pyc/   编译后的 .pyc 字节码
```

## 6. 查看和验证包

查看元数据：

```sh
python spk.py inspect repo/pool/main/hello_1.0.3.0.GSOSYGP_skyos-i386.spk
```

重建索引：

```sh
python spk.py index --repo repo --no-samples
```

验证软件源：

```sh
python spk.py validate --repo repo
```

## 7. 启动管理后台

```sh
cd sappserver
python sapp_manage_server.py --repo repo --bind 0.0.0.0 --port 8080
```

访问：

```text
http://127.0.0.1:8080/       公开包列表
http://127.0.0.1:8080/admin  管理后台
```

后台可以新建二进制 SPK、上传 SPK、删除包和重建索引。

## 8. 发布流程

1. 用 `spk.py pack` 生成 `.spk`。
2. 把 `.spk` 放入 `sappserver/repo/pool/main`。
3. 执行 `python spk.py index --repo repo --no-samples`。
4. 执行 `python spk.py validate --repo repo`。
5. 启动服务器或把 `repo` 目录发布到 Web 根目录。
6. 在 SkyOS 中配置源：`deb http://skyapps.skyu.cc.cd skyos main`。本地调试可临时使用 `http://<server-ip>:8080`。
7. 执行 `sapp update`、`sapp search <包名>`、`sapp install <包名>`。

## 9. 常见错误

- 文件名不符合规则：改为 `<name>_<version>_skyos-i386.spk`。
- 依赖版本写了 `1.0.3.0.GSOSYGP`：改成内部版本，例如 `10015`。
- 上传后列表没有变化：在 `/admin` 点击“重建索引”。
- `SHA256` 或 `Size` 不匹配：不要手改 `Packages`，重新运行 `spk.py index`。
