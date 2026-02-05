# Changelog

All notable changes to JP Directory Jumper will be documented in this file.

## [1.1.0] - 2026-02-05

### Added
- **NEW: Clink TAB completion for CMD** - Press TAB to cycle through saved shortcuts in CMD
  - `jp [TAB]` - cycles through saved shortcut names
  - `jp w[TAB]` - auto-completes partial shortcut names
- `jp_clink.lua` - Clink completion script
- Clink detection and setup in `install.bat` (Step 5)

### Changed
- Updated all documentation to reflect Clink TAB completion support
- Updated `install.bat` with optional Clink completion setup step

## [1.0.0] - 2026-02-05

### Added
- Initial release of JP Directory Jumper
- Core `jp.bat` script with add, remove, list, and jump functionality
- **NEW: `jp.ps1` PowerShell version with TAB COMPLETION support** ⭐
- **NEW: `jp clean` - Interactive cleanup to remove multiple shortcuts**
- `install.bat` automated installation script
- `install-powershell.bat` automated installation for PowerShell version
- `uninstall.bat` automated uninstallation script
- `cmd_shortcuts.bat` template for static aliases
- Comprehensive README.md documentation
- EXAMPLES.md with real-world usage scenarios
- QUICKSTART.md for new users
- **TAB_COMPLETION_GUIDE.md** - Complete guide for tab completion setup
- **REMOVING_SHORTCUTS_GUIDE.md** - Guide for removing shortcuts
- Support for adding current directory without specifying path
- Persistent storage in `%USERPROFILE%\.jump_directories`
- Automatic PATH configuration during installation
- Optional auto-load of cmd_shortcuts.bat
- **Cross-drive detection**: Automatically detects when jumping between drives (C: → E:) and displays notification
- **Smart error handling**: Validates directory accessibility before jumping

### Features
- Add directory shortcuts: `jp add <name> <path>`
- **Add current directory**: `jp add <name> .` or `jp add <name>` (omit path)
- Jump to shortcuts: `jp <name>`
- **Jump to previous**: `jp -` - Toggle back and forth between last two directories
- **TAB completion**: Press TAB to cycle through shortcuts (PowerShell version)
- List all shortcuts: `jp list`
- Remove shortcuts: `jp remove <name>`
- **Interactive cleanup**: `jp clean` - Remove multiple shortcuts at once
- Case-insensitive shortcut names
- Works with paths containing spaces
- **Automatic drive switching** with `/d` flag when crossing drives
- Visual feedback when switching between drives
- Error detection for inaccessible directories
- **Dot syntax support**: Use `.` to explicitly add current directory
- **Previous directory tracking**: Automatically saves last location for `jp -`
- No dependencies or admin rights required (batch version)
- PowerShell version with enhanced features and tab completion
- Works on Windows 7 and later

### Documentation
- Complete installation guide
- Usage examples for different user types (developers, admins, etc.)
- Troubleshooting section
- Tips and best practices
- Comparison with alternative methods

---

## Future Enhancements (Ideas)

- [x] Tab completion support (CMD via Clink, PowerShell built-in)
- [ ] Import/export shortcuts
- [ ] Shortcut categories/groups
- [ ] Recent directories history
- [ ] Fuzzy matching for shortcut names
- [x] PowerShell version for better Windows integration
- [ ] GUI configuration tool
- [ ] Backup/restore functionality
- [ ] Team sharing features
- [ ] Integration with Windows Terminal

---

## Contributing

Have an idea? Found a bug? Feel free to modify and enhance!
