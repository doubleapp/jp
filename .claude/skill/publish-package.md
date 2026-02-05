# Skill: Publish Package

**Trigger**: `/publish-package` or when the user asks to publish/release JP.

## Overview

This skill handles versioning and publishing JP to GitHub Releases and Scoop.

## Version Bumping Rules

Before publishing, evaluate all commits since the last published git tag (e.g., `v1.0.0`) to determine the correct semver bump.

### Step 1: Find the last published version

```bash
git tag -l "v*" --sort=-v:refname | head -1
```

If no tags exist, the base version is `1.0.0` (from `version.txt`).

### Step 2: Get changes since last tag

```bash
git log v1.0.0..HEAD --oneline
git diff v1.0.0..HEAD --stat
```

### Step 3: Classify the bump

Evaluate the changes and apply the **highest applicable** bump:

| Bump    | When to apply                                                    |
|---------|------------------------------------------------------------------|
| **major** | Breaking changes: renamed commands, removed features, changed storage format, changed default behavior users depend on |
| **minor** | New features: new commands, new flags, new file support, new install targets, significant UX improvements |
| **patch** | Bug fixes, documentation updates, refactors, test changes, typo fixes, performance improvements with no API change |

**Examples:**
- Added `jp clean` command → **minor**
- Fixed cross-drive detection bug → **patch**
- Renamed `jp remove` to `jp delete` → **major**
- Added Scoop publishing support → **minor**
- Updated README typo → **patch**
- Changed shortcut file format from `name=path` to JSON → **major**

### Step 4: Bump and publish

Run the publish script with the determined bump type:

```powershell
.\publish.ps1 -Target all -BumpType <major|minor|patch>
```

Or for dry run first:

```powershell
.\publish.ps1 -Target all -BumpType <major|minor|patch> -DryRun
```

## Publish Workflow

### 1. Pre-publish checklist

- [ ] All tests pass (`test_e2e.bat` and `test_e2e.ps1`)
- [ ] Changes are committed and pushed
- [ ] CHANGELOG.md is updated with the new version section
- [ ] version.txt will be updated automatically by the script

### 2. Update CHANGELOG.md

Before running publish, add a new section to CHANGELOG.md:

```markdown
## [X.Y.Z] - YYYY-MM-DD

### Added
- (list new features)

### Changed
- (list changes to existing features)

### Fixed
- (list bug fixes)
```

### 3. Run publish

```powershell
# Publish to all targets
.\publish.ps1 -Target all -BumpType patch

# Or publish to specific target
.\publish.ps1 -Target github -BumpType minor
.\publish.ps1 -Target scoop
```

### 4. Post-publish

- Tag + push is done automatically by publish.ps1 (triggers SSH passphrase prompt)
- Upload the zip to the GitHub release page (opens in browser automatically)
- Scoop bucket is updated automatically (pushed to doubleapp/jp-scoop-bucket)

## Files

| File | Purpose |
|------|---------|
| `version.txt` | Single source of truth for current version |
| `publish.ps1` | Main publish script (build, release, Scoop) |
| `install-remote.bat` | One-command installer for end users |
| `dist/` | Output directory (git-ignored) |
| `dist/jp-X.Y.Z.zip` | Release zip archive |
| `dist/jp.json` | Scoop manifest |

## Target Details

### GitHub Release
- Creates a git tag, pushes via SSH (prompts for passphrase)
- Opens GitHub release page in browser for zip upload
- Release notes from CHANGELOG.md copied to clipboard
- Requires: git with SSH key configured

### Scoop
- Generates `jp.json` manifest with SHA256 hash
- Auto-pushes to `doubleapp/jp-scoop-bucket` repo
- Users install: `scoop bucket add jp https://github.com/doubleapp/jp-scoop-bucket && scoop install jp`

### WinGet (not supported)
WinGet requires MSI/EXE installers. JP is a pure script tool so WinGet is not applicable.
