# Previous Directory Feature - `jp -`

Jump back and forth between your last two locations with `jp -`, similar to `cd -` in Linux/Unix!

## Quick Start

```cmd
# Jump to a directory
C:\> jp web
Jumped to: e:\EProjects\website

# Jump to another directory
E:\EProjects\website> jp api
Jumped to: e:\EProjects\api

# Jump back to previous (website)
E:\EProjects\api> jp -
Jumped back to: e:\EProjects\website

# Jump forward again (api)
E:\EProjects\website> jp -
Jumped back to: e:\EProjects\api

# Keep toggling!
E:\EProjects\api> jp -
Jumped back to: e:\EProjects\website
```

## How It Works

Every time you jump to a directory using `jp <name>`, your **current location is automatically saved**. When you use `jp -`, you jump to that saved location, and the new location becomes the saved one.

This creates a **toggle effect** between two directories!

## Use Cases

### 1. Frontend & Backend Development

```cmd
# Add your projects
jp add web e:\Projects\website\frontend
jp add api e:\Projects\website\backend

# Work on frontend
jp web
code .

# Check backend
jp api
npm test

# Back to frontend
jp -

# Back to backend
jp -

# Toggle as you work!
```

### 2. Code & Documentation

```cmd
jp add code e:\Projects\MyApp\src
jp add docs e:\Projects\MyApp\docs

# Write some code
jp code
# Edit files...

# Update docs
jp docs
# Edit README...

# Back to code
jp -

# Back to docs
jp -
```

### 3. Development & Testing

```cmd
jp add dev C:\Work\Development
jp add test C:\Work\Testing

jp dev
# Make changes...

jp test
# Run tests...

jp -
# Fix issues...

jp -
# Test again...
```

### 4. Local & Remote Directories

```cmd
jp add local C:\Projects\website
jp add remote Z:\SharedDrive\website

jp local
# Work locally...

jp remote
# Sync files...

jp -
# Back to local...

jp -
# Check remote again...
```

## Comparison with Other Methods

| Method | Remembers Location | Toggle | Cross-Drive |
|--------|-------------------|--------|-------------|
| `jp -` | ✅ Yes | ✅ Yes | ✅ Yes |
| `pushd`/`popd` | ✅ Yes | ❌ Stack-based | ✅ Yes |
| `cd ..` | ❌ No | ❌ No | ❌ No |
| Regular `jp` | ❌ No | ❌ No | ✅ Yes |

**`jp -` advantages:**
- Simple toggle between two places
- Automatic - no need to explicitly save
- Works across drives
- Persists across commands (until next jump)

**`pushd`/`popd` advantages:**
- Stack-based (can go back multiple levels)
- Built into Windows

## Technical Details

### Storage

Previous directory is stored in:
```
%USERPROFILE%\.jump_previous
```

This file contains the path of your last location.

### When Previous Is Updated

The previous directory is saved when you:
- Jump to a named shortcut: `jp web`
- Use `jp -` (toggles the previous location)

The previous directory is **NOT** saved when you:
- Add a shortcut: `jp add name path`
- List shortcuts: `jp list`
- Remove shortcuts: `jp remove name`
- Clean shortcuts: `jp clean`
- Use regular `cd` commands

### Cross-Drive Support

`jp -` fully supports jumping across drives:

```cmd
C:\Users\Me> jp web
Switching from C: to E:
Jumped to: e:\EProjects\website

E:\EProjects\website> jp -
Switching from E: to C:
Jumped back to: C:\Users\Me
```

## Common Workflows

### Quick Edit Workflow

```cmd
# You're in project root
E:\Projects\MyApp> jp src
Jumped to: e:\Projects\MyApp\src

# Edit some files...
# Need to check config in root

E:\Projects\MyApp\src> jp -
Jumped back to: E:\Projects\MyApp

# Check config...
# Back to editing

E:\Projects\MyApp> jp -
Jumped back to: E:\Projects\MyApp\src
```

### Compare Two Directories

```cmd
jp old-version
dir

jp new-version
dir

jp -
# Compare with old version

jp -
# Back to new version
```

### Multi-Project Work

```cmd
# Morning: Start on project A
jp project-a
git pull
# Work...

# Need to check something in project B
jp project-b
git pull
# Quick check...

# Back to project A
jp -
# Continue working...

# Afternoon: Switch to project B
jp project-b
# Work...

# Quick reference to project A
jp -
# Check something...

# Back to project B
jp -
```

## Tips & Tricks

💡 **Quick toggle**: Hit up arrow and Enter to repeat `jp -`
```cmd
E:\> jp -
C:\> [UP ARROW] [ENTER]
E:\> [UP ARROW] [ENTER]
C:\>
```

💡 **Combine with other commands**:
```cmd
jp web && npm run dev
jp -
# Previous location, not back to before "jp web"!
```

💡 **First jump**: If you haven't jumped anywhere yet:
```cmd
C:\> jp -
No previous directory. Jump somewhere first!
```

💡 **Check where you'll go**: The previous location is saved in `%USERPROFILE%\.jump_previous`:
```cmd
type %USERPROFILE%\.jump_previous
```

## Troubleshooting

**"No previous directory"**
- You haven't jumped anywhere yet in this session
- Use `jp <name>` first to establish a previous location

**Previous directory doesn't exist**
- The directory was deleted or moved
- Clear it: `del %USERPROFILE%\.jump_previous`

**Not jumping to expected location**
- Previous location is from your last `jp <name>` or `jp -` command
- Not affected by regular `cd` commands
- Each `jp -` updates the previous location to where you just were

## Examples

### Example 1: Simple Toggle

```cmd
C:\> jp add home C:\Users\Me
C:\> jp add work E:\Work

C:\> jp work
Jumped to: E:\Work

E:\Work> jp home
Jumped to: C:\Users\Me

C:\Users\Me> jp -
Jumped back to: E:\Work

E:\Work> jp -
Jumped back to: C:\Users\Me

C:\Users\Me> jp -
Jumped back to: E:\Work
```

### Example 2: Three Locations

```cmd
C:\> jp a
E:\A> jp b
E:\B> jp c
E:\C> jp -
Jumped back to: E:\B

E:\B> jp -
Jumped back to: E:\C

E:\C> jp -
Jumped back to: E:\B

# Note: Location A is not in the toggle anymore!
# jp - only toggles between the last TWO locations
```

### Example 3: Mixed with CD

```cmd
C:\> jp web
E:\Web> cd src
E:\Web\src> cd components
E:\Web\src\components> jp -
Jumped back to: C:\

# Previous directory was C:\, not E:\Web\src
# Regular cd commands don't affect jp -
```

## See Also

- [README.md](README.md) - Main documentation
- [EXAMPLES.md](EXAMPLES.md) - More usage examples
- [QUICKSTART.md](QUICKSTART.md) - Getting started

---

**Happy toggling! 🔄**
