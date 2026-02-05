@echo off
setlocal enabledelayedexpansion

set "JUMPLIST=%USERPROFILE%\.jump_directories"
set "PREVIOUS=%USERPROFILE%\.jump_previous"
if defined JP_JUMPLIST set "JUMPLIST=!JP_JUMPLIST!"
if defined JP_PREVIOUS set "PREVIOUS=!JP_PREVIOUS!"

if "%~1"=="" (
    echo Usage: jp [name^|add^|list^|remove^|clean^|-]
    echo.
    echo Examples:
    echo   jp add web e:\EProjects\doubletap\storewebsite
    echo   jp add here .       - Add current directory
    echo   jp web              - Jump to saved directory
    echo   jp -                - Jump to previous directory ^(toggle back/forth^)
    echo   jp list             - List all saved directories
    echo   jp remove web       - Remove a specific directory
    echo   jp clean            - Interactive cleanup ^(select what to remove^)
    exit /b
)

if /i "%~1"=="add" (
    if "%~2"=="" (
        echo Error: Please provide a name for this directory
        exit /b 1
    )
    REM Handle "." as current directory
    if "%~3"=="." (
        echo Adding current directory as '%~2'
        >>"%JUMPLIST%" echo %~2=%CD%
        echo Added '%~2' = '%CD%'
        exit /b
    )
    if "%~3"=="" (
        echo Adding current directory as '%~2'
        >>"%JUMPLIST%" echo %~2=%CD%
        echo Added '%~2' = '%CD%'
    ) else (
        if exist "%~3\" (
            >>"%JUMPLIST%" echo %~2=%~3
            echo Added '%~2' = '%~3'
        ) else (
            echo Error: Directory '%~3' does not exist
            exit /b 1
        )
    )
    exit /b
)

if /i "%~1"=="list" (
    if not exist "%JUMPLIST%" (
        echo No directories saved yet. Use 'jp add [name] [path]' to add one.
        exit /b
    )
    echo Saved directories:
    echo.
    for /f "usebackq tokens=1,* delims==" %%a in ("%JUMPLIST%") do (
        echo   %%a = %%b
    )
    exit /b
)

if /i "%~1"=="remove" (
    if "%~2"=="" (
        echo Error: Please specify which directory to remove
        exit /b 1
    )
    if not exist "%JUMPLIST%" (
        echo No directories saved yet.
        exit /b 1
    )
    set "TEMP_FILE=%TEMP%\jumplist_temp.txt"
    set "FOUND=0"
    (for /f "usebackq tokens=1,* delims==" %%a in ("%JUMPLIST%") do (
        if /i not "%%a"=="%~2" (
            echo %%a=%%b
        ) else (
            set "FOUND=1"
        )
    )) > "!TEMP_FILE!"
    if "!FOUND!"=="1" (
        move /y "!TEMP_FILE!" "%JUMPLIST%" >nul
        echo Removed '%~2'
    ) else (
        del "!TEMP_FILE!" >nul
        echo Error: '%~2' not found
        exit /b 1
    )
    exit /b
)

if /i "%~1"=="clean" (
    if not exist "%JUMPLIST%" if not exist "%PREVIOUS%" (
        echo No directories saved yet.
        exit /b
    )
    if exist "%JUMPLIST%" del "%JUMPLIST%"
    if exist "%PREVIOUS%" del "%PREVIOUS%"
    echo All shortcuts removed.
    exit /b
)

REM Handle "jp -" to go to previous directory
if "%~1"=="-" goto :jump_previous

REM Jump to saved directory
goto :jump_to

:jump_previous
if not exist "%PREVIOUS%" (
    echo No previous directory. Jump somewhere first!
    exit /b 1
)

REM Read previous directory
set /p PREV_DIR=<"%PREVIOUS%"

if not defined PREV_DIR (
    echo No previous directory saved.
    exit /b 1
)

REM Save current directory before jumping
set "CURRENT_DIR=%CD%"

REM Get current drive and target drive
set "CURRENT_DRIVE=%CD:~0,2%"
set "TARGET_DRIVE=!PREV_DIR:~0,2!"

REM Check if crossing drives
if /i not "!CURRENT_DRIVE!"=="!TARGET_DRIVE!" (
    echo Switching from !CURRENT_DRIVE! to !TARGET_DRIVE!
)

REM Save the directory we just came from as the new previous
>"%PREVIOUS%" echo !CURRENT_DIR!

REM Jump to previous directory - endlocal so cd persists after script exits
endlocal & cd /d "%PREV_DIR%"
if errorlevel 1 (
    echo Error: Failed to jump to previous directory
    echo Directory may not exist or is inaccessible
    exit /b 1
)
echo Jumped back to: %CD%
exit /b

:jump_to
if not exist "%JUMPLIST%" (
    echo No directories saved yet. Use 'jp add [name] [path]' to add one.
    exit /b 1
)

set "FOUND="
for /f "usebackq tokens=1,* delims==" %%a in ("%JUMPLIST%") do (
    if /i "%%a"=="%~1" (
        set "FOUND=%%b"
    )
)

if not defined FOUND (
    echo Error: No directory saved as '%~1'
    echo Run 'jp list' to see available shortcuts
    exit /b 1
)

REM Save current directory as previous before jumping
>"%PREVIOUS%" echo %CD%

REM Get current drive and target drive
set "CURRENT_DRIVE=%CD:~0,2%"
set "TARGET_DRIVE=!FOUND:~0,2!"

REM Check if crossing drives
if /i not "!CURRENT_DRIVE!"=="!TARGET_DRIVE!" (
    echo Switching from !CURRENT_DRIVE! to !TARGET_DRIVE!
)

REM Change directory - endlocal so cd persists after script exits
endlocal & cd /d "%FOUND%"
if errorlevel 1 (
    echo Error: Failed to jump to directory
    echo Directory may not exist or is inaccessible
    exit /b 1
)
echo Jumped to: %CD%
exit /b
