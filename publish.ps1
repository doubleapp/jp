<#
.SYNOPSIS
    Publish JP Directory Jumper - GitHub Release and Scoop.
.DESCRIPTION
    Builds a release zip, creates a GitHub release via git tag + push,
    and publishes to Scoop bucket. Requires: git (with SSH).
.PARAMETER Target
    Where to publish: github, scoop, or all.
.PARAMETER Version
    Override version (e.g., "1.2.0"). If omitted, reads from version.txt.
.PARAMETER BumpType
    Auto-bump before publishing: major, minor, or patch.
.PARAMETER DryRun
    Show what would happen without making changes.
.EXAMPLE
    .\publish.ps1 -Target all -BumpType patch
    .\publish.ps1 -Target github -Version 2.0.0
    .\publish.ps1 -Target all -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("github", "scoop", "all")]
    [string]$Target,

    [string]$Version,

    [ValidateSet("major", "minor", "patch")]
    [string]$BumpType,

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$VersionFile = Join-Path $ScriptDir "version.txt"
$DistDir = Join-Path $ScriptDir "dist"
$Repo = "doubleapp/jp"

# --- Version helpers ---

function Get-CurrentVersion {
    if (-not (Test-Path $VersionFile)) {
        throw "version.txt not found at $VersionFile"
    }
    return (Get-Content $VersionFile -Raw).Trim()
}

function Step-Version {
    param([string]$Current, [string]$Bump)
    $parts = $Current.Split('.')
    switch ($Bump) {
        "major" { $parts[0] = [int]$parts[0] + 1; $parts[1] = "0"; $parts[2] = "0" }
        "minor" { $parts[1] = [int]$parts[1] + 1; $parts[2] = "0" }
        "patch" { $parts[2] = [int]$parts[2] + 1 }
    }
    return "$($parts[0]).$($parts[1]).$($parts[2])"
}

function Set-VersionFile {
    param([string]$NewVersion)
    "$NewVersion`n" | Set-Content $VersionFile -NoNewline
    Write-Host "  Updated version.txt to $NewVersion" -ForegroundColor Green
}

# --- Build helpers ---

function Build-ReleaseZip {
    param([string]$Ver)

    if (-not (Test-Path $DistDir)) { New-Item -ItemType Directory -Path $DistDir -Force | Out-Null }

    $zipName = "jp-$Ver.zip"
    $zipPath = Join-Path $DistDir $zipName
    $stagingDir = Join-Path $DistDir "jp-$Ver"

    if (Test-Path $stagingDir) { Remove-Item $stagingDir -Recurse -Force }
    if (Test-Path $zipPath) { Remove-Item $zipPath -Force }

    New-Item -ItemType Directory -Path $stagingDir -Force | Out-Null

    $files = @(
        "jp.bat", "jp.ps1", "jp-completion.ps1", "jp_clink.lua",
        "install.bat", "install-powershell.bat", "uninstall.bat",
        "install-remote.bat", "cmd_shortcuts.bat",
        "README.md", "QUICKSTART.md", "LICENSE.txt", "NOTICE", "version.txt"
    )

    foreach ($f in $files) {
        $src = Join-Path $ScriptDir $f
        if (Test-Path $src) {
            Copy-Item $src $stagingDir
        } else {
            Write-Host "  Warning: $f not found, skipping" -ForegroundColor Yellow
        }
    }

    Compress-Archive -Path $stagingDir -DestinationPath $zipPath -Force
    Remove-Item $stagingDir -Recurse -Force

    Write-Host "  Built: $zipPath" -ForegroundColor Green
    return $zipPath
}

function Get-FileHash256 {
    param([string]$FilePath)
    return (Get-FileHash -Path $FilePath -Algorithm SHA256).Hash.ToLower()
}

# --- Publish: GitHub ---

function Publish-GitHub {
    param([string]$Ver, [string]$ZipPath)

    $tag = "v$Ver"
    Write-Host "`n[GitHub] Creating release $tag..." -ForegroundColor Cyan

    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create tag $tag and push to origin" -ForegroundColor Yellow
        Write-Host "  [DRY RUN] Would open GitHub release page for upload" -ForegroundColor Yellow
        return
    }

    # Create git tag
    $existingTag = git -C $ScriptDir tag -l $tag 2>&1
    if ($existingTag) {
        Write-Host "  Tag $tag already exists, skipping tag creation" -ForegroundColor Yellow
    } else {
        git -C $ScriptDir tag -a $tag -m "Release $tag"
        Write-Host "  Created tag: $tag" -ForegroundColor Green
    }

    # Push tag to origin (triggers SSH passphrase prompt)
    Write-Host "  Pushing tag to origin (you may be prompted for SSH passphrase)..." -ForegroundColor White
    git -C $ScriptDir push origin $tag
    Write-Host "  Pushed tag: $tag" -ForegroundColor Green

    # Open GitHub release creation page in browser
    $releaseUrl = "https://github.com/$Repo/releases/new?tag=$tag&title=JP+$tag"
    Write-Host ""
    Write-Host "  Opening GitHub release page in your browser..." -ForegroundColor Cyan
    Write-Host "  Attach this zip: $ZipPath" -ForegroundColor Yellow
    Start-Process $releaseUrl

    # Copy release notes to clipboard if available
    $changelogPath = Join-Path $ScriptDir "CHANGELOG.md"
    if (Test-Path $changelogPath) {
        $content = Get-Content $changelogPath -Raw
        if ($content -match "(?s)## \[$([regex]::Escape($Ver))\].*?(?=\n## \[|---|\z)") {
            $Matches[0].Trim() | Set-Clipboard
            Write-Host "  Release notes copied to clipboard - paste into description!" -ForegroundColor Green
        }
    }

    Write-Host ""
    Write-Host "  Release URL: https://github.com/$Repo/releases/tag/$tag" -ForegroundColor Green
}

