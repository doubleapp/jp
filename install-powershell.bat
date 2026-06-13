@echo off
setlocal enabledelayedexpansion

echo ============================================================================
echo JP - PowerShell Version Installation (with Tab Completion!)
echo ============================================================================
echo.

REM The repo folder this installer lives in IS the source of truth.
REM Nothing is copied: shells are wired to load jp directly from here, so a
REM `git pull` updates behavior with no reinstall and no manual hacks.
set "SCRIPT_DIR=%~dp0"
set "REPO_DIR=%SCRIPT_DIR:~0,-1%"
set "INSTALL_DIR=%USERPROFILE%\bin"

echo This installer will (repo-direct, no file copies):
echo   1. Create %INSTALL_DIR% (if needed) and add it to PATH
echo   2. Create jp.bat / jp.cmd shims that call this repo's jp.bat
echo   3. Wire your PowerShell profile to this repo's jp-completion.ps1
echo   4. Register this repo with Clink for CMD tab completion (if installed)
echo.
echo   Source of truth: %REPO_DIR%
echo.

choice /C YN /M "Do you want to continue"
if errorlevel 2 goto :cancel

echo.
echo [Step 1] Creating installation directory and adding to PATH...
if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%"
    echo   Created: %INSTALL_DIR%
) else (
    echo   Already exists: %INSTALL_DIR%
)
powershell -ExecutionPolicy Bypass -Command "$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $binPath = '%INSTALL_DIR%'; if ($userPath -notlike \"*$binPath*\") { [Environment]::SetEnvironmentVariable('PATH', \"$userPath;$binPath\", 'User'); Write-Host '  Added to PATH' } else { Write-Host '  Already in PATH' }"

echo.
echo [Step 2] Creating jp shims (CMD)...
REM IMPORTANT: jp must run as a NATIVE batch in the parent shell so `cd`
REM persists. A `powershell -File jp.ps1` wrapper runs in a CHILD process and
REM can NEVER change the parent's directory -- that was the old bug. These
REM shims `call` the repo's native jp.bat, whose `endlocal & cd /d` persists.
(
echo @echo off
echo REM Thin shim -^> always runs the live repo version ^(updates via `git pull`^).
echo REM Do not add logic here; edit "%REPO_DIR%\jp.bat" instead.
echo call "%REPO_DIR%\jp.bat" %%*
) > "%INSTALL_DIR%\jp.bat"
copy /Y "%INSTALL_DIR%\jp.bat" "%INSTALL_DIR%\jp.cmd" >nul
echo   Created: jp.bat and jp.cmd shims -^> %REPO_DIR%\jp.bat

echo.
echo [Step 3] Wiring PowerShell profile for the jp function + tab completion...
REM The profile dot-sources the repo's jp-completion.ps1, which defines the
REM `jp` FUNCTION (it dot-sources jp.ps1 so Set-Location persists in YOUR
REM session) and registers tab completion.
powershell -ExecutionPolicy Bypass -Command "$profileDir = Split-Path $PROFILE; if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir -Force | Out-Null }; $line = \". '%REPO_DIR%\jp-completion.ps1'\"; $jpImport = \"`n# JP Directory Jumper - function and tab completion`n$line`n\"; if (Test-Path $PROFILE) { $content = Get-Content $PROFILE -Raw; if ($content -like '*jp-completion.ps1*') { $content = $content -replace '(?m)^.*jp-completion\.ps1.*$', $line; Set-Content $PROFILE $content; Write-Host '  Updated profile to load jp-completion.ps1 from repo' } elseif ($content -like '*jp.ps1*') { $content = $content -replace '(?m)^.*jp\.ps1.*$', $line; Set-Content $PROFILE $content; Write-Host '  Migrated old jp.ps1 reference to jp-completion.ps1' } else { Add-Content $PROFILE $jpImport; Write-Host '  Added tab completion to PowerShell profile' } } else { Set-Content $PROFILE $jpImport; Write-Host '  Created PowerShell profile with tab completion' }"

echo.
echo [Step 4] Clink TAB completion for CMD (optional)...
if exist "C:\Program Files (x86)\clink\clink_x64.exe" (
    "C:\Program Files (x86)\clink\clink_x64.exe" installscripts "%REPO_DIR%" >nul 2>&1
    echo   Registered repo with Clink for CMD tab completion.
) else (
    if exist "C:\Program Files (x86)\clink\clink.bat" (
        call "C:\Program Files (x86)\clink\clink.bat" installscripts "%REPO_DIR%" >nul 2>&1
        echo   Registered repo with Clink for CMD tab completion.
    ) else (
        echo   Clink not found. For CMD tab completion: winget install chrisant996.clink
        echo   Then re-run this installer.
    )
)

echo.
echo ============================================================================
echo Installation Complete!
echo ============================================================================
echo.
echo Repo-direct install: jp now loads from %REPO_DIR%
echo A `git pull` in that folder updates jp everywhere - no reinstall needed.
echo.
echo Next steps:
echo   1. Close and reopen your CMD or PowerShell window
echo   2. Try: jp add myproject C:\path\to\project
echo   3. Try: jp [TAB] - Press TAB to cycle through shortcuts!
echo   4. Try: jp myproject
echo.
echo NOTE: If you move or delete the repo folder, re-run this installer.
echo.
pause
exit /b 0

:cancel
echo.
echo Installation cancelled.
pause
exit /b 1
