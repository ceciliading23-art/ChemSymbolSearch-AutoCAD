$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$indexPath = Join-Path $repoRoot "symbol-index.csv"
$catalogPath = Join-Path $repoRoot "SYMBOL-CATALOG.zh-CN.md"

if (-not (Test-Path $indexPath)) {
    throw "symbol-index.csv not found: $indexPath"
}

$rows = Import-Csv -LiteralPath $indexPath -Encoding UTF8
$lines = New-Object System.Collections.Generic.List[string]

# Keep this script ASCII-only for Windows PowerShell compatibility.
# The generated catalog still preserves Chinese symbol names from symbol-index.csv.
$lines.Add("# ChemSymbolSearch Symbol Catalog")
$lines.Add("")
$lines.Add("This catalog lists the DWG symbols included in ChemSymbolSearch.")
$lines.Add("")
$lines.Add("- Catalog ID is a stable number in this document, useful for lookup and discussion.")
$lines.Add("- The 1/2/3 numbers shown by HGSYMFIND inside AutoCAD are search-result numbers for the current search only.")
$lines.Add("- When inserting in AutoCAD, use the result number currently shown in AutoCAD.")
$lines.Add("")
$lines.Add(("Total DWG symbols: {0}" -f $rows.Count))
$lines.Add("")
$lines.Add("| Catalog ID | Symbol Name | Category | Folder | DWG Path |")
$lines.Add("| ---: | --- | --- | --- | --- |")

$i = 1
foreach ($row in $rows) {
    $id = "{0:D3}" -f $i
    $name = $row.Name
    $category = if ([string]::IsNullOrWhiteSpace($row.Category)) { "-" } else { $row.Category }
    $folder = if ([string]::IsNullOrWhiteSpace($row.Folder)) { "-" } else { $row.Folder }
    $path = $row.RelativePath

    foreach ($varName in @("name", "category", "folder", "path")) {
        $value = Get-Variable -Name $varName -ValueOnly
        $value = $value -replace "\|", "/"
        Set-Variable -Name $varName -Value $value
    }

    $lines.Add(("| {0} | {1} | {2} | {3} | `{4}` |" -f $id, $name, $category, $folder, $path))
    $i++
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllLines($catalogPath, $lines, $utf8NoBom)

Write-Host "Symbol catalog created:"
Write-Host "  $catalogPath"
