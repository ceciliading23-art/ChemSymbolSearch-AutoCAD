$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$targetDir = "D:\ChemSymbolSearch"
$targetLibrary = Join-Path $targetDir "Library"

if (-not (Test-Path $targetDir)) {
    New-Item -ItemType Directory -Path $targetDir | Out-Null
}

if (-not (Test-Path $targetLibrary)) {
    New-Item -ItemType Directory -Path $targetLibrary | Out-Null
}

Copy-Item -LiteralPath (Join-Path $repoRoot "src\ChemSymbolSearch.lsp") -Destination (Join-Path $targetDir "ChemSymbolSearch.lsp") -Force
Copy-Item -LiteralPath (Join-Path $repoRoot "scripts\LoadPlugin.scr") -Destination (Join-Path $targetDir "LoadPlugin.scr") -Force

$repoLibrary = Join-Path $repoRoot "Library"
if (Test-Path $repoLibrary) {
    Copy-Item -Path (Join-Path $repoLibrary "*") -Destination $targetLibrary -Recurse -Force
}

if (Test-Path (Join-Path $repoRoot "symbol-index.csv")) {
    Copy-Item -LiteralPath (Join-Path $repoRoot "symbol-index.csv") -Destination (Join-Path $targetDir "symbol-index.csv") -Force
}

Set-Content -Path (Join-Path $targetDir "ChemSymbolSearch.root") -Value $targetLibrary -Encoding ASCII

Write-Host "Installed ChemSymbolSearch to:"
Write-Host "  $targetDir"
Write-Host ""
Write-Host "DWG library folder:"
Write-Host "  $targetLibrary"
Write-Host ""
Write-Host "In AutoCAD, APPLOAD:"
Write-Host "  D:\ChemSymbolSearch\ChemSymbolSearch.lsp"
Write-Host ""
Write-Host "Then run HGSYMINFO."
