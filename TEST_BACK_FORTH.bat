@echo off
echo ============================================================================
echo JP "-" Command Test - Jump Back and Forth
echo ============================================================================
echo.

REM Check if jp is available
where jp >nul 2>&1
if errorlevel 1 (
    echo ERROR: jp command not found. Please run install.bat first.
    pause
    exit /b 1
)

echo Setting up test shortcuts...
jp add test-home C:\Users\%USERNAME%
jp add test-ep E:\EProjects
echo.

echo Starting from: %CD%
echo.

echo [Test 1] Jump to C:\Users\%USERNAME%
jp test-home
echo Current directory: %CD%
echo.
pause

echo [Test 2] Jump to E:\EProjects
jp test-ep
echo Current directory: %CD%
echo.
pause

echo [Test 3] Jump back with "jp -"
jp -
echo Current directory: %CD%
echo.
pause

echo [Test 4] Jump forward again with "jp -"
jp -
echo Current directory: %CD%
echo.
pause

echo [Test 5] Keep toggling with "jp -"
jp -
echo Current directory: %CD%
echo.
pause

echo Cleaning up test shortcuts...
jp remove test-home
jp remove test-ep
echo.

echo ============================================================================
echo Test completed!
echo ============================================================================
echo.
echo The "jp -" command lets you toggle between your last two locations!
echo Perfect for switching back and forth while working.
echo.
pause
