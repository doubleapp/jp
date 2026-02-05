@echo off
setlocal enabledelayedexpansion

echo ============================================================================
echo JP - Directory Jumper Uninstallation
echo ============================================================================
echo.

set "INSTALL_DIR=%USERPROFILE%\bin"

echo This will:
echo   1. Remove jp.bat from %INSTALL_DIR%
echo   2. Remove %INSTALL_DIR% from PATH (if empty)
echo   3. Remove cmd_shortcuts.bat AutoRun (if configured)
echo   4. Optionally delete saved shortcuts
echo.

choice /C YN /M "Do you want to continue"
if errorlevel 2 goto :cancel

echo.
echo [Step 1] Removing jp.bat...
if exist "%INSTALL_DIR%\jp.bat" (
    del "%INSTALL_DIR%\jp.bat"
    echo   Deleted: jp.bat
) else (
    echo   Not found: jp.bat
)

echo.
echo [Step 2] Cleaning up PATH...
powershell -ExecutionPolicy Bypass -Command "$userPath = [Environment]::GetEnvironmentVariable('PATH', 'User'); $binPath = '%INSTALL_DIR%'; if ($userPath -like \"*$binPath*\") { $newPath = ($userPath -split ';' | Where-Object { $_ -ne $binPath }) -join ';'; [Environment]::SetEnvironmentVariable('PATH', $newPath, 'User'); Write-Host '  Removed from PATH' } else { Write-Host '  Not in PATH' }"

echo.
echo [Step 3] Removing AutoRun...
reg query "HKCU\Software\Microsoft\Command Processor" /v AutoRun >nul 2>&1
if not errorlevel 1 (
    reg delete "HKCU\Software\Microsoft\Command Processor" /v AutoRun /f >nul 2>&1
    echo   Removed AutoRun
    if exist "%USERPROFILE%\cmd_shortcuts.bat" (
        del "%USERPROFILE%\cmd_shortcuts.bat"
        echo   Deleted cmd_shortcuts.bat
    )
) else (
    echo   AutoRun not configured
)

echo.
echo [Step 4] Delete saved shortcuts?
choice /C YN /M "Delete %USERPROFILE%\.jump_directories"
if errorlevel 2 goto :keep_shortcuts

if exist "%USERPROFILE%\.jump_directories" (
    del "%USERPROFILE%\.jump_directories"
    echo   Deleted saved shortcuts
) else (
    echo   No shortcuts file found
)
goto :after_shortcuts

:keep_shortcuts
echo   Kept saved shortcuts

:after_shortcuts
echo.
echo ============================================================================
echo Uninstallation Complete!
echo ============================================================================
echo.
echo JP has been removed from your system.
echo Close and reopen CMD for PATH changes to take effect.
echo.
pause
exit /b 0

:cancel
echo.
echo Uninstallation cancelled.
pause
exit /b 1
