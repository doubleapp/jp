@echo off
setlocal enabledelayedexpansion

REM ============================================================================
REM E2E Tests for jp.bat - Directory Jumper
REM Uses temp directories for complete test isolation
REM ============================================================================

set "PASS=0"
set "FAIL=0"
set "TOTAL=0"

REM Create temp test directory with unique name
set "TEST_DIR=%TEMP%\jp_e2e_test_%RANDOM%"
mkdir "%TEST_DIR%"
mkdir "%TEST_DIR%\dir_a"
mkdir "%TEST_DIR%\dir_b"
mkdir "%TEST_DIR%\dir_c"
mkdir "%TEST_DIR%\dir_d"
mkdir "%TEST_DIR%\output"

REM Set isolated data file paths
set "JP_JUMPLIST=%TEST_DIR%\.jump_directories"
set "JP_PREVIOUS=%TEST_DIR%\.jump_previous"

REM Path to jp.bat under test
set "JP=%~dp0jp.bat"
set "OUT=%TEST_DIR%\output\out.txt"

echo ========================================
echo  JP.BAT E2E Test Suite
echo ========================================
echo  Test dir: %TEST_DIR%
echo ========================================
echo.

REM -------------------------------------------------------
REM Test 1: No arguments shows usage
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" > "%OUT%" 2>&1
findstr /C:"Usage:" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 1: No arguments shows usage
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 1: No arguments shows usage
)

REM -------------------------------------------------------
REM Test 2: Add shortcut with explicit path
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" add testa "%TEST_DIR%\dir_a" > "%OUT%" 2>&1
findstr /C:"Added" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 2: Add shortcut with explicit path
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 2: Add shortcut with explicit path
)

REM -------------------------------------------------------
REM Test 3: List shows the added shortcut
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"testa" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 3: List shows added shortcut
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 3: List shows added shortcut
)

REM -------------------------------------------------------
REM Test 4: Add second shortcut
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" add testb "%TEST_DIR%\dir_b" > "%OUT%" 2>&1
findstr /C:"Added" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 4: Add second shortcut
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 4: Add second shortcut
)

REM -------------------------------------------------------
REM Test 5: List shows multiple shortcuts
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"testa" "%OUT%" >nul 2>&1
set "F1=!errorlevel!"
findstr /C:"testb" "%OUT%" >nul 2>&1
set "F2=!errorlevel!"
set "R=PASS"
if not !F1!==0 set "R=FAIL"
if not !F2!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 5: List shows multiple shortcuts
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 5: List shows multiple shortcuts
)

