# ============================================================================
# E2E Tests for jp.ps1 - Directory Jumper (PowerShell version)
# Uses temp directories for complete test isolation
# ============================================================================

$ErrorActionPreference = "Continue"
$InformationPreference = "Continue"
$pass = 0
$fail = 0
$total = 0

# Create temp test directory
$testDir = Join-Path $env:TEMP "jp_ps_e2e_test_$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
New-Item -ItemType Directory -Path "$testDir\dir_a" -Force | Out-Null
New-Item -ItemType Directory -Path "$testDir\dir_b" -Force | Out-Null
New-Item -ItemType Directory -Path "$testDir\dir_c" -Force | Out-Null
New-Item -ItemType Directory -Path "$testDir\dir_d" -Force | Out-Null

# Set isolated data file paths
$env:JP_JUMPLIST = Join-Path $testDir ".jump_directories"
$env:JP_PREVIOUS = Join-Path $testDir ".jump_previous"

$jpScript = Join-Path $PSScriptRoot "jp.ps1"

# Helper: capture all output streams including Write-Host (Information stream)
function Capture-JP {
    param([string[]]$Arguments)
    $result = & $jpScript @Arguments *>&1 | Out-String
    return $result
}

function Assert-Pass {
    param([string]$Name, [bool]$Condition)
    $script:total++
    if ($Condition) {
        $script:pass++
        Write-Host "  [PASS] $Name"
    } else {
        $script:fail++
        Write-Host "  [FAIL] $Name" -ForegroundColor Red
    }
}

Write-Host "========================================"
Write-Host " JP.PS1 E2E Test Suite"
Write-Host "========================================"
Write-Host " Test dir: $testDir"
Write-Host "========================================"
Write-Host ""

# Save original location
$originalDir = Get-Location

# ------- Test 1: No arguments shows usage -------
$out = Capture-JP
Assert-Pass "Test 1: No arguments shows usage" ($out -match "Usage:")

# ------- Test 2: Add shortcut with explicit path -------
$out = Capture-JP add, testa, "$testDir\dir_a"
Assert-Pass "Test 2: Add shortcut with explicit path" ($out -match "Added")

# ------- Test 3: List shows added shortcut -------
$out = Capture-JP list
Assert-Pass "Test 3: List shows added shortcut" ($out -match "testa")

# ------- Test 4: Add second shortcut -------
$out = Capture-JP add, testb, "$testDir\dir_b"
Assert-Pass "Test 4: Add second shortcut" ($out -match "Added")

# ------- Test 5: List shows multiple shortcuts -------
$out = Capture-JP list
Assert-Pass "Test 5: List shows multiple shortcuts" (($out -match "testa") -and ($out -match "testb"))

# ------- Test 6: Add current directory (no path) -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Set-Location "$testDir\dir_c"
$out = Capture-JP add, testcur
$list = Capture-JP list
Assert-Pass "Test 6: Add current directory (no path)" (($out -match "Adding current directory") -and ($list -match "dir_c"))
Set-Location $originalDir

# ------- Test 7: Add current directory with dot -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Set-Location "$testDir\dir_d"
$out = Capture-JP add, testdot, "."
$list = Capture-JP list
Assert-Pass "Test 7: Add current directory with dot" (($out -match "Adding current directory") -and ($list -match "dir_d"))
Set-Location $originalDir

# ------- Test 8: Remove shortcut -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
& $jpScript add rmtest "$testDir\dir_a" *>&1 | Out-Null
$out = Capture-JP remove, rmtest
Assert-Pass "Test 8: Remove shortcut" ($out -match "Removed")

# ------- Test 9: Removed shortcut gone from list -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
& $jpScript add keepme "$testDir\dir_a" *>&1 | Out-Null
& $jpScript add delme "$testDir\dir_b" *>&1 | Out-Null
& $jpScript remove delme *>&1 | Out-Null
$list = Capture-JP list
Assert-Pass "Test 9: Removed shortcut gone from list" (($list -match "keepme") -and ($list -notmatch "delme"))

# ------- Test 10: Error - add without name -------
$out = Capture-JP add
Assert-Pass "Test 10: Error on add without name" ($out -match "Error")

# ------- Test 11: Error - add with nonexistent path -------
$out = Capture-JP add, badpath, "$testDir\nonexistent_xyz"
Assert-Pass "Test 11: Error on add with nonexistent path" ($out -match "Error")

# ------- Test 12: Error - jump to unknown shortcut -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
& $jpScript add dummy "$testDir\dir_a" *>&1 | Out-Null
$out = Capture-JP nosuchname
Assert-Pass "Test 12: Error on jump to unknown shortcut" ($out -match "Error")

# ------- Test 13: Error - remove unknown shortcut -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
& $jpScript add dummy "$testDir\dir_a" *>&1 | Out-Null
$out = Capture-JP remove, nosuchname
Assert-Pass "Test 13: Error on remove unknown shortcut" ($out -match "not found")

# ------- Test 14: Error - remove without name -------
$out = Capture-JP remove
Assert-Pass "Test 14: Error on remove without name" ($out -match "Error")

# ------- Test 15: List when no shortcuts file -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
$out = Capture-JP list
Assert-Pass "Test 15: List when no shortcuts exist" ($out -match "No directories saved")

# ------- Test 16: Jump when no shortcuts file -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
$out = Capture-JP anything
Assert-Pass "Test 16: Jump when no shortcuts file" ($out -match "No directories saved")

# ------- Test 17: Previous with no history -------
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
$out = Capture-JP "-"
Assert-Pass "Test 17: Previous with no history" ($out -match "No previous")

