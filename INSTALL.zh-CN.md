# 快速安装说明

这个压缩包是 ChemSymbolSearch 化工图例符号库 AutoCAD 插件的发行包，适合普通用户直接下载使用。

## 一键安装

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

3. 双击运行：

```text
Install.cmd
```

4. 安装程序会显示默认安装目录，例如：

```text
Default install folder:
  D:\ChemSymbolSearch

Install folder, or press Enter for default:
```

看到这里时，直接按回车即可使用默认目录。不要输入 `install`。

如果想安装到别的短路径，也可以输入：

```text
C:\ChemSymbolSearch
```

或：

```text
E:\ChemSymbolSearch
```

默认规则：

- 如果电脑有 D 盘，默认安装到 `D:\ChemSymbolSearch`
- 如果电脑没有 D 盘，默认安装到 `C:\ChemSymbolSearch`
- 也可以手动输入其他短路径，例如 `E:\ChemSymbolSearch`

建议使用短路径，尽量不要安装到很长的中文目录里。

5. 安装完成后，会生成你选择的安装目录。默认情况下可能是：

```text
D:\ChemSymbolSearch
```

或：

```text
C:\ChemSymbolSearch
```

主要文件包括：

```text
D:\ChemSymbolSearch\ChemSymbolSearch.lsp
D:\ChemSymbolSearch\Library
D:\ChemSymbolSearch\ChemSymbolSearch.root
```

如果你选择了 C 盘或其他目录，请把上面的 `D:\ChemSymbolSearch` 换成你的实际安装目录。

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

## 在 AutoCAD 里加载

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

4. 加载成功后输入：

```text
HGSYMINFO
```

如果看到：

```text
Indexed DWG files: 393
```

说明安装成功。

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
