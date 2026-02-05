# Skill: Publish Package

**Trigger**: `/publish-package` or when the user asks to publish/release JP.

## Overview

This skill handles versioning and publishing JP to GitHub Releases, Scoop, and WinGet.

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
- Added WinGet publishing support → **minor**
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
.\publish.ps1 -Target winget
```

### 4. Post-publish

- Tag the commit: `git tag v<version>` (done automatically by `gh release create`)
- Push the tag: `git push origin v<version>`
- For Scoop: copy `dist/jp.json` to the scoop bucket repo
- For WinGet: submit `dist/winget/` manifests to microsoft/winget-pkgs

## Files

| File | Purpose |
|------|---------|
| `version.txt` | Single source of truth for current version |
| `publish.ps1` | Main publish script (build, release, manifests) |
| `install-remote.bat` | One-command installer for end users |
| `dist/` | Output directory (git-ignored) |
| `dist/jp-X.Y.Z.zip` | Release zip archive |
| `dist/jp.json` | Scoop manifest |
| `dist/winget/` | WinGet manifest files |

## Target Details

### GitHub Release
- Creates a tagged release with the zip as an asset
- Release notes extracted from CHANGELOG.md
- Requires: `gh` CLI authenticated

### Scoop
- Generates `jp.json` manifest with SHA256 hash
- Needs a separate bucket repo (e.g., `doubleapp/jp-scoop-bucket`)
- Users install: `scoop bucket add jp <bucket-url> && scoop install jp`

### WinGet
- Generates three YAML manifests (version, locale, installer)
- Submit via PR to `microsoft/winget-pkgs`
- Users install: `winget install doubleapp.jp`
