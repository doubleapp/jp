@echo off
setlocal enabledelayedexpansion

echo ============================================================================
echo JP - Directory Jumper - Remote Installer
echo ============================================================================
echo.

set "REPO=doubleapp/jp"
set "TEMP_DIR=%TEMP%\jp-install"
set "TEMP_ZIP=%TEMP%\jp-latest.zip"

echo Downloading latest JP release from GitHub...
echo.

REM Clean up previous temp files
if exist "%TEMP_ZIP%" del "%TEMP_ZIP%"
if exist "%TEMP_DIR%" rmdir /s /q "%TEMP_DIR%"

REM Download and extract latest release
powershell -ExecutionPolicy Bypass -Command ^
    "$ProgressPreference = 'SilentlyContinue'; " ^
    "try { " ^
    "  $release = Invoke-RestMethod -Uri 'https://api.github.com/repos/%REPO%/releases/latest'; " ^
    "  $zipUrl = ($release.assets | Where-Object { $_.name -like 'jp-*.zip' }).browser_download_url; " ^
    "  if (-not $zipUrl) { Write-Host 'ERROR: No zip asset found in latest release' -ForegroundColor Red; exit 1 } " ^
    "  Write-Host \"Downloading $($release.tag_name)...\"; " ^
    "  Invoke-WebRequest -Uri $zipUrl -OutFile '%TEMP_ZIP%'; " ^
    "  Write-Host 'Extracting...'; " ^
    "  Expand-Archive -Path '%TEMP_ZIP%' -DestinationPath '%TEMP_DIR%' -Force; " ^
    "  Write-Host 'Download complete!' -ForegroundColor Green " ^
    "} catch { " ^
    "  Write-Host \"ERROR: $($_.Exception.Message)\" -ForegroundColor Red; exit 1 " ^
    "}"

if errorlevel 1 (
    echo.
    echo Download failed. Check your internet connection and try again.
    pause
    exit /b 1
)

REM Find the extracted folder and run install
echo.
for /d %%D in ("%TEMP_DIR%\jp-*") do (
    set "INSTALL_SOURCE=%%D"
)

if not defined INSTALL_SOURCE (
    echo ERROR: Could not find extracted files.
    pause
    exit /b 1
)

echo.
echo Choose installation type:
echo   1. Batch version (CMD)
echo   2. PowerShell version (with Tab Completion)
echo.
choice /C 12 /M "Select version"
if errorlevel 2 (
    call "!INSTALL_SOURCE!\install-powershell.bat"
) else (
    call "!INSTALL_SOURCE!\install.bat"
)

REM Cleanup
del "%TEMP_ZIP%" 2>nul
rmdir /s /q "%TEMP_DIR%" 2>nul

exit /b 0
