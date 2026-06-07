# 快速安装说明

这个压缩包是 ChemSymbolSearch 化工图例符号库 AutoCAD 插件的发行包，适合普通用户直接下载使用。

## 最简单使用方法：解压后直接在 AutoCAD 加载

如果只是想马上试用，推荐先按这个方法操作，不需要运行安装脚本。

1. 右键 zip 文件，选择“全部解压”或“解压到当前文件夹”。

注意：一定要先解压整个 zip 压缩包，再运行安装程序。不要在 WinRAR、7-Zip 或 Windows 压缩包预览窗口里直接双击 `Install.cmd`，否则安装脚本可能找不到 `scripts` 文件夹。

2. 进入解压后的文件夹，确认能看到这些内容：

```text
Install.cmd
scripts
src
Library
README.md
```

3. 打开 AutoCAD。
4. 输入命令：

```text
APPLOAD
```

5. 在 APPLOAD 窗口里，进入刚才解压出来的文件夹，再进入：

```text
src
```

6. 选择并加载这个文件：

```text
ChemSymbolSearch.lsp
```

也就是类似这样的路径：

```text
你解压的位置\ChemSymbolSearch-AutoCAD-v0.1.2\src\ChemSymbolSearch.lsp
```

7. 加载成功时，AutoCAD 命令行应该出现：

```text
ChemSymbolSearch loaded. Run HGSYMINFO, HGSYM, or HGSYMFIND.
```

8. 在 AutoCAD 命令行输入：

```text
HGSYMINFO
```

正常应该显示：

```text
Indexed DWG files: 393
```

如果显示 `Indexed DWG files: 3`，说明插件扫到了错误目录，通常是扫到了项目顶层，而不是 `Library`。请运行 `HGSYMSETROOT`，输入下面这个路径：

```text
你解压的位置\ChemSymbolSearch-AutoCAD-v0.1.2\Library
```

然后运行：

```text
HGSYMREINDEX
```

再运行：

```text
HGSYMINFO
```

应该就会显示 `393`。

## 可选：安装到短路径

如果你不想每次都从下载目录加载，可以运行安装脚本，把插件复制到短路径，例如 `D:\ChemSymbolSearch` 或 `C:\ChemSymbolSearch`。

1. 进入解压后的文件夹。
2. 双击运行：

```text
Install.cmd
```

3. 安装程序会显示默认安装目录。看到 `Install folder, or press Enter for default:` 时，直接按回车即可使用默认目录。不要输入 `install`。

4. 安装完成后，会生成你选择的安装目录。默认情况下可能是：

```text
D:\ChemSymbolSearch
```

或：

```text
C:\ChemSymbolSearch
```

## 常见安装卡点

### 提示 `.ps1` 文件不存在

常见报错类似：

```text
-File 形式参数的实际参数 ...\scripts\Install-To-D-ShortPath.ps1 不存在
```

这通常说明你没有先解压整个 zip，而是在压缩包预览窗口里直接运行了 `Install.cmd`。请重新右键 zip 文件，选择“全部解压”，进入解压后的文件夹后再双击 `Install.cmd`。

### 安装目录那里应该填什么

看到：

```text
Install folder, or press Enter for default:
```

直接按回车即可。一般不需要填任何内容。不要输入 `install`。

## 安装到短路径后，在 AutoCAD 里加载

1. 打开 AutoCAD。
2. 输入命令：

```text
APPLOAD
```

3. 加载这个文件：

```text
D:\ChemSymbolSearch\ChemSymbolSearch.lsp
```

如果安装在 C 盘，则加载：

```text
C:\ChemSymbolSearch\ChemSymbolSearch.lsp
```

注意：APPLOAD 要加载的是 `ChemSymbolSearch.lsp` 这个文件，不是 `Install.cmd`、`LoadPlugin.scr`、zip 压缩包或 DWG 文件。

4. 加载成功时，AutoCAD 命令行应该出现类似提示：

```text
ChemSymbolSearch loaded. Run HGSYMINFO, HGSYM, or HGSYMFIND.
```

5. 加载成功后输入：

```text
HGSYMINFO
```

如果看到：

```text
Indexed DWG files: 393
```

说明安装成功。

如果输入 `HGSYMINFO` 或 `HGSYMFIND` 后提示“未知命令”，说明插件没有真正加载成功。请重新运行 `APPLOAD`，确认选择的是安装目录里的 `ChemSymbolSearch.lsp`。如果仍失败，按 `F2` 打开 AutoCAD 命令历史窗口查看加载报错。

## 搜索并插入图例

1. 输入命令：

```text
HGSYMFIND
```

2. 输入中文关键词，例如：

```text
球阀
```

3. 按编号选择结果。
4. 在图纸上点击插入点。
5. X 比例输入 `1`。
6. Y 比例输入 `1`。
7. 旋转角度直接按回车，默认是 `0`。

如果插入后图例太小，可以撤销后重新插入，比例改成 `10`、`10` 或 `100`、`100`。

如果搜索结果在 AutoCAD 底部命令行看不全，按 `F2` 打开命令历史窗口查看完整编号列表。

## 查看全部图例

压缩包里有这个文件：

```text
SYMBOL-CATALOG.zh-CN.md
```

它列出了全部图例、目录编号、分类和 DWG 路径。目录编号用于查找和交流；AutoCAD 插入时仍然以 `HGSYMFIND` 当前搜索结果显示的编号为准。

目录按装置/类别分组，例如：

```text
C01 阀门管件泵类设备
01 Y型过滤器
02 安全阀-通用
13 蝶阀
14 法兰
16 浮球阀1
17 浮球阀2
```

其中 `C01` 是分类编号，`01/02/13` 是该分类下的图例编号。
