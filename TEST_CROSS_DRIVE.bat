@echo off
echo ============================================================================
echo JP Cross-Drive Navigation Test
echo ============================================================================
echo.
echo This script tests the cross-drive jumping functionality.
echo.

REM Check if jp is available
where jp >nul 2>&1
if errorlevel 1 (
    echo ERROR: jp command not found. Please run install.bat first.
    pause
    exit /b 1
)

echo Current directory: %CD%
echo Current drive: %CD:~0,2%
echo.

echo Setting up test shortcuts...
jp add test-c C:\Users\%USERNAME%
jp add test-e E:\EProjects\jp
echo.

echo Testing cross-drive navigation...
echo.

echo [Test 1] Jumping to C: drive...
jp test-c
echo.

echo [Test 2] Jumping to E: drive from C:...
jp test-e
echo.

echo [Test 3] Listing all shortcuts...
jp list
echo.

echo Cleaning up test shortcuts...
jp remove test-c
jp remove test-e
echo.

echo ============================================================================
echo Test completed!
echo ============================================================================
echo.
echo If you saw "Switching from X: to Y:" messages, the cross-drive
echo detection is working correctly!
echo.
pause
