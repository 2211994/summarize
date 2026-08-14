# DWG2PNG

**基于 AutoCAD Core Console + AutoLISP + Batch 实现的 DWG 批量转 PNG 工具**

一个用于自动化处理 AutoCAD `.dwg` 文件的 Windows 批处理工具。

本项目通过 AutoCAD 自带的 `accoreconsole.exe` 以命令行方式打开 DWG 文件，并调用 AutoLISP 自动完成页面设置、视图缩放以及 PNG 发布；随后使用 ImageMagick 对生成的 PNG 进行尺寸调整。

项目主要用于 **CAD 图纸批量转换、计算机视觉数据预处理以及 YOLO / CVAT 数据集制作**。

> 本项目主要作为个人学习、实验和项目记录使用。

---

## ✨ 项目简介

在进行 CAD 图纸相关的计算机视觉项目时，经常需要将大量 DWG 文件转换成普通图片。

传统方式需要：

```text
打开 AutoCAD
    ↓
打开 DWG
    ↓
设置页面
    ↓
设置打印参数
    ↓
导出 PNG
    ↓
关闭 DWG
    ↓
重复处理下一个文件
```

当 DWG 文件数量较多时，这种方式效率较低。

本项目利用 AutoCAD 提供的：

```text
accoreconsole.exe
```

将整个过程自动化。

最终实现：

```text
DWG
 ↓
Batch
 ↓
AutoCAD Core Console
 ↓
AutoLISP
 ↓
页面设置
 ↓
Zoom Extents
 ↓
PublishToWeb PNG
 ↓
PNG
 ↓
ImageMagick
 ↓
调整尺寸
```

---

# 🚀 核心功能

### 1. 批量处理 DWG

自动遍历指定输入目录中的 `.dwg` 文件，并逐个进行转换。

---

### 2. 自动调用 AutoCAD Core Console

使用：

```text
accoreconsole.exe
```

以命令行方式执行 AutoCAD 操作，不需要手动打开 AutoCAD 图形界面。

---

### 3. 自动生成临时 SCR

Batch 脚本在处理每一个 DWG 时，会创建：

```text
temp.scr
```

用于向 AutoCAD Core Console 发送自动化命令。

基本流程：

```text
加载 AutoLISP
    ↓
执行 DWG2PNG_CORE
    ↓
完成 PNG 发布
    ↓
退出 AutoCAD
```

---

### 4. 自动加载 AutoLISP

核心 AutoLISP 文件：

```text
DWG2PNG_CORE.lsp
```

其中定义：

```lisp
(defun c:DWG2PNG_CORE ...)
```

负责执行实际的 DWG → PNG 转换过程。

---

### 5. 自动导入页面设置

项目提供：

```text
YOLO_EXPORT.dwt
```

作为 AutoCAD 页面设置模板。

程序会自动执行：

```text
-PSETUPIN
```

导入：

```text
YOLO_EXPORT
```

页面设置。

PNG 输出使用 AutoCAD 自带的：

```text
PublishToWeb PNG.pc3
```

---

### 6. 自动 Zoom Extents

程序会自动切换到模型空间，并执行：

```text
ZOOM
EXTENTS
```

使图纸内容尽可能完整地进入输出范围。

---

### 7. 自动跳过已经转换的文件

程序会检查目标 PNG 是否已经存在。

例如：

```text
001.dwg
001.png
```

如果：

```text
001.png
```

已经存在，则跳过该 DWG，避免重复转换。

---

### 8. PNG 尺寸调整

AutoCAD 输出的 PNG 通常具有非常大的分辨率。

本项目另外提供：

```text
resize_png.bat
```

使用 ImageMagick 对 PNG 进行尺寸调整。

目前主要将原始约 **16K** 尺寸的图片缩小到约 **3000 像素长度**，以降低后续标注程序处理大尺寸图片时的负担。

---

# 📂 项目结构

