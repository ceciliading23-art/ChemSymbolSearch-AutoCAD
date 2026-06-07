param(
    [string]$TargetDir
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

if ([string]::IsNullOrWhiteSpace($TargetDir)) {
    if (Test-Path "D:\") {
        $TargetDir = "D:\ChemSymbolSearch"
    } else {
        $TargetDir = "C:\ChemSymbolSearch"
    }
}

$targetDir = $TargetDir
$targetLibrary = Join-Path $targetDir "Library"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

if (-not (Test-Path $targetLibrary)) {
    New-Item -ItemType Directory -Path $targetLibrary | Out-Null
}

Copy-Item -LiteralPath (Join-Path $repoRoot "src\ChemSymbolSearch.lsp") -Destination (Join-Path $targetDir "ChemSymbolSearch.lsp") -Force

$lspPath = (Join-Path $targetDir "ChemSymbolSearch.lsp") -replace "\\", "/"
$scrLines = @(
    ("(load ""{0}"")" -f $lspPath),
    "HGSYMINFO"
)
Set-Content -LiteralPath (Join-Path $targetDir "LoadPlugin.scr") -Value $scrLines -Encoding ASCII

$repoLibrary = Join-Path $repoRoot "Library"
if (Test-Path $repoLibrary) {
    Copy-Item -Path (Join-Path $repoLibrary "*") -Destination $targetLibrary -Recurse -Force
}

if (Test-Path (Join-Path $repoRoot "symbol-index.csv")) {
    Copy-Item -LiteralPath (Join-Path $repoRoot "symbol-index.csv") -Destination (Join-Path $targetDir "symbol-index.csv") -Force
}

if (Test-Path (Join-Path $repoRoot "SYMBOL-CATALOG.zh-CN.md")) {
    Copy-Item -LiteralPath (Join-Path $repoRoot "SYMBOL-CATALOG.zh-CN.md") -Destination (Join-Path $targetDir "SYMBOL-CATALOG.zh-CN.md") -Force
}

Set-Content -Path (Join-Path $targetDir "ChemSymbolSearch.root") -Value $targetLibrary -Encoding ASCII

Write-Host "Installed ChemSymbolSearch to:"
Write-Host "  $targetDir"
Write-Host ""
Write-Host "DWG library folder:"
Write-Host "  $targetLibrary"
Write-Host ""
Write-Host "In AutoCAD, APPLOAD:"
Write-Host ("  " + (Join-Path $targetDir "ChemSymbolSearch.lsp"))
Write-Host ""
Write-Host "Then run HGSYMINFO."