REM -------------------------------------------------------
REM Test 6: Jump changes directory
REM -------------------------------------------------------
set /a TOTAL+=1
cd /d "%TEST_DIR%"
call "%JP%" testa > "%OUT%" 2>&1
if /i "%CD%"=="%TEST_DIR%\dir_a" (
    set /a PASS+=1
    echo   [PASS] Test 6: Jump changes directory
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 6: Jump changes directory - expected dir_a got %CD%
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 7: Jump saves previous directory
REM -------------------------------------------------------
set /a TOTAL+=1
cd /d "%TEST_DIR%\dir_c"
call "%JP%" testa > "%OUT%" 2>&1
set "R=FAIL"
if exist "%JP_PREVIOUS%" (
    set /p PREV_CHECK=<"%JP_PREVIOUS%"
    if /i "!PREV_CHECK!"=="%TEST_DIR%\dir_c" set "R=PASS"
)
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 7: Jump saves previous directory
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 7: Jump saves previous directory
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 8: Previous directory toggle
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add testa "%TEST_DIR%\dir_a" > nul 2>&1
cd /d "%TEST_DIR%\dir_c"
call "%JP%" testa > nul 2>&1
REM Now at dir_a, previous is dir_c
call "%JP%" - > "%OUT%" 2>&1
if /i "%CD%"=="%TEST_DIR%\dir_c" (
    set /a PASS+=1
    echo   [PASS] Test 8: Previous directory toggle
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 8: Previous directory toggle - got %CD%
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 9: Double toggle returns to original
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add testa "%TEST_DIR%\dir_a" > nul 2>&1
cd /d "%TEST_DIR%\dir_c"
call "%JP%" testa > nul 2>&1
call "%JP%" - > nul 2>&1
call "%JP%" - > nul 2>&1
if /i "%CD%"=="%TEST_DIR%\dir_a" (
    set /a PASS+=1
    echo   [PASS] Test 9: Double toggle returns to original
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 9: Double toggle returns - got %CD%
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 10: Add current directory - no path arg
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
cd /d "%TEST_DIR%\dir_c"
call "%JP%" add testcur > "%OUT%" 2>&1
findstr /C:"Adding current directory" "%OUT%" >nul 2>&1
set "F1=!errorlevel!"
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"dir_c" "%OUT%" >nul 2>&1
set "F2=!errorlevel!"
set "R=PASS"
if not !F1!==0 set "R=FAIL"
if not !F2!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 10: Add current directory - no path
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 10: Add current directory - no path
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 11: Add current directory with dot syntax
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
cd /d "%TEST_DIR%\dir_d"
call "%JP%" add testdot . > "%OUT%" 2>&1
findstr /C:"Adding current directory" "%OUT%" >nul 2>&1
set "F1=!errorlevel!"
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"dir_d" "%OUT%" >nul 2>&1
set "F2=!errorlevel!"
set "R=PASS"
if not !F1!==0 set "R=FAIL"
if not !F2!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 11: Add current directory with dot syntax
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 11: Add current directory with dot syntax
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 12: Remove shortcut
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" add rmtest "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" remove rmtest > "%OUT%" 2>&1
findstr /C:"Removed" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 12: Remove shortcut
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 12: Remove shortcut
)

REM -------------------------------------------------------
REM Test 13: Removed shortcut no longer in list
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" add keepme "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" add delme "%TEST_DIR%\dir_b" > nul 2>&1
call "%JP%" remove delme > nul 2>&1
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"keepme" "%OUT%" >nul 2>&1
set "F1=!errorlevel!"
findstr /C:"delme" "%OUT%" >nul 2>&1
set "F2=!errorlevel!"
set "R=PASS"
if not !F1!==0 set "R=FAIL"
if !F2!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 13: Removed shortcut gone from list
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 13: Removed shortcut gone from list
)

REM -------------------------------------------------------
REM Test 14: Error - add without name
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" add > "%OUT%" 2>&1
findstr /C:"Error" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 14: Error on add without name
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 14: Error on add without name
)

REM -------------------------------------------------------
REM Test 15: Error - add with nonexistent path
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" add badpath "%TEST_DIR%\nonexistent_dir_xyz" > "%OUT%" 2>&1
findstr /C:"Error" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 15: Error on add with nonexistent path
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 15: Error on add with nonexistent path
)

REM -------------------------------------------------------
REM Test 16: Error - jump to unknown shortcut
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" add dummy "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" nosuchname > "%OUT%" 2>&1
findstr /C:"Error" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 16: Error on jump to unknown shortcut
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 16: Error on jump to unknown shortcut
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 17: Error - remove unknown shortcut
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" add dummy "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" remove nosuchname > "%OUT%" 2>&1
findstr /C:"not found" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 17: Error on remove unknown shortcut
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 17: Error on remove unknown shortcut
)

REM -------------------------------------------------------
REM Test 18: Error - remove without name
REM -------------------------------------------------------
set /a TOTAL+=1
call "%JP%" remove > "%OUT%" 2>&1
findstr /C:"Error" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 18: Error on remove without name
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 18: Error on remove without name
)

REM -------------------------------------------------------
REM Test 19: Error - list when no shortcuts file
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"No directories saved" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 19: List when no shortcuts exist
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 19: List when no shortcuts exist
)

REM -------------------------------------------------------
REM Test 20: Error - jump when no shortcuts file
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" anything > "%OUT%" 2>&1
findstr /C:"No directories saved" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 20: Jump when no shortcuts file
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 20: Jump when no shortcuts file
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 21: Error - previous with no history
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_PREVIOUS%" 2>nul
call "%JP%" - > "%OUT%" 2>&1
findstr /C:"No previous" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 21: Previous with no history
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 21: Previous with no history
)

