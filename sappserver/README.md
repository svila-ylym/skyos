# SkyOS SAPP 服务器

本目录提供 SkyOS SAPP 软件源、单端口 Web 管理后台和二进制 `.spk` 打包工具。

默认版本：
- 版本名：`1.0.1.0.SKYCNQU`
- 内部版本：`10002`
- 系统号：`skyos-10002`

依赖判断、兼容判断、包版本比较统一使用数字内部版本；展示给用户时使用版本名。

## 启动服务器

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
- `http://127.0.0.1:8080/`：公开包列表
- `http://127.0.0.1:8080/admin`：管理后台
- `http://127.0.0.1:8080/dists/skyos/main/binary-i386/Packages`：SAPP 索引

SkyOS 源配置：

```text
deb http://skyapps.skyu.cc.cd skyos main
```

本地调试时可以直接连 8080；正式公网建议把 `skyapps.skyu.cc.cd:80` 反向代理到本服务的 8080 端口。

## SPK 工具

`.spk` 现在是二进制包，格式为：

```text
SPK1 + JSON 元数据长度 + JSON 元数据 + tar.gz 载荷
```

构建示例包：

```sh
python spk.py index --repo repo
python spk.py validate --repo repo
```

查看包元数据：

```sh
python spk.py inspect repo/pool/main/base-tools_1.0.1.0.SKYCNQU_skyos-i386.spk
```

从普通目录打包：

```sh
python spk.py pack \
  --name hello \
  --version 1.0.1.0.SKYCNQU \
  --internal-version 10002 \
  --depends "base-tools (>= 10002)" \
  --description "Hello command for SkyOS" \
  --source ./hello-root \
  --output repo/pool/main/hello_1.0.1.0.SKYCNQU_skyos-i386.spk
```

从 Python 项目打包：

```sh
python spk.py pack \
  --name hello-python \
  --python-source ./hello-python \
  --output repo/pool/main/hello-python_1.0.1.0.SKYCNQU_skyos-i386.spk
```

Python 打包会把 `.py` 编译成 `.pyc`，并把源码放到 `opt/<包名>/src`、字节码放到 `opt/<包名>/pyc`。这不是把 Python 转成 SkyOS 原生机器码；它是当前阶段更稳定的发布格式，后续需要 SkyOS 的 Python 运行时或加载器来执行。

## 管理后台

`/admin` 支持：
- 新建二进制 SPK
- 上传已有 `.spk`
- 删除包
- 重建索引
- 管理包名、版本名、内部版本、兼容系统号、前置包和说明

## 文档

更完整的包编写和发布教程见：

```text
docs/spk-sapp-developer-guide.md
docs/spk-sapp-developer-guide.zh-CN.md
docs/spk-sapp-developer-guide.en.md
docs/sapp-package-authoring.zh-CN.md
```
