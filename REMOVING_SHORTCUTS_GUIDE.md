# Guide: Removing Shortcuts in JP

There are multiple ways to remove shortcuts in JP. Choose the method that works best for your situation.

## Method 1: Remove Single Shortcut

**Best for:** Removing one specific shortcut

```cmd
jp remove <name>
```

**Example:**
```cmd
C:\> jp list
Saved directories:
  web = e:\EProjects\doubletap\storewebsite
  api = e:\EProjects\api
  oldproject = C:\OldStuff

C:\> jp remove oldproject
Removed 'oldproject'

C:\> jp list
Saved directories:
  web = e:\EProjects\doubletap\storewebsite
  api = e:\EProjects\api
```

## Method 2: Interactive Cleanup (NEW!)

**Best for:** Reviewing and removing multiple shortcuts at once

```cmd
jp clean
```

**Example Session:**
```cmd
C:\> jp clean

========================================
Interactive Shortcut Cleanup
========================================

Current shortcuts:

  [1] web = e:\EProjects\doubletap\storewebsite
  [2] api = e:\EProjects\api
  [3] oldproject = C:\OldStuff
  [4] temp = C:\Temp\Work
  [5] test = e:\Test

Enter shortcut names to remove (space-separated), or 'all' to remove all:
Example: web api temp

Remove: oldproject temp test
Removed: oldproject
Removed: temp
Removed: test

Cleanup complete!
```

### Interactive Cleanup Features:

**Remove multiple shortcuts:**
```cmd
Remove: oldproject temp test
```

**Remove all shortcuts (with confirmation):**
```cmd
Remove: all
Are you sure you want to remove ALL shortcuts (Y/N)? Y
All shortcuts removed.
```

**Cancel cleanup:**
```cmd
Remove: [just press Enter]
No shortcuts removed.
```

## Method 3: Remove All and Start Fresh

**Best for:** Completely clearing all shortcuts

```cmd
del %USERPROFILE%\.jump_directories
```

Or use the interactive method:
```cmd
jp clean
Remove: all
```

## Comparison

| Method | When to Use | Pros | Cons |
|--------|-------------|------|------|
| `jp remove <name>` | Single removal | Fast, direct | One at a time |
| `jp clean` | Multiple removals | Interactive, visual | Requires typing |
| Manual delete | Clear everything | Complete reset | Removes all |

## Common Scenarios

### Scenario 1: Clean Up Old Projects

```cmd
# Review what you have
jp list

# Remove old ones interactively
jp clean
Remove: old-client-2023 temp-project prototype-v1
```

### Scenario 2: Remove Typo

```cmd
# Made a typo when adding
jp add wbe e:\EProjects\website

# Remove the typo
jp remove wbe

# Add correct one
jp add web e:\EProjects\website
```

### Scenario 3: Spring Cleaning

```cmd
# See everything
jp list

# Review and decide what to keep
jp clean

# Enter all the names you want to remove
Remove: project1 project2 old-temp archived-2024
```

### Scenario 4: Fresh Start

```cmd
# Remove everything
jp clean
Remove: all
Are you sure you want to remove ALL shortcuts (Y/N)? Y

# Add only current projects
jp add web e:\EProjects\current-website
jp add api e:\EProjects\current-api
```

## Tips

💡 **Before removing:** Run `jp list` to see all shortcuts

💡 **Double-check:** Make sure you spell the shortcut name correctly

💡 **Use clean for bulk:** If removing 3+ shortcuts, use `jp clean` instead of multiple `jp remove` commands

💡 **Keep it clean:** Periodically review with `jp list` and remove unused shortcuts

💡 **No undo:** Once removed, you'll need to re-add. Write down paths if unsure

## Troubleshooting

**"Error: 'name' not found"**
- Check spelling with `jp list`
- Names are case-insensitive but must match exactly

**"No shortcuts removed" after jp clean**
- You pressed Enter without typing anything
- Type the shortcut names you want to remove

**Want to remove but keep the path?**
```cmd
# Save the path first
jp list > my-shortcuts-backup.txt

# Then remove
jp remove myproject

# Can re-add later using the backup
```

## See Also

- [README.md](README.md) - Full documentation
- [EXAMPLES.md](EXAMPLES.md) - Usage examples
- [QUICKSTART.md](QUICKSTART.md) - Getting started guide
