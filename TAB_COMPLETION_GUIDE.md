# Tab Completion Guide for JP

JP supports **TAB completion** in both **PowerShell** (built-in) and **CMD** (via [Clink](https://github.com/chrisant996/clink))! Press TAB to cycle through your saved shortcuts.

## Quick Start

### CMD (via Clink)

1. **Install Clink:**
   ```cmd
   winget install chrisant996.clink
   ```

2. **Run the jp installer:**
   ```cmd
   install.bat
   ```
   Say **Yes** at Step 5 to install Clink TAB completion.

3. **Open a new CMD window** and use tab completion:
   ```cmd
   jp [TAB]           # Cycles through saved shortcuts
   jp w[TAB]          # Completes shortcuts starting with 'w'
   ```

### PowerShell (Built-in)

1. **Install the PowerShell version:**
   ```cmd
   install-powershell.bat
   ```

2. **Restart PowerShell**

3. **Use tab completion:**
   ```powershell
   jp [TAB]        # Press TAB to cycle through shortcuts
   jp w[TAB]       # Press TAB to complete shortcuts starting with 'w'
   ```

## How Tab Completion Works

### In PowerShell

**Cycle through all shortcuts:**
```powershell
PS C:\> jp [TAB]
# First press: jp web
# Second press: jp api
# Third press: jp home
# etc...
```

**Auto-complete partial names:**
```powershell
PS C:\> jp we[TAB]
# Completes to: jp web
```

**Works with multiple matches:**
```powershell
PS C:\> jp a[TAB]
# First press: jp api
# Second press: jp app
# Third press: jp azure
```

### In CMD (with Clink)

[Clink](https://github.com/chrisant996/clink) enhances CMD with custom TAB completion. Once installed, jp shortcuts complete just like in PowerShell:

**Cycle through all shortcuts:**
```cmd
C:\> jp [TAB]
# First press: jp web
# Second press: jp api
# Third press: jp home
# etc...
```

**Auto-complete partial names:**
```cmd
C:\> jp we[TAB]
# Completes to: jp web
```

**See available commands:**
```cmd
C:\> jp
# Shows usage and all available commands (add, list, remove, clean, -)
```

### In CMD (without Clink)

If you don't have Clink, you still have options:

**Option 1: Quick list**
```cmd
C:\> jp list
```
Shows all shortcuts to pick from.

**Option 2: Use PowerShell**
```cmd
C:\> powershell
PS C:\> jp [TAB]
```

**Option 3: Create custom aliases**
Edit `cmd_shortcuts.bat` with your most-used shortcuts:
```batch
doskey jpw=jp web
doskey jpa=jp api
```

## Installation Options

### Batch Version + Clink (TAB Completion in CMD)

**Pros:**
- ✅ Tab completion for saved shortcuts in CMD via Clink
- ✅ Faster startup than PowerShell
- ✅ Works identically in CMD and PowerShell

**Cons:**
- ⚠️ Requires Clink to be installed for tab completion

**Install:**
```cmd
winget install chrisant996.clink
cd e:\EProjects\jp
install.bat
```

### PowerShell Version (Built-in Tab Completion)

**Pros:**
- ✅ Full tab completion support (no extra tools needed)
- ✅ Auto-complete partial names
- ✅ Color-coded output
- ✅ Better error messages

**Cons:**
- ⚠️ Slightly slower startup (PowerShell overhead)
- ⚠️ Tab completion only works in PowerShell, not CMD

**Install:**
```cmd
cd e:\EProjects\jp
install-powershell.bat
```

### Batch Version (No Tab Completion)

**Pros:**
- ✅ Fastest startup
- ✅ Works identically in CMD and PowerShell
- ✅ No extra tools or profile modifications

**Cons:**
- ❌ No tab completion

**Install:**
```cmd
cd e:\EProjects\jp
install.bat
```

### Use Both!

You can install both versions and use whichever you prefer:
- `jp.bat` - Batch version
- `jp.ps1` / `jp.cmd` - PowerShell version with tab completion

## Configuration

### Clink Setup (CMD)

The `install.bat` installer automatically detects Clink and offers to install the completion script.

**Script location:** `%LOCALAPPDATA%\clink\jp_clink.lua`

**Manual setup (if needed):**

1. **Install Clink:**
   ```cmd
   winget install chrisant996.clink
   ```

2. **Copy the completion script:**
   ```cmd
   copy jp_clink.lua "%LOCALAPPDATA%\clink\jp_clink.lua"
   ```

3. **Open a new CMD window** - Clink loads scripts automatically

**Verify Clink is active:**
Open CMD and look for the Clink version in the banner, or run:
```cmd
clink info
```

### PowerShell Profile Setup

The installer automatically adds tab completion to your PowerShell profile:

**Location:** `$PROFILE` (typically `Documents\PowerShell\Microsoft.PowerShell_profile.ps1`)

**What's added:**
```powershell
# JP Directory Jumper Tab Completion
. 'C:\Users\YourName\bin\jp.ps1' -Command dummy 2>$null
```

### Manual Setup (if needed)

If tab completion isn't working:

1. **Open PowerShell as Administrator**

2. **Enable script execution:**
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

3. **Edit profile:**
   ```powershell
   notepad $PROFILE
   ```

4. **Add this line:**
   ```powershell
   . 'C:\Users\YourName\bin\jp.ps1' -Command dummy 2>$null
   ```

5. **Save and restart PowerShell**

## Usage Examples

### PowerShell with Tab Completion

```powershell
# Add some shortcuts
PS C:\> jp add web e:\EProjects\website
PS C:\> jp add api e:\EProjects\api
PS C:\> jp add work C:\Work\Projects

# Use tab completion to navigate
PS C:\> jp [TAB]       # Cycles through: web, api, work
PS C:\> jp w[TAB]      # Completes to: web or work
PS C:\> jp we[TAB]     # Completes to: web

# Jump to a project
PS C:\> jp web[ENTER]
Jumped to: e:\EProjects\website
```

### CMD without Tab Completion

```cmd
# Add shortcuts
C:\> jp add web e:\EProjects\website
C:\> jp add api e:\EProjects\api

# View shortcuts to pick from
C:\> jp list
Saved directories:
  api = e:\EProjects\api
  web = e:\EProjects\website

# Jump to a project
C:\> jp web
Jumped to: e:\EProjects\website
```

## Tips & Tricks

### PowerShell Tips

💡 **Start typing and press TAB:**
```powershell
jp we[TAB]    # Completes to 'web'
```

💡 **Press TAB multiple times to cycle:**
```powershell
jp [TAB][TAB][TAB]    # Cycles through all shortcuts
```

💡 **Case doesn't matter:**
```powershell
jp WEB[TAB]    # Works just like jp web[TAB]
```

### CMD Tips (with Clink)

💡 **TAB cycles through saved shortcuts:**
```cmd
jp [TAB][TAB][TAB]    # Cycles through all saved shortcuts
```

💡 **Partial matching works:**
```cmd
jp we[TAB]    # Completes to 'web'
```

### CMD Tips (without Clink)

💡 **Create a quick alias:**
```cmd
doskey jpl=jp list
```
Then just type `jpl` to see all shortcuts

💡 **Use PowerShell temporarily:**
```cmd
C:\> powershell
PS C:\> jp [TAB]
PS C:\> exit
C:\>
```

💡 **Add frequent shortcuts to cmd_shortcuts.bat:**
```batch
doskey jpw=jp web
doskey jpa=jp api
```

## Troubleshooting

### Tab completion not working in CMD (Clink)

**Check if Clink is installed:**
```cmd
winget list chrisant996.clink
```

**Check if Clink is injected into CMD:**
Open a new CMD window and run:
```cmd
clink info
```
If "clink is not recognized", Clink's autorun may not be set up. Run:
```cmd
"C:\Program Files (x86)\clink\clink_x64.exe" autorun install
```

**Check if jp_clink.lua is in the scripts directory:**
```cmd
dir "%LOCALAPPDATA%\clink\jp_clink.lua"
```
If missing, copy it:
```cmd
copy path\to\jp_clink.lua "%LOCALAPPDATA%\clink\"
```

**Check Clink log for errors:**
```cmd
type "%LOCALAPPDATA%\clink\clink.log"
```

### Tab completion not working in PowerShell

**Check if jp.ps1 is loaded:**
```powershell
Get-Command jp
```
Should show `jp.ps1` or `jp.cmd`

**Check PowerShell profile:**
```powershell
cat $PROFILE
```
Should contain reference to jp.ps1

**Reload profile:**
```powershell
. $PROFILE
```

### Tab completion showing file names instead of shortcuts

This means the ArgumentCompleter isn't registered. Run:
```powershell
. 'C:\Users\YourName\bin\jp.ps1' -Command dummy 2>$null
```

### "Cannot be loaded because running scripts is disabled"

Enable script execution:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

## Comparison

| Feature | Batch (jp.bat) | Batch + Clink | PowerShell (jp.ps1) |
|---------|---------------|---------------|---------------------|
| Tab completion | ❌ | ✅ | ✅ |
| Speed | ⚡⚡⚡ Fast | ⚡⚡⚡ Fast | ⚡⚡ Medium |
| Works in CMD | ✅ | ✅ | ✅ (via jp.cmd) |
| Works in PowerShell | ✅ | ✅ | ✅ |
| Color output | Limited | Limited | ✅ Full color |
| Error messages | Basic | Basic | Detailed |
| Extra tools needed | None | Clink | None |

## Recommendation

- 🎯 **Use Batch + Clink** if you primarily work in CMD and want TAB completion
- 🎯 **Use PowerShell version** if you primarily work in PowerShell
- 🎯 **Use Batch version** if you want maximum speed with no extras
- 🎯 **Install both** and use whichever fits your current shell!

---

**Happy jumping with tab completion! 🚀**
