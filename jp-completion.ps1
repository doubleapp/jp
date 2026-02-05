# JP Directory Jumper - PowerShell function and tab completion
# Dot-source this from your PowerShell profile:  . "path\jp-completion.ps1"

$script:JpScriptPath = Join-Path (Split-Path -Parent $MyInvocation.MyCommand.Path) "jp.ps1"

function jp {
    param(
        [Parameter(Position=0)][string]$Command,
        [Parameter(Position=1)][string]$Name,
        [Parameter(Position=2)][string]$Path
    )
    . $script:JpScriptPath @PSBoundParameters
}

# Helper: read shortcut names from jumplist file
function script:Get-JpShortcutNames {
    param([string]$Filter = '*')
    $jl = if ($env:JP_JUMPLIST) { $env:JP_JUMPLIST } else { Join-Path $env:USERPROFILE ".jump_directories" }
    if (Test-Path $jl) {
        Get-Content $jl | ForEach-Object {
            if ($_ -match '^(.+?)=') {
                $n = $matches[1]
                if ($n -like "$Filter") {
                    [System.Management.Automation.CompletionResult]::new($n, $n, 'ParameterValue', $n)
                }
            }
        }
    }
}

# Tab completion for first argument: shortcut names only
Register-ArgumentCompleter -CommandName jp -ParameterName Command -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    script:Get-JpShortcutNames -Filter "$wordToComplete*"
}

# Tab completion for second argument: shortcut names after "remove"
Register-ArgumentCompleter -CommandName jp -ParameterName Name -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    if ($fakeBoundParameters.Command -eq 'remove') {
        script:Get-JpShortcutNames -Filter "$wordToComplete*"
    }
}
