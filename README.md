# ChemSymbolSearch 化工图例符号库 AutoCAD 插件

这是一个用于 AutoCAD 的化工绘图图例符号搜索插件。它可以把已有的 DWG 图例符号整理成一个可搜索的图库，在 AutoCAD 里输入中文关键词后，直接选择并插入对应图块，不用每次重新画阀门、法兰、泵、仪表、管件等常用符号。

本项目包含：

- AutoCAD AutoLISP 插件源码
- 393 个化工工艺流程图常用 DWG 图例符号
- 一键安装到 D 盘短路径的脚本
- 图例索引文件 `symbol-index.csv`

项目主要面向中文化工、工艺、管道、设备、仪表、自控、工程制图相关用户。搜索词也建议使用中文，例如 `球阀`、`保温法兰`、`泵`、`流量计`、`压力表`。

## 为什么做这个插件

化工制图里有大量重复出现的标准图例。很多人手里其实已经有一批 DWG 图例文件，但真正画图时仍然要到文件夹里翻、打开、复制、粘贴，非常慢。

这个插件的目标很简单：

- 把散落的 DWG 图例变成一个可以搜索的符号库
- 在 AutoCAD 里直接按中文关键词查找
- 查到后直接插入当前图纸
- 尽量使用简单命令，不依赖复杂安装环境
- 方便大家继续补充、改进和开源共享

## 已测试环境

- AutoCAD 2026
- Windows
- 插件运行路径建议使用：`D:\ChemSymbolSearch`

如果你的 AutoCAD 或 Windows 装在 C 盘也可以使用，但建议仍然把本插件安装到 D 盘短路径。AutoCAD 对很长的中文路径有时会报错，短路径更稳定。

## 安装方法

### 方法一：下载发行包，推荐

1. 打开本项目 GitHub 页面右侧的 `Releases`。
2. 下载最新版本的压缩包，例如：

```text
ChemSymbolSearch-AutoCAD-v0.1.0.zip
```

3. 解压到任意目录。
4. 双击运行：

```text
Install.cmd
```

5. 安装完成后，插件会被复制到：

```text
D:\ChemSymbolSearch
```

然后按下面的 AutoCAD 加载步骤继续操作。

### 方法二：下载源码或克隆仓库

1. 下载或克隆本仓库。

2. 在 PowerShell 里进入本项目目录，运行：

```powershell
.\scripts\Install-To-D-ShortPath.ps1
```

3. 安装后会生成这个目录：

```text
D:\ChemSymbolSearch
```

其中主要文件是：

```text
D:\ChemSymbolSearch\ChemSymbolSearch.lsp
D:\ChemSymbolSearch\Library
D:\ChemSymbolSearch\ChemSymbolSearch.root
```

4. 打开 AutoCAD，输入命令：

```text
APPLOAD
```

5. 在弹出的窗口里加载：

```text
D:\ChemSymbolSearch\ChemSymbolSearch.lsp
```

6. 加载成功后，在 AutoCAD 命令行输入：

```text
HGSYMINFO
```

如果看到类似下面的信息，说明插件和图库识别成功：

```text
Indexed DWG files: 393
```

## 推荐使用方式

当前最推荐使用命令行模式：

```text
HGSYMFIND
```

完整流程如下。

1. 在 AutoCAD 命令行输入：

```text
HGSYMFIND
```

2. 插件提示：

```text
Search symbol:
```

输入中文关键词，例如：

```text
球阀
```

3. AutoCAD 会列出搜索结果，每条结果前面都有编号，例如：

```text
1. 球阀 [化工类系统组件]
2. 电动球阀 [化工类系统组件]
3. 气动球阀 [化工类系统组件]
```

4. 如果底部命令行只显示最后一两条结果，按 `F2` 打开 AutoCAD 命令历史窗口，就能看到完整编号列表。

5. 插件提示：

```text
Insert result number <0 to cancel>:
```

输入你想插入的结果编号，例如：

```text
1
```

输入 `0` 表示取消。

6. 根据 AutoCAD 提示，在图纸中点击插入点。

7. AutoCAD 会询问 X 比例：

```text
输入 X 比例因子
```

一般先输入：

```text
1
```

8. AutoCAD 会询问 Y 比例：

```text
输入 Y 比例因子
```

通常输入和 X 一样的值，例如：

```text
1
```

9. AutoCAD 会询问旋转角度。

如果不需要旋转，直接按回车，默认就是 `0`。

## 比例怎么选

不同图纸的单位和比例可能不一样，所以插入后可能会觉得图例太小或太大。

建议这样试：

- 第一次先用 `1`、`1`
- 如果太小，撤销后试 `10`、`10`
- 还小就试 `100`、`100`
- 如果太大，就试 `0.1`、`0.1`

这里要输入两次，是因为 AutoCAD 原生命令会分别询问 X 比例和 Y 比例。一般为了不变形，X 和 Y 输入同一个数。

## 常用命令

- `HGSYMFIND`：命令行搜索并插入图例，推荐使用
- `HGSYM`：打开搜索对话框
- `HGSYMINFO`：查看图库路径和索引到的 DWG 数量
- `HGSYMHELP`：显示命令帮助
- `HGSYMREINDEX`：重新扫描图库
- `HGSYMSETROOT`：手动设置图库文件夹
- `HGSYMROOT`：显示当前图库文件夹

## 搜索技巧

可以直接输入中文名称，也可以输入名称中的一部分。

例子：

```text
球阀
法兰
保温
泵
流量
压力
仪表
截止阀
止回阀
```

如果搜不到，可以试试更短的词。例如搜不到 `保温法兰连接`，可以改搜 `保温` 或 `法兰`。

## 常见问题

### 1. APPLOAD 后提示已经加载，但命令没反应

先输入：

```text
HGSYMINFO
```

确认是否能看到索引数量。如果索引数量是 `0`，说明图库路径没有识别正确，可以运行：

```text
HGSYMSETROOT
```

然后输入图库目录，例如：

```text
D:\ChemSymbolSearch\Library
```

### 2. 搜索结果看不全

按 `F2` 打开 AutoCAD 命令历史窗口，看完整编号列表。

### 3. 插入后看起来很小

这是图纸单位和图例单位不一致导致的。撤销后重新插入，比例试 `10`、`10` 或 `100`、`100`。

### 4. 为什么比例要输入两遍

AutoCAD 的 `-INSERT` 命令会分别询问 X 比例和 Y 比例。一般输入同一个数字即可，例如 `1`、`1`。

### 5. 路径太长或中文路径报错

建议使用默认安装路径：

```text
D:\ChemSymbolSearch
```

AutoCAD 对过长路径、复杂中文路径有时不稳定，短路径最省心。

## 目录结构

```text
ChemSymbolSearch-AutoCAD
├─ src
│  └─ ChemSymbolSearch.lsp
├─ scripts
│  ├─ Install-To-D-ShortPath.ps1
│  ├─ Install-To-D-ShortPath.cmd
│  └─ LoadPlugin.scr
├─ Library
│  └─ 393 个 DWG 图例符号
├─ symbol-index.csv
├─ README.md
└─ LICENSE
```

## 开源说明

插件源码使用 MIT License。

本仓库中的 DWG 图例符号由维护者随项目公开发布，目的是方便化工制图学习、交流和工程绘图复用。欢迎继续补充图例、改进搜索词、优化 AutoCAD 使用体验。

如果你补充了新的 DWG 图例，建议放入 `Library` 目录，并运行 `HGSYMREINDEX` 重新扫描。
