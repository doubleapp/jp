@echo off
setlocal enabledelayedexpansion

echo ============================================================================
echo JP - PowerShell Version Installation (with Tab Completion!)
echo ============================================================================
echo.

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "INSTALL_DIR=%USERPROFILE%\bin"

echo This installer will:
echo   1. Create %INSTALL_DIR% (if needed)
echo   2. Copy jp.ps1 to %INSTALL_DIR%
echo   3. Create jp.cmd wrapper for easy calling
echo   4. Add %INSTALL_DIR% to your PATH
echo   5. Set up PowerShell profile for tab completion
echo.

choice /C YN /M "Do you want to continue"
if errorlevel 2 goto :cancel

echo.
echo [Step 1] Creating installation directory...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo   Created: %INSTALL_DIR%
) else (
    echo   Already exists: %INSTALL_DIR%
)

echo.
echo [Step 2] Copying jp.ps1...
copy /Y "%SCRIPT_DIR%jp.ps1" "%INSTALL_DIR%\jp.ps1" >nul
if errorlevel 1 (
    echo   ERROR: Failed to copy jp.ps1
    goto :error
)
echo   Copied: jp.ps1 to %INSTALL_DIR%

echo.
echo [Step 3] Creating jp.cmd wrapper...
(
echo @echo off
echo powershell -NoProfile -ExecutionPolicy Bypass -File "%INSTALL_DIR%\jp.ps1" %%*
) > "%INSTALL_DIR%\jp.cmd"
echo   Created: jp.cmd wrapper

echo.
echo [Step 4] Adding to PATH...
powershell -ExecutionPolicy Bypass -Command "$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $binPath = '%INSTALL_DIR%'; if ($userPath -notlike \"*$binPath*\") { [Environment]::SetEnvironmentVariable('PATH', \"$userPath;$binPath\", 'User'); Write-Host '  Added to PATH' } else { Write-Host '  Already in PATH' }"

echo.
echo [Step 5] Setting up PowerShell profile for tab completion...
powershell -ExecutionPolicy Bypass -Command "$profileDir = Split-Path $PROFILE; if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }; $jpImport = \"`n# JP Directory Jumper Tab Completion`n. '%INSTALL_DIR%\jp.ps1' -Command dummy 2>`$null`n\"; if (Test-Path $PROFILE) { $content = Get-Content $PROFILE -Raw; if ($content -notlike '*jp.ps1*') { Add-Content $PROFILE $jpImport; Write-Host '  Added tab completion to PowerShell profile' } else { Write-Host '  Tab completion already in profile' } } else { Set-Content $PROFILE $jpImport; Write-Host '  Created PowerShell profile with tab completion' }"

echo.
echo ============================================================================
echo Installation Complete!
echo ============================================================================
echo.
echo PowerShell version installed with TAB COMPLETION support!
echo.
echo Next steps:
echo   1. Close and reopen your CMD or PowerShell window
echo   2. Try: jp add myproject C:\path\to\project
echo   3. Try: jp [TAB] - Press TAB to cycle through shortcuts!
echo   4. Try: jp myproject
echo.
echo NOTE: Tab completion works best in PowerShell!
echo In CMD, you can still use: jp list
echo.
echo Choose your version:
echo   - jp.ps1 / jp.cmd = PowerShell version with tab completion
echo   - jp.bat = Batch version (faster but no tab completion)
echo.
pause
exit /b 0

:cancel
echo.
echo Installation cancelled.
pause
exit /b 1

:error
echo.
echo Installation failed!
pause
exit /b 1
