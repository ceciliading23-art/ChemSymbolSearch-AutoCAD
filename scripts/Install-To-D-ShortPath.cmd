@echo off
setlocal

if exist D:\ (
    set "DEFAULT_TARGET=D:\ChemSymbolSearch"
) else (
    set "DEFAULT_TARGET=C:\ChemSymbolSearch"
)

echo ChemSymbolSearch AutoCAD plugin installer
echo.
echo Default install folder:
echo   %DEFAULT_TARGET%
echo.
set /p TARGET_DIR=Install folder, or press Enter for default:
if "%TARGET_DIR%"=="" set "TARGET_DIR=%DEFAULT_TARGET%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0Install-To-D-ShortPath.ps1" -TargetDir "%TARGET_DIR%"
pause
