# ===============================
# Base paths
# ===============================
$DOTFILES   = "$HOME\dotfiles"
$PS_ROOT    = "$DOTFILES\powershell"
$PS_MODULES = "$PS_ROOT\modules"
$POSH_CFG   = "$DOTFILES\.oh-my-posh\atomic.omp.json"
$FASTFETCH  = "$DOTFILES\powershell\fastfetch\config.jsonc"

# ===============================
# Encoding
# ===============================
[Console]::InputEncoding  = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.UTF8Encoding]::new($false)

# ===============================
# Load personal modules
# ===============================
if (Test-Path $PS_MODULES) {
    Get-ChildItem $PS_MODULES -Directory | ForEach-Object {
        Import-Module $_.FullName -Force -ErrorAction SilentlyContinue
    }
}

# ===============================
# UI
# ===============================
if (Get-Command oh-my-posh.exe -ErrorAction SilentlyContinue) {
    oh-my-posh.exe init pwsh --config="$POSH_CFG" | Invoke-Expression
}

Import-Module Terminal-Icons -ErrorAction SilentlyContinue

# ===============================
# Aliases
# ===============================

function ls { Get-ChildItem @args }
function ld { Get-ChildItem -Directory @args }
function lh { Get-ChildItem -Hidden @args }
function tree { tree.exe @args }
function htop { ntop.exe @args }

# fzf from current directory with full path output
function fzf {
    fd.exe |
        fzf.exe |
        ForEach-Object { (Get-Item $_).FullName }
}

# OpenJarvis command
function jarvis {
    param(
        [Parameter(Position=0)]
        [string]$command,

        [Parameter(ValueFromRemainingArguments=$true)]
        $args
    )

    Push-Location "C:\Program Files\OpenJarvis"
    try {

        # Si aucun argument → mode interactif
        if (-not $command) {
            $inputText = Read-Host "Jarvis (ask)"

            if ([string]::IsNullOrWhiteSpace($inputText)) {
                return
            }

            & uv run jarvis ask $inputText
            return
        }

        # sinon commande normale
        & uv run jarvis $command @args
    }
    finally {
        Pop-Location
    }
}

# ===============================
# Fastfetch ASCII art
# ===============================
if (Test-Path "$DOTFILES\powershell\fastfetch\fastfetch.ps1") {
    & "$DOTFILES\powershell\fastfetch\fastfetch.ps1" auto
}

# ===============================
# Fastfetch shortcuts
# ===============================
function ff {
    & "$DOTFILES\powershell\fastfetch\fastfetch.ps1" @args
}

function ff-ascii {
    & "$DOTFILES\powershell\fastfetch\fastfetch.ps1" ascii
}

function ff-pokemon {
    & "$DOTFILES\powershell\fastfetch\fastfetch.ps1" pokemon
}