```text
summarize/
│
├── DWG2PNG_BATCH.bat
│   └── DWG 批量转换主程序
│
├── DWG2PNG_CORE.lsp
│   └── AutoCAD DWG → PNG 核心程序
│
├── YOLO_EXPORT.dwt
│   └── AutoCAD 页面设置模板
│
├── resize_png.bat
│   └── PNG 尺寸调整脚本
│
├── temp.scr
│   └── AutoCAD 临时 Script 文件
│
└── README.md
    └── 项目说明
```

---

# 🔧 工作原理

## 整体流程

```text
DWG 文件
   │
   ▼
DWG2PNG_BATCH.bat
   │
   ├── 设置环境
   ├── 设置 AutoCAD 路径
   ├── 设置输入 / 输出目录
   ├── 遍历 DWG
   ├── 检查 PNG 是否存在
   │
   ▼
生成 temp.scr
   │
   ▼
accoreconsole.exe
   │
   ├── 打开 DWG
   ├── 加载 DWG2PNG_CORE.lsp
   │
   ▼
DWG2PNG_CORE
   │
   ├── 获取 DWG 文件名
   ├── 导入 YOLO_EXPORT 页面设置
   ├── 切换 Model Space
   ├── Zoom Extents
   ├── 关闭后台打印
   └── -PLOT
   │
   ▼
PublishToWeb PNG.pc3
   │
   ▼
PNG
   │
   ▼
resize_png.bat
   │
   ▼
缩放后的 PNG
```

---

# 🧩 DWG2PNG_BATCH.bat

`DWG2PNG_BATCH.bat` 是整个项目的入口。

主要负责以下工作：

### 设置命令行编码

由于部分文件路径可能包含中文，因此使用：

```bat
chcp 65001 >nul
```

避免命令行中文乱码，同时隐藏 `chcp` 输出。

---

### 开启延迟变量展开

使用：

```bat
setlocal enabledelayedexpansion
```

方便在循环中使用：

```bat
!COUNT!
```

等动态变量。

---

### 设置 AutoCAD Core Console

指定：

```text
accoreconsole.exe
```

所在位置。

---

### 设置输入 / 输出目录

分别指定：

```text
DWG 输入目录
PNG 输出目录
```

如果 PNG 输出目录不存在，则自动创建。

---

### 遍历 DWG

程序遍历输入目录中的：

```text
*.dwg
```

并获取当前 DWG 的文件名。

例如：

```text
001.dwg
```

得到：

```text
001
```

用于后续生成：

```text
001.png
```

---

### 检查 PNG 是否存在

如果目标 PNG 已经存在：

```text
001.png
```

则跳过：

```text
001.dwg
```

避免重复处理。

---

### 创建 temp.scr

程序动态创建：

```text
temp.scr
```

其中包含类似：

```text
加载 LSP
↓
执行 DWG2PNG_CORE
↓
QUIT
```

的命令。

---

### 启动 AutoCAD Core Console

最终调用：

```text
accoreconsole.exe
```

打开当前 DWG，并执行生成的 SCR 文件。

处理完成之后继续循环处理下一个 DWG。

---

# 🧠 DWG2PNG_CORE.lsp

`DWG2PNG_CORE.lsp` 是整个项目的核心。

定义的主要命令：

```lisp
DWG2PNG_CORE
```

---

## 1. 获取当前 DWG 文件名

通过：

```lisp
(getvar "DWGNAME")
```

获取当前 DWG 文件名。

然后使用：

```lisp
(vl-filename-base ...)
```

去掉：

```text
.dwg
```

后缀。

例如：

```text
Drawing001.dwg
```

转换为：

```text
Drawing001
```

---

## 2. 生成 PNG 输出路径

根据 DWG 文件名拼接 PNG 文件路径。

例如：

```text
Drawing001.dwg
```

最终输出：

```text
Drawing001.png
```

---

## 3. 导入页面设置

程序调用：

```text
-PSETUPIN
```

导入：

```text
YOLO_EXPORT.dwt
```

中的：

```text
YOLO_EXPORT
```

页面设置。

---

## 4. 切换模型空间

程序将当前布局切换到：