REM -------------------------------------------------------
REM Test 22: Case-insensitive shortcut names
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add MyTest "%TEST_DIR%\dir_a" > nul 2>&1
cd /d "%TEST_DIR%"
call "%JP%" mytest > "%OUT%" 2>&1
if /i "%CD%"=="%TEST_DIR%\dir_a" (
    set /a PASS+=1
    echo   [PASS] Test 22: Case-insensitive shortcut names
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 22: Case-insensitive shortcut names
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 23: Case-insensitive commands
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" ADD citest "%TEST_DIR%\dir_b" > "%OUT%" 2>&1
findstr /C:"Added" "%OUT%" >nul 2>&1
set "F1=!errorlevel!"
call "%JP%" LIST > "%OUT%" 2>&1
findstr /C:"citest" "%OUT%" >nul 2>&1
set "F2=!errorlevel!"
call "%JP%" REMOVE citest > "%OUT%" 2>&1
findstr /C:"Removed" "%OUT%" >nul 2>&1
set "F3=!errorlevel!"
set "R=PASS"
if not !F1!==0 set "R=FAIL"
if not !F2!==0 set "R=FAIL"
if not !F3!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 23: Case-insensitive commands
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 23: Case-insensitive commands
)

REM -------------------------------------------------------
REM Test 24: Jump output includes target path
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add jout "%TEST_DIR%\dir_a" > nul 2>&1
cd /d "%TEST_DIR%"
call "%JP%" jout > "%OUT%" 2>&1
findstr /C:"Jumped to:" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 24: Jump output includes target path
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 24: Jump output includes target path
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 25: Previous output includes target path
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add pout "%TEST_DIR%\dir_b" > nul 2>&1
cd /d "%TEST_DIR%\dir_c"
call "%JP%" pout > nul 2>&1
call "%JP%" - > "%OUT%" 2>&1
findstr /C:"Jumped back to:" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 25: Previous output includes target path
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 25: Previous output includes target path
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 26: Overwrite shortcut by adding same name
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add ow "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" add ow "%TEST_DIR%\dir_b" > nul 2>&1
cd /d "%TEST_DIR%"
call "%JP%" ow > "%OUT%" 2>&1
if /i "%CD%"=="%TEST_DIR%\dir_b" (
    set /a PASS+=1
    echo   [PASS] Test 26: Last added shortcut wins on duplicate
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 26: Last added shortcut wins - got %CD%
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 27: Clean removes all shortcuts
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" add cl1 "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" add cl2 "%TEST_DIR%\dir_b" > nul 2>&1
call "%JP%" clean > "%OUT%" 2>&1
findstr /C:"All shortcuts removed" "%OUT%" >nul 2>&1
set "F1=!errorlevel!"
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"No directories saved" "%OUT%" >nul 2>&1
set "F2=!errorlevel!"
set "R=PASS"
if not !F1!==0 set "R=FAIL"
if not !F2!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 27: Clean removes all shortcuts
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 27: Clean removes all shortcuts
)

REM -------------------------------------------------------
REM Test 28: Clean with no shortcuts file
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" clean > "%OUT%" 2>&1
findstr /C:"No directories saved" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 28: Clean with no shortcuts
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 28: Clean with no shortcuts
)

REM -------------------------------------------------------
REM Test 29: Remove last shortcut clears list
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
call "%JP%" add onlyone "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" remove onlyone > nul 2>&1
call "%JP%" list > "%OUT%" 2>&1
findstr /C:"onlyone" "%OUT%" >nul 2>&1
if !errorlevel!==1 (
    set /a PASS+=1
    echo   [PASS] Test 29: Remove last shortcut clears list
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 29: Remove last shortcut clears list
)

