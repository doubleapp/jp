# JP - Directory Jumper for Windows CMD

A lightweight, fast directory navigation tool for Windows Command Prompt. Jump between your projects instantly without endless `cd` commands!

## Features

- 🚀 **Quick Navigation**: Save directories with short names and jump to them instantly
- ⌨️ **Tab Completion**: Press TAB to cycle through shortcuts (PowerShell version + CMD via Clink)
- 💾 **Persistent**: Shortcuts are saved permanently across sessions
- 🎯 **Simple**: Easy to add, remove, and list shortcuts
- 🔧 **Flexible**: Use dynamic shortcuts (jp) or static aliases (doskey)
- 💿 **Cross-Drive**: Automatically detects and handles jumping between different drives (C: → E:)
- 📦 **Portable**: Single file, minimal dependencies

## Installation

### Choose Your Version

**PowerShell Version (with Tab Completion)** ⭐ Recommended
1. Run `install-powershell.bat`
2. Close and reopen PowerShell
3. Use `jp [TAB]` to cycle through shortcuts!

**Batch Version (faster, optional tab completion via Clink)**
1. Run `install.bat`
2. Close and reopen CMD
3. Start using `jp`!
4. (Optional) Install [Clink](https://github.com/chrisant996/clink) for TAB completion in CMD:
   ```cmd
   winget install chrisant996.clink
   ```
   Then re-run `install.bat` to set up TAB completion

### Manual Install

1. Copy `jp.bat` or `jp.ps1` to a directory in your PATH (e.g., `C:\Users\YourName\bin`)
2. Add that directory to your PATH environment variable
3. Restart CMD/PowerShell

See [TAB_COMPLETION_GUIDE.md](TAB_COMPLETION_GUIDE.md) for detailed tab completion setup

## Usage

### JP Command (Recommended)

**Add a directory shortcut:**
```cmd
jp add web e:\EProjects\doubletap\storewebsite
jp add home C:\Users\YourName
jp add api C:\projects\myapi
```

**Add current directory:**
```cmd
cd e:\some\path
jp add myproject        # Omit path to use current directory
# OR
jp add myproject .      # Use "." to explicitly specify current directory
```

**Jump to a saved directory:**
```cmd
jp web      → Jumps to e:\EProjects\doubletap\storewebsite
jp home     → Jumps to C:\Users\YourName
jp api      → Jumps to C:\projects\myapi
```

**Jump to previous directory (toggle back/forth):**
```cmd
jp -        → Jump to previous location
jp -        → Jump back (toggles between last two directories)
```

**List all shortcuts:**
```cmd
jp list
```

**Remove a shortcut:**
```cmd
jp remove web
```

**Interactive cleanup (select multiple to remove):**
```cmd
jp clean
```
This shows all shortcuts and lets you type which ones to remove (space-separated)

### CMD Shortcuts (Alternative Method)

If you prefer static aliases (like Linux aliases):

1. Edit `cmd_shortcuts.bat` and add your directories:
   ```batch
   doskey cdweb=cd /d e:\EProjects\doubletap\storewebsite
   doskey cdapi=cd /d C:\myother\project
   ```

2. Run it manually each session:
   ```cmd
   cmd_shortcuts.bat
   ```

3. Or enable auto-load during installation to run automatically

## Examples

### Basic Workflow
```cmd
# Add your main projects once
jp add web e:\EProjects\website
jp add api e:\EProjects\api
jp add docs C:\Users\Me\Documents

# Now jump around easily
jp web
jp api
jp docs

# See what you have saved
jp list
```

### Combined with Built-in Commands
```cmd
# Jump to main project
jp web

# Temporarily check another folder
pushd ..\api
dir
popd

# Back to web project
jp web
```

### Cross-Drive Navigation
```cmd
# Add projects on different drives
jp add web e:\EProjects\website
jp add docs C:\Users\Me\Documents
jp add backup D:\Backups

# Jump seamlessly between drives
C:\> jp web
Switching from C: to E:
Jumped to: e:\EProjects\website

E:\EProjects\website> jp docs
Switching from E: to C:
Jumped to: C:\Users\Me\Documents

# Jump back to previous location
C:\Users\Me\Documents> jp -
Switching from C: to E:
Jumped back to: e:\EProjects\website

# Toggle back and forth
E:\EProjects\website> jp -
Jumped back to: C:\Users\Me\Documents

# The script automatically detects drive changes and uses /d flag
```

## How It Works

- **jp.bat**: A batch script that manages directory shortcuts
- **Storage**: Shortcuts are saved in `%USERPROFILE%\.jump_directories`
- **Format**: Simple `name=path` text file
- **No dependencies**: Pure batch script, works on all Windows versions

## Comparison with Other Methods

| Method | Speed | Persistent | Dynamic | Notes |
|--------|-------|------------|---------|-------|
| `jp` | ⚡⚡⚡ | ✅ | ✅ | Best for frequently used projects |
| doskey aliases | ⚡⚡⚡ | ❌ | ❌ | Fast but need manual setup each session |
| pushd/popd | ⚡⚡ | ❌ | ✅ | Built-in, good for temporary navigation |
| cd commands | ⚡ | ❌ | ❌ | Tedious for deep directories |

## Tips & Tricks

1. **Use short, memorable names**: `jp w` is faster than `jp website`
2. **Group by project**: `jp web`, `jp web-api`, `jp web-db`
3. **Combine with pushd**: Use `jp` for main locations, `pushd` for temporary jumps
4. **Edit shortcuts file directly**: Advanced users can edit `%USERPROFILE%\.jump_directories`

## Troubleshooting

**"jp is not recognized as a command"**
- Make sure you reopened CMD after installation
- Check if `%USERPROFILE%\bin` is in your PATH
- Run `install.bat` again

**Shortcut doesn't work after restart**
- Shortcuts are saved in `%USERPROFILE%\.jump_directories`
- Check if this file exists and contains your shortcuts
- Re-add the shortcut if needed

**Auto-load not working**
- Check registry key: `HKCU\Software\Microsoft\Command Processor\AutoRun`
- It should point to `%USERPROFILE%\cmd_shortcuts.bat`
- Disable antivirus if blocking registry changes

## Uninstall

1. Remove `jp.bat` from your bin directory
2. Remove the bin directory from PATH
3. Delete `%USERPROFILE%\.jump_directories`
4. (Optional) Remove AutoRun registry key:
   ```cmd
   reg delete "HKCU\Software\Microsoft\Command Processor" /v AutoRun /f
   ```

## Files Included

- `jp.bat` - Main directory jumper script
- `jp.ps1` - PowerShell version with built-in tab completion
- `jp_clink.lua` - Clink TAB completion script for CMD
- `cmd_shortcuts.bat` - Alternative static aliases (template)
- `install.bat` - Automated installation script (batch version)
- `install-powershell.bat` - Automated installation script (PowerShell version)
- `uninstall.bat` - Automated uninstallation script
- `README.md` - This file

## System Requirements

- Windows 7 or later
- Command Prompt (cmd.exe)
- No admin rights required

## License

Apache License 2.0 - Copyright 2026 Amir Gur. See [LICENSE.txt](LICENSE.txt) for details.

## Contributing

Found a bug? Have a feature request? Feel free to modify and enhance!

## Author

Created by Amir Gur as a productivity tool for developers who work with multiple projects.

---

**Happy jumping! 🚀**