```text
MODEL
```

确保打印的是模型空间中的图纸内容。

---

## 5. Zoom Extents

执行：

```text
ZOOM
EXTENTS
```

使当前图纸内容尽可能完整地显示。

---

## 6. 关闭后台打印

程序关闭后台打印，以减少批量处理过程中可能出现的打印任务冲突，提高批处理稳定性。

---

## 7. 执行 PNG Plot

最终调用：

```text
-PLOT
```

并指定：

```text
布局：
MODEL

页面设置：
YOLO_EXPORT

打印设备：
PublishToWeb PNG.pc3

输出：
xxx.png
```

完成 PNG 文件发布。

---

# 🖼️ resize_png.bat

`resize_png.bat` 用于对 AutoCAD 输出的 PNG 图片进行二次处理。

项目使用：

```text
ImageMagick 7.1.2
```

完成图片尺寸调整。

---

## 为什么需要缩放？

AutoCAD 导出的 PNG 图片尺寸通常比较大，目前实际输出可能达到约：

```text
16K
```

对于后续图像标注来说，这样的尺寸没有太大必要。

过大的图片会导致：

```text
文件体积增加
    ↓
标注软件加载速度下降
    ↓
内存占用增加
    ↓
标注效率下降
```

因此通过 ImageMagick 将图片缩放到约：

```text
3000 px
```

长度。

从而更适合后续的：

```text
CVAT
YOLO
计算机视觉数据集
```

等处理流程。

---

# ⚙️ 使用方法

## 1. 准备 AutoCAD

电脑需要安装 AutoCAD，并确保存在：

```text
accoreconsole.exe
```

不同 AutoCAD 版本的安装路径可能不同。

---

## 2. 准备 DWG 文件

将需要转换的 DWG 文件放入指定输入目录。

例如：

```text
INPUT/
├── 001.dwg
├── 002.dwg
├── 003.dwg
└── ...
```

---

## 3. 修改路径

**使用本项目之前，需要根据自己的电脑修改路径。**

主要修改：

```text
DWG2PNG_BATCH.bat
DWG2PNG_CORE.lsp
```

中的相关路径。

包括：

```text
AutoCAD Core Console 路径
DWG 输入目录
PNG 输出目录
YOLO_EXPORT.dwt 路径
```

当前仓库中的路径是作者个人项目环境中的路径，并不是通用路径。

---

## 4. 执行批处理

运行：

```text
DWG2PNG_BATCH.bat
```

程序开始自动处理 DWG。

例如：

```text
001.dwg
002.dwg
003.dwg
004.dwg
```

会依次转换为：

```text
001.png
002.png
003.png
004.png
```

---

## 5. 调整 PNG

DWG 转换完成之后，运行：

```text
resize_png.bat
```

对 PNG 进行尺寸调整。

---

# 📐 页面设置

项目依赖：

```text
YOLO_EXPORT.dwt
```

其中保存了项目需要使用的 AutoCAD 页面设置。

同时使用 AutoCAD 自带的：

```text
PublishToWeb PNG.pc3
```

作为 PNG 输出设备。

因此，如果在其他电脑上运行项目，需要确保：

```text
YOLO_EXPORT.dwt
```

路径正确，并且 AutoCAD 中能够正常使用：

```text
PublishToWeb PNG.pc3
```

---

# ⚠️ 注意事项

### 1. 路径需要修改

当前项目中的路径是开发环境中的实际路径。

例如：

```text
F:\YOLO_Donut_Project\
```

如果换电脑或者修改项目目录，需要同步修改：

```text
DWG2PNG_BATCH.bat
DWG2PNG_CORE.lsp
```

中的路径。

---

### 2. AutoCAD 版本不同可能需要修改 Core Console 路径

不同版本 AutoCAD 的：

```text
accoreconsole.exe
```

位置可能不同。

请根据实际安装位置修改。

---

### 3. 页面设置需要存在

如果：

```text
YOLO_EXPORT
```

页面设置不存在，或者：

