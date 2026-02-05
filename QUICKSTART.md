# Quick Start Guide - JP Directory Jumper

Get started in 2 minutes!

## Installation (30 seconds)

1. **Run the installer:**
   ```cmd
   install.bat
   ```

2. **Close and reopen CMD**

3. **Done!** 🎉

## First Steps (1 minute)

**Add your first project:**
```cmd
jp add web e:\EProjects\doubletap\storewebsite
```

**Jump to it:**
```cmd
jp web
```

**That's it!** You're now jumping between directories.

## Add More Projects

```cmd
jp add home C:\Users\YourName
jp add docs C:\Users\YourName\Documents
jp add downloads C:\Users\YourName\Downloads
```

## Essential Commands

| Command | What it does |
|---------|-------------|
| `jp add <name> <path>` | Save a directory |
| `jp <name>` | Jump to saved directory |
| `jp -` | Jump to previous directory (toggle) |
| `jp list` | Show all saved directories |
| `jp remove <name>` | Delete a specific shortcut |
| `jp clean` | Interactive cleanup (remove multiple) |

## Pro Tips

💡 **Use short names**: `jp w` instead of `jp website`

💡 **Add current directory**: `jp add name` or `jp add name .`

💡 **List to remember**: Forgot a name? Run `jp list`

## Want TAB Completion in CMD?

Install [Clink](https://github.com/chrisant996/clink) and re-run the installer:
```cmd
winget install chrisant996.clink
install.bat
```
Then in a new CMD window, `jp [TAB]` cycles through your shortcuts!

## What's Next?

- Read [README.md](README.md) for full documentation
- Check [EXAMPLES.md](EXAMPLES.md) for real-world usage
- See [TAB_COMPLETION_GUIDE.md](TAB_COMPLETION_GUIDE.md) for full TAB completion setup
- Customize [cmd_shortcuts.bat](cmd_shortcuts.bat) for static aliases

---

**Need help?** Run `jp` with no arguments to see usage.
