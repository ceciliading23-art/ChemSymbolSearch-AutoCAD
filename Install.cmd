@echo off
setlocal

set "SCRIPT_PATH=%~dp0scripts\Install-To-D-ShortPath.ps1"

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
echo Press Enter to use the default folder.
echo Or type another short folder, for example C:\ChemSymbolSearch or E:\ChemSymbolSearch.
echo.
if not exist "%SCRIPT_PATH%" (
    echo [ERROR] Installer files are incomplete.
    echo.
    echo Please extract the whole zip file first, then run Install.cmd from the extracted folder.
    echo.
    echo Do not run Install.cmd directly inside WinRAR/7-Zip/Windows compressed folder preview.
    echo.
    pause
    exit /b 1
)

set /p TARGET_DIR=Install folder, or press Enter for default:
if "%TARGET_DIR%"=="" set "TARGET_DIR=%DEFAULT_TARGET%"

powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%SCRIPT_PATH%" -TargetDir "%TARGET_DIR%"
pause