```text
YOLO_EXPORT.dwt
```

路径错误，可能导致 Plot 失败。

---

### 4. PNG 输出结果与 DWG 内容有关

不同 DWG 文件的：

* 图形范围
* 图层
* 坐标
* 模型空间内容
* 字体
* 外部参照
* 页面设置

可能不同。

因此该工具主要针对具有相对统一结构的 DWG 批量处理场景。

---

# 🤖 与 YOLO / CVAT 的关系

这个项目本身主要负责：

```text
DWG → PNG
```

以及：

```text
PNG 尺寸预处理
```

它属于整个计算机视觉数据集制作流程中的**数据预处理环节**。

例如：

```text
CAD DWG
   │
   ▼
DWG2PNG
   │
   ▼
PNG
   │
   ▼
Resize
   │
   ▼
CVAT
   │
   ▼
目标标注
   │
   ▼
YOLO Dataset
```

因此项目名称虽然是 `summarize`，但实际功能更准确地说是：

> **AutoCAD DWG 批量转换及图像预处理工具。**

---

# 🔍 项目文件说明

| 文件                  | 作用                     |
| ------------------- | ---------------------- |
| `DWG2PNG_BATCH.bat` | 批量处理 DWG 的入口程序         |
| `DWG2PNG_CORE.lsp`  | AutoCAD DWG → PNG 核心逻辑 |
| `YOLO_EXPORT.dwt`   | AutoCAD 页面设置模板         |
| `resize_png.bat`    | PNG 尺寸调整               |
| `temp.scr`          | AutoCAD 临时 Script      |
| `README.md`         | 项目说明                   |

---

# 📊 完整处理流程

```text
┌──────────────────────┐
│      DWG 文件        │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ DWG2PNG_BATCH.bat    │
│   批量遍历 DWG       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│      temp.scr        │
│   自动生成命令脚本   │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ accoreconsole.exe    │
│ AutoCAD Core Console │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ DWG2PNG_CORE.lsp     │
│                      │
│ 页面设置             │
│ Zoom Extents         │
│ PNG Plot             │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│        PNG           │
│     原始大尺寸       │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│   resize_png.bat     │
│     ImageMagick      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│    Resize PNG        │
│     ~3000 px         │
└──────────────────────┘
```

---

# 🛠️ 后续改进方向

目前这个项目主要用于个人学习和实际项目中的数据预处理。

后续可以进一步完善：

* [ ] 自动检测 AutoCAD 安装路径
* [ ] 将所有路径统一到配置文件
* [ ] 支持命令行参数
* [ ] 支持自定义输入 / 输出目录
* [ ] 增加转换成功 / 失败统计
* [ ] 增加错误日志
* [ ] 增加进度显示
* [ ] 自动检测 AutoCAD Core Console 是否存在
* [ ] 自动检测 ImageMagick 是否安装
* [ ] 支持自定义 PNG 输出尺寸
* [ ] 优化 DWG 异常处理
* [ ] 与 CVAT / YOLO 数据集流程进一步结合

---

# 📌 项目定位

这是一个针对 **AutoCAD DWG 批量图像化处理** 的自动化脚本项目。

核心思想非常简单：

> **把原本需要人工重复执行的 AutoCAD DWG → PNG 操作，通过 Batch + Core Console + AutoLISP 自动化。**

项目目前主要用于：

* AutoCAD 自动化学习
* DWG 批量处理
* CAD 数据预处理
* 计算机视觉数据集制作
* YOLO 数据集准备
* CVAT 标注前的图片处理

---

# 👤 Author

**2211994**

GitHub Repository:

[2211994/summarize](https://github.com/2211994/summarize?utm_source=chatgpt.com)

---

## ⭐ 一句话总结

> **DWG2PNG 是一个基于 AutoCAD Core Console、AutoLISP 和 Windows Batch 的 DWG 批量转 PNG 工具，并结合 ImageMagick 对输出图片进行尺寸预处理，主要用于 CAD 图纸的自动化图像生成及后续计算机视觉数据集制作。**
