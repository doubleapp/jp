@echo off
setlocal enabledelayedexpansion

echo ============================================================================
echo JP - Directory Jumper Installation
echo ============================================================================
echo.

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"
set "INSTALL_DIR=%USERPROFILE%\bin"

echo This installer will:
echo   1. Create %INSTALL_DIR% (if needed)
echo   2. Copy jp.bat to %INSTALL_DIR%
echo   3. Add %INSTALL_DIR% to your PATH
echo   4. Optionally set up cmd_shortcuts.bat to auto-load
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
echo [Step 2] Copying jp.bat...
copy /Y "%SCRIPT_DIR%jp.bat" "%INSTALL_DIR%\jp.bat" >nul
if errorlevel 1 (
    echo   ERROR: Failed to copy jp.bat
    goto :error
)
echo   Copied: jp.bat to %INSTALL_DIR%

echo.
echo [Step 3] Adding to PATH...
powershell -ExecutionPolicy Bypass -Command "$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $binPath = '%INSTALL_DIR%'; if ($userPath -notlike \"*$binPath*\") { [Environment]::SetEnvironmentVariable('PATH', \"$userPath;$binPath\", 'User'); Write-Host '  Added to PATH' } else { Write-Host '  Already in PATH' }"

echo.
echo [Step 4] Auto-load cmd_shortcuts.bat (optional)
echo This will run cmd_shortcuts.bat automatically when you open CMD.
echo.
choice /C YN /M "Do you want to enable auto-load"
if errorlevel 2 goto :skip_autoload

copy /Y "%SCRIPT_DIR%cmd_shortcuts.bat" "%USERPROFILE%\cmd_shortcuts.bat" >nul
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "%USERPROFILE%\cmd_shortcuts.bat" /f >nul
echo   Enabled auto-load of cmd_shortcuts.bat
echo   Edit shortcuts in: %USERPROFILE%\cmd_shortcuts.bat
goto :after_autoload

:skip_autoload
echo   Skipped auto-load setup
copy /Y "%SCRIPT_DIR%cmd_shortcuts.bat" "%USERPROFILE%\cmd_shortcuts.bat" >nul
echo   You can manually run: %USERPROFILE%\cmd_shortcuts.bat

:after_autoload
echo.
echo [Step 5] Clink TAB completion (optional)
echo Clink adds TAB completion for jp shortcuts in CMD.
echo.
if exist "C:\Program Files (x86)\clink\clink_x64.exe" (
    echo   Clink detected!
    choice /C YN /M "Install jp TAB completion for Clink"
    if errorlevel 2 goto :skip_clink
    REM Get Clink scripts directory from clink info
    set "CLINK_SCRIPTS=%LOCALAPPDATA%\clink"
    if not exist "!CLINK_SCRIPTS!" mkdir "!CLINK_SCRIPTS!"
    copy /Y "%SCRIPT_DIR%jp_clink.lua" "!CLINK_SCRIPTS!\jp_clink.lua" >nul
    echo   Installed jp_clink.lua to !CLINK_SCRIPTS!
    echo   TAB completion will work in new CMD windows.
    goto :after_clink
) else (
    echo   Clink not found. Install Clink for TAB completion:
    echo     winget install chrisant996.clink
    echo   Then re-run this installer.
    goto :after_clink
)
:skip_clink
echo   Skipped Clink TAB completion setup

:after_clink
echo.
echo ============================================================================
echo Installation Complete!
echo ============================================================================
echo.
echo Next steps:
echo   1. Close and reopen your CMD window
echo   2. Try: jp add myproject C:\path\to\project
echo   3. Try: jp myproject
echo   4. Try: jp list
echo.
echo For help, run: jp
echo Full documentation: %SCRIPT_DIR%README.md
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
