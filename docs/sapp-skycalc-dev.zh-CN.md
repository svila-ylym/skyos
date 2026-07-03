# SkyCalc SPK 开发文档

本示例位于 `cache/skycalc`，用于演示如何用 Python 编写一个最小 SAPP 包并打包成二进制 `.spk`。

## 目录结构

```text
cache/skycalc/
  main.py       交互式命令行计算器
  README.md     包说明
  sapp.json     包元数据示例
```

## 依赖

最小依赖：

```text
base-tools (>= 10015)
```

`skycalc` 只使用 Python 标准库，不依赖第三方 Python 包。

## 本地运行

```powershell
python cache\skycalc\main.py
```

示例：

```text
calc> 1 + 2 * 3
7
calc> history
1: 1 + 2 * 3 = 7
calc> quit
```

## 打包 SPK

```powershell
python sappserver\spk.py pack `
  --name skycalc `
  --version 1.0.3.0.GSOSYGP `
  --internal-version 10015 `
  --compatible-internal-version 10015 `
  --system skyos-10015 `
  --depends "base-tools (>= 10015)" `
  --description "Minimal Python interactive calculator for SkyOS" `
  --python-source cache\skycalc `
  --output sappserver\repo\pool\main\skycalc_1.0.3.0.GSOSYGP_skyos-i386.spk
```

## 重建软件源索引

```powershell
python sappserver\spk.py index --repo sappserver\repo --no-samples
python sappserver\spk.py validate --repo sappserver\repo
```

## 查看包元数据

```powershell
python sappserver\spk.py inspect sappserver\repo\pool\main\skycalc_1.0.3.0.GSOSYGP_skyos-i386.spk
```

## 发布

1. 把生成的 `.spk` 保留在 `sappserver\repo\pool\main`。
2. 重建 `Packages` 索引。
3. 启动 SAPP 服务器：`python sappserver\sapp_manage_server.py --bind 0.0.0.0 --port 8080`。
4. 公网环境中把 `http://skyapps.skyu.cc.cd` 反向代理到该服务。
