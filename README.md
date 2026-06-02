# ChemSymbolSearch for AutoCAD

AutoCAD AutoLISP plugin for searching and inserting chemical process drawing symbols from a local DWG library.

This repository contains the plugin code, helper scripts, and an open chemical-process DWG symbol library maintained for public use.

## Features

- Search DWG symbols by file name, folder, category, and path.
- Insert an existing DWG as a block using AutoCAD's `-INSERT` command.
- Dialog command: `HGSYM`.
- Command-line fallback: `HGSYMFIND`.
- Diagnostics: `HGSYMINFO`, `HGSYMHELP`, `HGSYMREINDEX`.
- Designed for a short, stable Windows path: `D:\ChemSymbolSearch`.

## Install

1. Download or clone this repository.
2. Run:

```powershell
.\scripts\Install-To-D-ShortPath.ps1
```

3. The included DWG library will be installed into:

```text
D:\ChemSymbolSearch\Library
```

4. In AutoCAD, run `APPLOAD` and load:

```text
D:\ChemSymbolSearch\ChemSymbolSearch.lsp
```

5. Run:

```text
HGSYMINFO
```

You should see the number of indexed DWG files.

## Usage

Command-line mode:

```text
HGSYMFIND
```

Then enter a keyword, select a numbered result, pick the insertion point, enter scale `1`, and rotation `0`.

Dialog mode:

```text
HGSYM
```

If the dialog is unstable on your AutoCAD install, use `HGSYMFIND`.

## Commands

- `HGSYM`: open the search dialog.
- `HGSYMFIND`: search and insert from the command line.
- `HGSYMINFO`: print the active library folder and indexed DWG count.
- `HGSYMHELP`: print command help.
- `HGSYMREINDEX`: rebuild the DWG index.
- `HGSYMSETROOT`: set the library folder.
- `HGSYMROOT`: show the active library folder.

## DWG Asset Notice

The plugin code is MIT licensed. DWG symbol files included in this repository are published by the maintainer for public use with this project.
