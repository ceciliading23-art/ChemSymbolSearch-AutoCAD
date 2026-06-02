$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
$version = if ($args.Count -gt 0) { $args[0] } else { "v0.1.0" }
$distDir = Join-Path $repoRoot "dist"
$packageRoot = Join-Path $distDir "ChemSymbolSearch-AutoCAD-$version"
$zipPath = Join-Path $distDir "ChemSymbolSearch-AutoCAD-$version.zip"

if (Test-Path $packageRoot) {
    Remove-Item -LiteralPath $packageRoot -Recurse -Force
}

if (Test-Path $zipPath) {
    Remove-Item -LiteralPath $zipPath -Force
}

New-Item -ItemType Directory -Path $packageRoot | Out-Null

$items = @(
    "src",
    "scripts",
    "Library",
    "Install.cmd",
    "symbol-index.csv",
    "SYMBOL-CATALOG.zh-CN.md",
    "README.md",
    "INSTALL.zh-CN.md",
    "LICENSE"
)

foreach ($item in $items) {
    $source = Join-Path $repoRoot $item
    if (Test-Path $source) {
        Copy-Item -LiteralPath $source -Destination $packageRoot -Recurse -Force
    }
}

Compress-Archive -Path (Join-Path $packageRoot "*") -DestinationPath $zipPath -Force

Write-Host "Release package created:"
Write-Host "  $zipPath"
