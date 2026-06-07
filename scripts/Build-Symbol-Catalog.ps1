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
# Chinese symbol names and categories are read from symbol-index.csv.
$lines.Add("# ChemSymbolSearch Symbol Catalog")
$lines.Add("")
$lines.Add("This catalog lists the DWG symbols included in ChemSymbolSearch, grouped by category/device library.")
$lines.Add("")
$lines.Add("- Category ID is the number of a group, such as valve/fitting/pump symbols.")
$lines.Add("- Item No. is the number inside that category.")
$lines.Add("- Global ID is a stable number across the whole catalog.")
$lines.Add("- The 1/2/3 numbers shown by HGSYMFIND inside AutoCAD are search-result numbers for the current search only.")
$lines.Add("- When inserting in AutoCAD, use the result number currently shown in AutoCAD.")
$lines.Add("")
$lines.Add(("Total DWG symbols: {0}" -f $rows.Count))
$lines.Add("")
$lines.Add("## Categories")
$lines.Add("")
$lines.Add("| Category ID | Category | Count |")
$lines.Add("| ---: | --- | ---: |")

$groups = $rows | Group-Object {
    if ([string]::IsNullOrWhiteSpace($_.Category)) {
        if ([string]::IsNullOrWhiteSpace($_.Folder)) {
            "Uncategorized"
        } else {
            $_.Folder
        }
    } else {
        $_.Category
    }
} | Sort-Object Name

$categoryNo = 1
foreach ($group in $groups) {
    $categoryId = "C{0:D2}" -f $categoryNo
    $categoryName = $group.Name -replace "\|", "/"
    $lines.Add(("| {0} | {1} | {2} |" -f $categoryId, $categoryName, $group.Count))
    $categoryNo++
}

$lines.Add("")
$lines.Add("## Symbols By Category")
$lines.Add("")

$globalNo = 1
$categoryNo = 1
foreach ($group in $groups) {
    $categoryId = "C{0:D2}" -f $categoryNo
    $categoryName = $group.Name -replace "\|", "/"
    $lines.Add(("### {0} {1}" -f $categoryId, $categoryName))
    $lines.Add("")
    $lines.Add("| Item No. | Symbol Name | Global ID | DWG Path |")
    $lines.Add("| ---: | --- | ---: | --- |")

    $itemNo = 1
    foreach ($row in ($group.Group | Sort-Object Name, RelativePath)) {
        $itemId = "{0:D2}" -f $itemNo
        $globalId = "{0:D3}" -f $globalNo
        $name = $row.Name
        $path = $row.RelativePath

        foreach ($varName in @("name", "path")) {
            $value = Get-Variable -Name $varName -ValueOnly
            $value = $value -replace "\|", "/"
            Set-Variable -Name $varName -Value $value
        }

        $lines.Add(("| {0} | {1} | {2} | `{3}` |" -f $itemId, $name, $globalId, $path))
        $itemNo++
        $globalNo++
    }

    $lines.Add("")
    $categoryNo++
}

while (($lines.Count -gt 0) -and ($lines[$lines.Count - 1] -eq "")) {
    $lines.RemoveAt($lines.Count - 1)
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($catalogPath, ($lines -join "`n"), $utf8NoBom)

Write-Host "Symbol catalog created:"
Write-Host "  $catalogPath"