REM -------------------------------------------------------
REM Test 30: Clean also removes previous directory file
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add cl1 "%TEST_DIR%\dir_a" > nul 2>&1
cd /d "%TEST_DIR%\dir_c"
call "%JP%" cl1 > nul 2>&1
cd /d "%TEST_DIR%"
REM Verify .jump_previous was created
set "R=PASS"
if not exist "%JP_PREVIOUS%" set "R=FAIL"
REM Now clean
call "%JP%" clean > "%OUT%" 2>&1
if exist "%JP_JUMPLIST%" set "R=FAIL"
if exist "%JP_PREVIOUS%" set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 30: Clean also removes previous directory file
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 30: Clean also removes previous directory file
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 31: After clean, jp - shows no previous directory
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add cl1 "%TEST_DIR%\dir_a" > nul 2>&1
cd /d "%TEST_DIR%\dir_c"
call "%JP%" cl1 > nul 2>&1
cd /d "%TEST_DIR%"
call "%JP%" clean > nul 2>&1
call "%JP%" - > "%OUT%" 2>&1
findstr /C:"No previous" "%OUT%" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 31: After clean, jp - shows no previous
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 31: After clean, jp - shows no previous
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 32: Add dot stores exact current directory path
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
cd /d "%TEST_DIR%\dir_a"
call "%JP%" add dotexact . > nul 2>&1
set "R=PASS"
findstr /C:"dotexact=%TEST_DIR%\dir_a" "%JP_JUMPLIST%" >nul 2>&1
if not !errorlevel!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 32: Add dot stores exact current directory path
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 32: Add dot stores exact current directory path
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 33: Add dot with path ending in digit
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
mkdir "%TEST_DIR%\dir1" 2>nul
cd /d "%TEST_DIR%\dir1"
call "%JP%" add digitdir . > nul 2>&1
set "R=PASS"
findstr /C:"digitdir=%TEST_DIR%\dir1" "%JP_JUMPLIST%" >nul 2>&1
if not !errorlevel!==0 set "R=FAIL"
if "!R!"=="PASS" (
    set /a PASS+=1
    echo   [PASS] Test 33: Add dot with path ending in digit
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 33: Add dot with path ending in digit
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 34: Sequential jumps work correctly
REM -------------------------------------------------------
set /a TOTAL+=1
del "%JP_JUMPLIST%" 2>nul
del "%JP_PREVIOUS%" 2>nul
call "%JP%" add seqa "%TEST_DIR%\dir_a" > nul 2>&1
call "%JP%" add seqb "%TEST_DIR%\dir_b" > nul 2>&1
cd /d "%TEST_DIR%"
call "%JP%" seqa > nul 2>&1
call "%JP%" seqb > nul 2>&1
if /i "%CD%"=="%TEST_DIR%\dir_b" (
    set /a PASS+=1
    echo   [PASS] Test 34: Sequential jumps work correctly
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 34: Sequential jumps - got %CD%
)
cd /d "%TEST_DIR%"

REM -------------------------------------------------------
REM Test 35: Clink completion script exists
REM -------------------------------------------------------
set /a TOTAL+=1
if exist "%~dp0jp_clink.lua" (
    set /a PASS+=1
    echo   [PASS] Test 35: Clink completion script exists
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 35: Clink completion script exists
)

REM -------------------------------------------------------
REM Test 36: Clink script references jump_directories
REM -------------------------------------------------------
set /a TOTAL+=1
findstr /C:".jump_directories" "%~dp0jp_clink.lua" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 36: Clink script references jump_directories
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 36: Clink script references jump_directories
)

REM -------------------------------------------------------
REM Test 37: Clink script has argmatcher for jp
REM -------------------------------------------------------
set /a TOTAL+=1
findstr /C:"argmatcher" "%~dp0jp_clink.lua" >nul 2>&1
if !errorlevel!==0 (
    set /a PASS+=1
    echo   [PASS] Test 37: Clink script has argmatcher for jp
) else (
    set /a FAIL+=1
    echo   [FAIL] Test 37: Clink script has argmatcher for jp
)

REM ========================================
REM Summary
REM ========================================
echo.
echo ========================================
echo  Results: !PASS!/!TOTAL! passed, !FAIL! failed
echo ========================================

REM Cleanup temp directory
cd /d "%TEMP%"
rmdir /S /Q "%TEST_DIR%" 2>nul

if !FAIL! GTR 0 (
    echo.
    echo  SOME TESTS FAILED
    exit /b 1
) else (
    echo.
    echo  ALL TESTS PASSED
    exit /b 0
)
