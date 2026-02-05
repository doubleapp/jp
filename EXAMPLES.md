# JP Usage Examples

## Real-World Scenarios

### Web Developer with Multiple Projects

```cmd
# Setup (one time only)
jp add client1 E:\Projects\ClientWebsite
jp add client2 E:\Projects\AnotherClient\website
jp add api E:\Projects\ClientWebsite\backend
jp add tools C:\DevTools

# Daily workflow
jp client1
code .
git pull
npm run dev

# Quick switch
jp api
npm test

# Check another project
jp client2
git status
```

### Data Scientist

```cmd
# Setup your projects
jp add research C:\Users\Me\Documents\Research
jp add data D:\Datasets
jp add models D:\ML_Models
jp add notebooks C:\Users\Me\Jupyter

# Switch between tasks
jp research
jp data
copy important_dataset.csv %temp%
jp models
python train.py

jp notebooks
jupyter notebook
```

### System Administrator

```cmd
# Setup common locations
jp add logs C:\Windows\System32\LogFiles
jp add scripts C:\AdminScripts
jp add iis C:\inetpub\wwwroot
jp add backups D:\Backups

# Quick navigation
jp logs
type *.log | findstr "ERROR"

jp scripts
.\backup_users.ps1

jp iis
dir /s *.aspx
```

### Game Developer

```cmd
# Setup project structure
jp add game E:\GameDev\MyGame
jp add assets E:\GameDev\MyGame\Assets
jp add scripts E:\GameDev\MyGame\Scripts
jp add builds E:\GameDev\Builds

# Daily workflow
jp game
git pull
jp scripts
code PlayerController.cs
jp builds
.\BuildGame.bat
```

## Advanced Usage

### Cross-Drive Navigation

```cmd
# Set up projects across multiple drives
jp add system-drive C:\Windows\System32
jp add ssd-project E:\FastProjects\WebApp
jp add hdd-backup D:\Backups
jp add network Z:\SharedProjects

# Jump between drives effortlessly
C:\Users\Me> jp ssd-project
Switching from C: to E:
Jumped to: E:\FastProjects\WebApp

E:\FastProjects\WebApp> jp hdd-backup
Switching from E: to D:
Jumped to: D:\Backups

D:\Backups> jp network
Switching from D: to Z:
Jumped to: Z:\SharedProjects

# No need to manually type drive letters or use /d flag - it's automatic!
```

### Toggle Between Two Directories

```cmd
# Working on frontend and backend simultaneously
jp web
# Make some changes...

jp api
# Make some changes...

jp -
# Back to web

jp -
# Back to api

jp -
# Back to web

# Keep toggling with "jp -" as you work!
```

### Combining with Other Commands

```cmd
# Jump and immediately run a command
jp web && npm start

# Jump, list files, and return
pushd $(jp web) && dir && popd

# Jump to multiple places in a script
@echo off
jp web
git pull
jp api
git pull
jp -
# Back to web
npm install
```

### Using in Batch Scripts

```batch
@echo off
REM Deploy script example

echo Deploying frontend...
jp web
call npm run build

echo Deploying backend...
jp api
call dotnet publish -c Release

echo Copying files...
jp deploy
xcopy /s /y ..\web\dist\* .\frontend\
xcopy /s /y ..\api\bin\Release\* .\backend\

echo Done!
```

### Project Templates

```cmd
# Create a new project structure
mkdir E:\Projects\NewProject
cd E:\Projects\NewProject
mkdir src tests docs

# Add to jump list immediately (current directory)
jp add newproj .
# OR
jp add newproj
jp add newproj-src E:\Projects\NewProject\src
jp add newproj-test E:\Projects\NewProject\tests
```

### Team Sharing

Share your jump list with team members:

```cmd
# Export your shortcuts
type %USERPROFILE%\.jump_directories > team-shortcuts.txt

# Team member imports:
type team-shortcuts.txt >> %USERPROFILE%\.jump_directories
```

## Workflow Patterns

### Morning Routine

```cmd
# Check all projects for updates
jp web && git pull
jp api && git pull
jp mobile && git pull

# Start working on main project
jp web
code .
npm run dev
```

### Quick Backup Workflow

```cmd
# Add temp location for quick access
jp add temp C:\Temp\WorkInProgress

jp web
xcopy /s /e /y .\src\* $(jp temp)\web-backup\

jp api
xcopy /s /e /y .\* $(jp temp)\api-backup\
```

### Multi-Drive Development

```cmd
# Different projects on different drives
jp add ssd-project C:\FastProjects\WebApp
jp add hdd-data D:\BigData\Analysis
jp add network-share \\server\shared\code

# Switch seamlessly
jp ssd-project
jp hdd-data
jp network-share
```

## Tips from Power Users

### Short Names for Speed
```cmd
jp add w E:\work\website
jp add a E:\work\api
jp add d E:\work\database
jp add t E:\work\testing

# Now just: jp w, jp a, jp d, jp t
```

### Organize by Context
```cmd
# Work projects
jp add work-main C:\Work\MainProject
jp add work-client C:\Work\ClientProject

# Personal projects
jp add personal-blog E:\Personal\Blog
jp add personal-game E:\Personal\GameDev

# Learning
jp add learn-python C:\Learning\Python
jp add learn-rust C:\Learning\Rust
```

### Combine with Environment Variables
```cmd
# Set up related tools
jp add project E:\MyProject
set PROJECT_HOME=E:\MyProject

# Use in scripts
jp project
%PROJECT_HOME%\tools\build.bat
```

## Common Mistakes to Avoid

❌ **Don't use spaces in shortcut names**
```cmd
jp add my project E:\Projects\Something  # Wrong!
jp add myproject E:\Projects\Something   # Correct
```

❌ **Don't forget to quote paths with spaces**
```cmd
jp add web E:\My Projects\Website        # Wrong!
jp add web "E:\My Projects\Website"      # Correct
```

✅ **Do use descriptive but short names**
```cmd
jp add w E:\Website                      # Too short, unclear
jp add website-main-production E:\...    # Too long
jp add web E:\Website                    # Just right
```

✅ **Do keep your list clean**
```cmd
# Remove old projects
jp remove oldproject

# Review periodically
jp list
```
