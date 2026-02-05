@echo off
echo ============================================================================
echo JP "." Syntax Test - Add Current Directory
echo ============================================================================
echo.

REM Check if jp is available
where jp >nul 2>&1
if errorlevel 1 (
    echo ERROR: jp command not found. Please run install.bat first.
    pause
    exit /b 1
)

echo Current directory: %CD%
echo.

echo Testing different ways to add current directory...
echo.

echo [Test 1] Using "jp add test-dot ."
jp add test-dot .
echo.

echo [Test 2] Using "jp add test-nodot" (no path)
jp add test-nodot
echo.

echo [Test 3] Listing all shortcuts...
jp list
echo.

echo [Test 4] Jumping to first shortcut...
jp test-dot
echo.

echo Cleaning up test shortcuts...
jp remove test-dot
jp remove test-nodot
echo.

echo ============================================================================
echo Test completed!
echo ============================================================================
echo.
echo Both syntaxes work:
echo   - jp add name .     (explicit dot)
echo   - jp add name       (omit path)
echo.
pause
