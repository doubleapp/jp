# Changelog

All notable changes to JP Directory Jumper will be documented in this file.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-05

### Added
- Core `jp.bat` batch script with add, remove, list, clean, and jump commands
- `jp.ps1` PowerShell version with built-in TAB completion
- `jp -` toggle between current and previous directory
- Dot syntax: `jp add name .` to save current directory
- Cross-drive detection with automatic `/d` flag (C: to E:, etc.)
- Clink TAB completion for CMD via `jp_clink.lua`
- `install.bat` automated batch version installer
- `install-powershell.bat` automated PowerShell version installer
- `install-remote.bat` one-command GitHub installer for end users
- `uninstall.bat` automated uninstaller
- `publish.ps1` publishing to GitHub Releases, Scoop, and WinGet
- Persistent storage in `%USERPROFILE%\.jump_directories`
- Case-insensitive shortcut names and paths with spaces
- Comprehensive test suites (`test_e2e.bat`, `test_e2e.ps1`)
- Documentation: README, QUICKSTART, EXAMPLES, TAB_COMPLETION_GUIDE, and more

---

## Future Enhancements (Ideas)

- [ ] Import/export shortcuts
- [ ] Shortcut categories/groups
- [ ] Recent directories history
- [ ] Fuzzy matching for shortcut names
- [ ] GUI configuration tool
- [ ] Backup/restore functionality
- [ ] Team sharing features
- [ ] Integration with Windows Terminal
