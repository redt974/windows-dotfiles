# ===============================
# Base paths
# ===============================
$DOTFILES   = "$HOME\dotfiles"
$PS_ROOT    = "$DOTFILES\powershell"
$PS_MODULES = "$PS_ROOT\modules"
$POSH_CFG   = "$DOTFILES\.oh-my-posh\atomic.omp.json"
$FASTFETCH  = "$DOTFILES\.config\fastfetch\config.jsonc"

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

if (Get-Command fastfetch -ErrorAction SilentlyContinue) {
    fastfetch -c "$FASTFETCH"
    #fastfetch
}