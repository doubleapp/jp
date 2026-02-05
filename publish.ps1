<#
.SYNOPSIS
    Publish JP Directory Jumper - GitHub Release, Scoop, and WinGet.
.DESCRIPTION
    Builds a release zip, creates a GitHub release, and generates
    Scoop/WinGet manifests. Requires: gh CLI (GitHub), git.
.PARAMETER Target
    Where to publish: github, scoop, winget, or all.
.PARAMETER Version
    Override version (e.g., "1.2.0"). If omitted, reads from version.txt.
.PARAMETER BumpType
    Auto-bump before publishing: major, minor, or patch.
.PARAMETER DryRun
    Show what would happen without making changes.
.EXAMPLE
    .\publish.ps1 -Target all -BumpType patch
    .\publish.ps1 -Target github -Version 2.0.0
    .\publish.ps1 -Target scoop -DryRun
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidateSet("github", "scoop", "winget", "all")]
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
        "jp.bat", "jp.ps1", "jp_clink.lua",
        "install.bat", "install-powershell.bat", "uninstall.bat",
        "install-remote.bat", "cmd_shortcuts.bat",
        "README.md", "QUICKSTART.md", "LICENSE.txt", "version.txt"
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

    # Build release notes from CHANGELOG
    $changelogPath = Join-Path $ScriptDir "CHANGELOG.md"
    $notes = "Release $tag"
    if (Test-Path $changelogPath) {
        $content = Get-Content $changelogPath -Raw
        if ($content -match "(?s)## \[$([regex]::Escape($Ver))\].*?(?=\n## \[|---|\z)") {
            $notes = $Matches[0].Trim()
        }
    }

    if ($DryRun) {
        Write-Host "  [DRY RUN] Would create release $tag with asset $ZipPath" -ForegroundColor Yellow
        return
    }

    $notesFile = Join-Path $DistDir "release-notes.md"
    $notes | Set-Content $notesFile

    gh release create $tag $ZipPath --repo $Repo --title "JP $tag" --notes-file $notesFile

    Remove-Item $notesFile -ErrorAction SilentlyContinue
    Write-Host "  Published: https://github.com/$Repo/releases/tag/$tag" -ForegroundColor Green
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
        license = "MIT"
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
    Write-Host ""
    Write-Host "  Next steps for Scoop:" -ForegroundColor Yellow
    Write-Host "    1. Create a GitHub repo: $Repo-scoop-bucket" -ForegroundColor White
    Write-Host "    2. Copy dist/jp.json into that repo as bucket/jp.json" -ForegroundColor White
    Write-Host "    3. Users install with:" -ForegroundColor White
    Write-Host "         scoop bucket add jp https://github.com/$Repo-scoop-bucket" -ForegroundColor Gray
    Write-Host "         scoop install jp" -ForegroundColor Gray
}

# --- Publish: WinGet ---

function Publish-WinGet {
    param([string]$Ver, [string]$ZipPath)

    Write-Host "`n[WinGet] Generating manifest..." -ForegroundColor Cyan

    $hash = Get-FileHash256 -FilePath $ZipPath
    $url = "https://github.com/$Repo/releases/download/v$Ver/jp-$Ver.zip"

    $wingetDir = Join-Path $DistDir "winget"
    if (-not (Test-Path $wingetDir)) { New-Item -ItemType Directory -Path $wingetDir -Force | Out-Null }

    # Version manifest
    $versionYaml = @"
PackageIdentifier: doubleapp.jp
PackageVersion: $Ver
DefaultLocale: en-US
ManifestType: version
ManifestVersion: 1.6.0
"@

    # Locale manifest
    $localeYaml = @"
PackageIdentifier: doubleapp.jp
PackageVersion: $Ver
PackageLocale: en-US
Publisher: doubleapp
PublisherUrl: https://github.com/$Repo
PackageName: JP Directory Jumper
PackageUrl: https://github.com/$Repo
License: MIT
LicenseUrl: https://github.com/$Repo/blob/main/LICENSE.txt
ShortDescription: Lightweight directory jumper for Windows CMD and PowerShell
Description: |-
  JP is a lightweight, fast directory navigation tool for Windows.
  Save directories with short names and jump to them instantly.
  Supports CMD (batch), PowerShell with tab completion, and cross-drive navigation.
Tags:
  - cli
  - directory
  - navigation
  - productivity
  - windows
ManifestType: defaultLocale
ManifestVersion: 1.6.0
"@

    # Installer manifest
    $installerYaml = @"
PackageIdentifier: doubleapp.jp
PackageVersion: $Ver
InstallerType: zip
NestedInstallerType: portable
NestedInstallerFiles:
  - RelativeFilePath: jp-$Ver\jp.bat
    PortableCommandAlias: jp
Installers:
  - Architecture: neutral
    InstallerUrl: $url
    InstallerSha256: $($hash.ToUpper())
ManifestType: installer
ManifestVersion: 1.6.0
"@

    if ($DryRun) {
        Write-Host "  [DRY RUN] Would write WinGet manifests to $wingetDir" -ForegroundColor Yellow
        Write-Host "`n--- version ---`n$versionYaml"
        Write-Host "`n--- locale ---`n$localeYaml"
        Write-Host "`n--- installer ---`n$installerYaml"
        return
    }

    $versionYaml | Set-Content (Join-Path $wingetDir "doubleapp.jp.yaml") -Encoding UTF8
    $localeYaml | Set-Content (Join-Path $wingetDir "doubleapp.jp.locale.en-US.yaml") -Encoding UTF8
    $installerYaml | Set-Content (Join-Path $wingetDir "doubleapp.jp.installer.yaml") -Encoding UTF8

    Write-Host "  Generated manifests in: $wingetDir" -ForegroundColor Green
    Write-Host "  Hash: $hash" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  Next steps for WinGet:" -ForegroundColor Yellow
    Write-Host "    1. Fork https://github.com/microsoft/winget-pkgs" -ForegroundColor White
    Write-Host "    2. Copy manifests to: manifests/d/doubleapp/jp/$Ver/" -ForegroundColor White
    Write-Host "    3. Submit a pull request" -ForegroundColor White
    Write-Host "    Or use: wingetcreate submit $wingetDir" -ForegroundColor Gray
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
$targets = if ($Target -eq "all") { @("github", "scoop", "winget") } else { @($Target) }

foreach ($t in $targets) {
    switch ($t) {
        "github" { Publish-GitHub -Ver $resolvedVersion -ZipPath $zipPath }
        "scoop"  { Publish-Scoop  -Ver $resolvedVersion -ZipPath $zipPath }
        "winget" { Publish-WinGet -Ver $resolvedVersion -ZipPath $zipPath }
    }
}

Write-Host "`n============================================================" -ForegroundColor Cyan
Write-Host " Done!" -ForegroundColor Green
Write-Host "============================================================" -ForegroundColor Cyan
