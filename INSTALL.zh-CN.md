# 快速安装说明

这个压缩包是 ChemSymbolSearch 化工图例符号库 AutoCAD 插件的发行包，适合普通用户直接下载使用。

## 一键安装

1. 解压整个压缩包。
2. 双击运行：

```text
Install.cmd
```

3. 安装完成后，会生成：

```text
D:\ChemSymbolSearch
```

主要文件包括：

```text
D:\ChemSymbolSearch\ChemSymbolSearch.lsp
D:\ChemSymbolSearch\Library
D:\ChemSymbolSearch\ChemSymbolSearch.root
```

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