# --- Publish: Scoop ---

function Publish-Scoop {
    param([string]$Ver, [string]$ZipPath)

    Write-Host "`n[Scoop] Generating manifest..." -ForegroundColor Cyan

    $hash = Get-FileHash256 -FilePath $ZipPath
    $url = "https://github.com/$Repo/releases/download/v$Ver/jp-$Ver.zip"

    $manifest = @{
        version = $Ver
        description = "Lightweight directory jumper for Windows CMD and PowerShell"
        homepage = "https://github.com/$Repo"
        license = "Apache-2.0"
        url = $url
        hash = $hash
        extract_dir = "jp-$Ver"
        bin = @("jp.bat")
        post_install = @(
            "Write-Host 'JP Directory Jumper installed!' -ForegroundColor Green"
            "Write-Host 'Run: jp add <name> <path>  to save a directory shortcut' -ForegroundColor Cyan"
            "Write-Host 'Run: jp <name>             to jump to it' -ForegroundColor Cyan"
        )
        notes = @(
            "For PowerShell tab completion, run install-powershell.bat from the app directory."
            "For CMD tab completion, install Clink: winget install chrisant996.clink"
        )
    }

    $manifestDir = Join-Path $ScriptDir "dist"
    $manifestPath = Join-Path $manifestDir "jp.json"

    if ($DryRun) {
        Write-Host "  [DRY RUN] Would write manifest to $manifestPath" -ForegroundColor Yellow
        $manifest | ConvertTo-Json -Depth 5 | Write-Host
        return
    }

    $manifest | ConvertTo-Json -Depth 5 | Set-Content $manifestPath -Encoding UTF8
    Write-Host "  Generated: $manifestPath" -ForegroundColor Green
    Write-Host "  Hash: $hash" -ForegroundColor DarkGray

    # Push manifest to scoop bucket repo
    $bucketRepo = "git@github.com:${Repo}-scoop-bucket.git"
    $bucketDir = Join-Path $DistDir "scoop-bucket"

    Write-Host ""
    Write-Host "  Pushing manifest to scoop bucket..." -ForegroundColor Cyan

    if (Test-Path $bucketDir) {
        git -C $bucketDir pull --rebase origin main 2>&1 | Out-Null
    } else {
        git clone $bucketRepo $bucketDir
    }

    # Scoop expects manifests at the repo root (bucket/ is optional)
    Copy-Item $manifestPath (Join-Path $bucketDir "jp.json") -Force

    git -C $bucketDir add jp.json
    git -C $bucketDir diff --cached --quiet 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        git -C $bucketDir commit -m "Update jp to $Ver"
        git -C $bucketDir push origin main
        Write-Host "  Pushed jp.json (v$Ver) to scoop bucket" -ForegroundColor Green
    } else {
        Write-Host "  Scoop bucket already up to date" -ForegroundColor Yellow
    }

    Write-Host ""
    Write-Host "  Users install with:" -ForegroundColor White
    Write-Host "    scoop bucket add jp https://github.com/${Repo}-scoop-bucket" -ForegroundColor Gray
    Write-Host "    scoop install jp" -ForegroundColor Gray
}

# --- Main ---

Write-Host "============================================================" -ForegroundColor Cyan
Write-Host " JP Directory Jumper - Publish" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan

# Resolve version
$currentVersion = Get-CurrentVersion
if ($BumpType) {
    $resolvedVersion = Step-Version -Current $currentVersion -Bump $BumpType
    Write-Host "`nVersion: $currentVersion -> $resolvedVersion ($BumpType bump)" -ForegroundColor White
    if (-not $DryRun) { Set-VersionFile -NewVersion $resolvedVersion }
} elseif ($Version) {
    $resolvedVersion = $Version
    Write-Host "`nVersion: $resolvedVersion (manual override)" -ForegroundColor White
    if (-not $DryRun) { Set-VersionFile -NewVersion $resolvedVersion }
} else {
    $resolvedVersion = $currentVersion
    Write-Host "`nVersion: $resolvedVersion (from version.txt)" -ForegroundColor White
}

# Build zip (needed for all targets)
Write-Host "`n[Build] Packaging release zip..." -ForegroundColor Cyan
$zipPath = Build-ReleaseZip -Ver $resolvedVersion

# Publish to selected targets
$targets = if ($Target -eq "all") { @("github", "scoop") } else { @($Target) }

foreach ($t in $targets) {
    switch ($t) {
        "github" { Publish-GitHub -Ver $resolvedVersion -ZipPath $zipPath }
        "scoop"  { Publish-Scoop  -Ver $resolvedVersion -ZipPath $zipPath }
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Done!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