# ------- Test 18: Jump changes directory (dot-sourced) -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add jmptest "$testDir\dir_a" *>&1 | Out-Null
Set-Location $testDir
. $jpScript jmptest *>&1 | Out-Null
$curDir = (Get-Location).Path
Assert-Pass "Test 18: Jump changes directory (dot-sourced)" ($curDir -eq "$testDir\dir_a")
Set-Location $originalDir

# ------- Test 19: Previous directory toggle (dot-sourced) -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add prevtest "$testDir\dir_b" *>&1 | Out-Null
Set-Location "$testDir\dir_c"
. $jpScript prevtest *>&1 | Out-Null
. $jpScript "-" *>&1 | Out-Null
$curDir = (Get-Location).Path
Assert-Pass "Test 19: Previous directory toggle (dot-sourced)" ($curDir -eq "$testDir\dir_c")
Set-Location $originalDir

# ------- Test 20: Double toggle returns (dot-sourced) -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add dttest "$testDir\dir_a" *>&1 | Out-Null
Set-Location "$testDir\dir_c"
. $jpScript dttest *>&1 | Out-Null
. $jpScript "-" *>&1 | Out-Null
. $jpScript "-" *>&1 | Out-Null
$curDir = (Get-Location).Path
Assert-Pass "Test 20: Double toggle returns to original (dot-sourced)" ($curDir -eq "$testDir\dir_a")
Set-Location $originalDir

# ------- Test 21: Case-insensitive commands -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
$out1 = Capture-JP ADD, citest, "$testDir\dir_b"
$out2 = Capture-JP LIST
$out3 = Capture-JP REMOVE, citest
Assert-Pass "Test 21: Case-insensitive commands" (($out1 -match "Added") -and ($out2 -match "citest") -and ($out3 -match "Removed"))

# ------- Test 22: Jump output includes target path -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add jout "$testDir\dir_a" *>&1 | Out-Null
$out = Capture-JP jout
Assert-Pass "Test 22: Jump output includes 'Jumped to'" ($out -match "Jumped to:")

# ------- Test 23: Clean removes all shortcuts -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
& $jpScript add cl1 "$testDir\dir_a" *>&1 | Out-Null
& $jpScript add cl2 "$testDir\dir_b" *>&1 | Out-Null
$out = Capture-JP clean
$list = Capture-JP list
Assert-Pass "Test 23: Clean removes all shortcuts" (($out -match "All shortcuts removed") -and ($list -match "No directories saved"))

# ------- Test 23b: Clean with no shortcuts -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
$out = Capture-JP clean
Assert-Pass "Test 23b: Clean with no shortcuts" ($out -match "No directories saved")

# ------- Test 24: Sequential jumps (dot-sourced) -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add seqa "$testDir\dir_a" *>&1 | Out-Null
& $jpScript add seqb "$testDir\dir_b" *>&1 | Out-Null
Set-Location $testDir
. $jpScript seqa *>&1 | Out-Null
. $jpScript seqb *>&1 | Out-Null
$curDir = (Get-Location).Path
Assert-Pass "Test 24: Sequential jumps work correctly" ($curDir -eq "$testDir\dir_b")
Set-Location $originalDir

# ------- Test 25: Clean also removes previous directory file -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add cl1 "$testDir\dir_a" *>&1 | Out-Null
Set-Location $testDir
. $jpScript cl1 *>&1 | Out-Null
Set-Location $originalDir
# Verify .jump_previous was created
$prevExists = Test-Path $env:JP_PREVIOUS
& $jpScript clean *>&1 | Out-Null
$jumplistGone = -not (Test-Path $env:JP_JUMPLIST)
$previousGone = -not (Test-Path $env:JP_PREVIOUS)
Assert-Pass "Test 25: Clean also removes previous directory file" ($prevExists -and $jumplistGone -and $previousGone)

# ------- Test 26: After clean, jp - shows no previous -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Remove-Item $env:JP_PREVIOUS -ErrorAction SilentlyContinue
& $jpScript add cl1 "$testDir\dir_a" *>&1 | Out-Null
Set-Location $testDir
. $jpScript cl1 *>&1 | Out-Null
Set-Location $originalDir
& $jpScript clean *>&1 | Out-Null
$out = Capture-JP "-"
Assert-Pass "Test 26: After clean, jp - shows no previous" ($out -match "No previous")

# ------- Test 27: Add dot stores exact current directory path -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
Set-Location "$testDir\dir_a"
& $jpScript add dotexact . *>&1 | Out-Null
$content = Get-Content $env:JP_JUMPLIST -Raw
$expected = "dotexact=$testDir\dir_a"
Assert-Pass "Test 27: Add dot stores exact current directory path" ($content -match [regex]::Escape($expected))
Set-Location $originalDir

# ------- Test 28: Remove last shortcut clears list -------
Remove-Item $env:JP_JUMPLIST -ErrorAction SilentlyContinue
& $jpScript add onlyone "$testDir\dir_a" *>&1 | Out-Null
& $jpScript remove onlyone *>&1 | Out-Null
$list = Capture-JP list
Assert-Pass "Test 28: Remove last shortcut clears list" ($list -notmatch "onlyone")

# ========================================
# Summary
# ========================================
Write-Host ""
Write-Host "========================================"
Write-Host " Results: $pass/$total passed, $fail failed"
Write-Host "========================================"

# Cleanup
Set-Location $originalDir
Remove-Item $testDir -Recurse -Force -ErrorAction SilentlyContinue
$env:JP_JUMPLIST = $null
$env:JP_PREVIOUS = $null

if ($fail -gt 0) {
    Write-Host ""
    Write-Host " SOME TESTS FAILED" -ForegroundColor Red
    exit 1
} else {
    Write-Host ""
    Write-Host " ALL TESTS PASSED" -ForegroundColor Green
    exit 0
}
