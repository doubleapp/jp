# JP - Directory Jumper (PowerShell version with Tab Completion)
[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$Command,

    [Parameter(Position=1)]
    [string]$Name,

    [Parameter(Position=2)]
    [string]$Path
)

$script:JUMPLIST = if ($env:JP_JUMPLIST) { $env:JP_JUMPLIST } else { Join-Path $env:USERPROFILE ".jump_directories" }
$script:PREVIOUS = if ($env:JP_PREVIOUS) { $env:JP_PREVIOUS } else { Join-Path $env:USERPROFILE ".jump_previous" }

function Get-SavedShortcuts {
    if (-not (Test-Path $script:JUMPLIST)) {
        return @{}
    }

    $shortcuts = @{}
    Get-Content $script:JUMPLIST | ForEach-Object {
        if ($_ -match '^(.+?)=(.+)$') {
            $shortcuts[$matches[1]] = $matches[2]
        }
    }
    return $shortcuts
}

function Show-Usage {
    Write-Host "Usage: jp [name|add|list|remove|clean|-]"
    Write-Host ""
    Write-Host "Examples:"
    Write-Host "  jp add web e:\EProjects\doubletap\storewebsite"
    Write-Host "  jp add here .       - Add current directory"
    Write-Host "  jp web              - Jump to saved directory"
    Write-Host "  jp -                - Jump to previous directory (toggle back/forth)"
    Write-Host "  jp list             - List all saved directories"
    Write-Host "  jp remove web       - Remove a specific directory"
    Write-Host "  jp clean            - Interactive cleanup"
    Write-Host ""
    Write-Host "Tab Completion: Type 'jp ' and press TAB to cycle through shortcuts"
}

function Add-Shortcut {
    param($Name, $Path)

    if (-not $Name) {
        Write-Host "Error: Please provide a name for this directory" -ForegroundColor Red
        return
    }

    # Handle "." as current directory
    if ($Path -eq ".") {
        $Path = Get-Location
        Write-Host "Adding current directory as '$Name'"
    }

    if (-not $Path) {
        $Path = Get-Location
        Write-Host "Adding current directory as '$Name'"
    }

    # Resolve to full path
    $Path = (Resolve-Path -Path $Path -ErrorAction SilentlyContinue).Path
    if (-not $Path) {
        Write-Host "Error: Directory does not exist" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $Path)) {
        Write-Host "Error: Directory '$Path' does not exist" -ForegroundColor Red
        return
    }

    "$Name=$Path" | Add-Content $script:JUMPLIST
    Write-Host "Added '$Name' = '$Path'" -ForegroundColor Green
}

function Remove-Shortcut {
    param($Name)

    if (-not $Name) {
        Write-Host "Error: Please specify which directory to remove" -ForegroundColor Red
        return
    }

    if (-not (Test-Path $script:JUMPLIST)) {
        Write-Host "No directories saved yet." -ForegroundColor Yellow
        return
    }

    $shortcuts = Get-SavedShortcuts
    if ($shortcuts.ContainsKey($Name)) {
        $shortcuts.Remove($Name)
        if ($shortcuts.Count -eq 0) {
            Remove-Item $script:JUMPLIST -ErrorAction SilentlyContinue
        } else {
            $shortcuts.GetEnumerator() | ForEach-Object { "$($_.Key)=$($_.Value)" } | Set-Content $script:JUMPLIST
        }
        Write-Host "Removed '$Name'" -ForegroundColor Green
    } else {
        Write-Host "Error: '$Name' not found" -ForegroundColor Red
        Write-Host "Run 'jp list' to see available shortcuts"
    }
}

function Show-Shortcuts {
    if (-not (Test-Path $script:JUMPLIST)) {
        Write-Host "No directories saved yet. Use 'jp add [name] [path]' to add one." -ForegroundColor Yellow
        return
    }

    Write-Host "Saved directories:" -ForegroundColor Cyan
    Write-Host ""
    (Get-SavedShortcuts).GetEnumerator() | Sort-Object Key | ForEach-Object {
        Write-Host "  $($_.Key) = $($_.Value)"
    }
}

function Invoke-Clean {
    $hasJumplist = Test-Path $script:JUMPLIST
    $hasPrevious = Test-Path $script:PREVIOUS

    if (-not $hasJumplist -and -not $hasPrevious) {
        Write-Host "No directories saved yet." -ForegroundColor Yellow
        return
    }

    if ($hasJumplist) { Remove-Item $script:JUMPLIST }
    if ($hasPrevious) { Remove-Item $script:PREVIOUS }
    Write-Host "All shortcuts removed." -ForegroundColor Green
    Write-Host ""
    Write-Host "Cleanup complete!" -ForegroundColor Green
}

function Invoke-JumpPrevious {
    if (-not (Test-Path $script:PREVIOUS)) {
        Write-Host "No previous directory. Jump somewhere first!" -ForegroundColor Yellow
        return
    }

    $prevDir = Get-Content $script:PREVIOUS -Raw
    $prevDir = $prevDir.Trim()

    if (-not $prevDir) {
        Write-Host "No previous directory saved." -ForegroundColor Yellow
        return
    }

    # Save current directory before jumping
    $currentDir = Get-Location

    # Get current and target drives
    $currentDrive = $currentDir.Drive.Name + ":"
    $targetDrive = $prevDir.Substring(0, 2)

    # Check if crossing drives
    if ($currentDrive -ne $targetDrive) {
        Write-Host "Switching from $currentDrive to $targetDrive" -ForegroundColor Yellow
    }

    if (Test-Path $prevDir) {
        Set-Location $prevDir
        # Save the directory we just came from as the new previous
        $currentDir.Path | Set-Content $script:PREVIOUS
        Write-Host "Jumped back to: $prevDir" -ForegroundColor Green
    } else {
        Write-Host "Error: Previous directory no longer exists: $prevDir" -ForegroundColor Red
    }
}

function Invoke-Jump {
    param($Name)

    if (-not (Test-Path $script:JUMPLIST)) {
        Write-Host "No directories saved yet. Use 'jp add [name] [path]' to add one." -ForegroundColor Yellow
        return
    }

    $shortcuts = Get-SavedShortcuts
    if ($shortcuts.ContainsKey($Name)) {
        $targetPath = $shortcuts[$Name]

        # Save current directory as previous before jumping
        (Get-Location).Path | Set-Content $script:PREVIOUS

        # Get current and target drives
        $currentDrive = (Get-Location).Drive.Name + ":"
        $targetDrive = $targetPath.Substring(0, 2)

        # Check if crossing drives
        if ($currentDrive -ne $targetDrive) {
            Write-Host "Switching from $currentDrive to $targetDrive" -ForegroundColor Yellow
        }

        if (Test-Path $targetPath) {
            Set-Location $targetPath
            Write-Host "Jumped to: $targetPath" -ForegroundColor Green
        } else {
            Write-Host "Error: Directory no longer exists: $targetPath" -ForegroundColor Red
        }
    } else {
        Write-Host "Error: No directory saved as '$Name'" -ForegroundColor Red
        Write-Host "Run 'jp list' to see available shortcuts"
    }
}

# Main logic
if (-not $Command) {
    Show-Usage
    return
}

switch ($Command) {
    "-" { Invoke-JumpPrevious }
    {$_.ToLower() -eq "add"} { Add-Shortcut -Name $Name -Path $Path }
    {$_.ToLower() -eq "remove"} { Remove-Shortcut -Name $Name }
    {$_.ToLower() -eq "list"} { Show-Shortcuts }
    {$_.ToLower() -eq "clean"} { Invoke-Clean }
    default { Invoke-Jump -Name $Command }
}
