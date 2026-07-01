# setup.ps1
$RepoRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
$UserHome = $HOME

$Mappings = @(
    @{ Source = Join-Path $RepoRoot ".config";      Target = Join-Path $UserHome ".config" }
    @{ Source = Join-Path $RepoRoot ".glzr";        Target = Join-Path $UserHome ".glzr" }
    @{ Source = Join-Path $RepoRoot ".oh-my-posh";  Target = Join-Path $UserHome ".oh-my-posh" }
    @{ Source = Join-Path $RepoRoot ".vscode";      Target = Join-Path $env:APPDATA "Code\User" }
    @{ Source = Join-Path $RepoRoot "powershell";   Target = Join-Path $UserHome "powershell" }
)

Get-Content .\vscode\extensions.txt | ForEach-Object {
    code --install-extension $_
}

function Copy-IfMissing {
    param([string]$Source, [string]$Target)

    if (!(Test-Path $Source)) {
        Write-Host "[WARN] Source introuvable : $Source" -ForegroundColor Yellow
        return
    }

    if (Test-Path $Target) {
        Write-Host "[SKIP] Existe déjà : $Target" -ForegroundColor DarkGray
        return
    }

    $Parent = Split-Path $Target -Parent
    if (!(Test-Path $Parent)) {
        New-Item -ItemType Directory -Path $Parent -Force | Out-Null
    }

    Copy-Item $Source $Target -Recurse -Force
    Write-Host "[OK] Copié : $Target" -ForegroundColor Green
}

Write-Host "=== Setup dotfiles ===" -ForegroundColor Cyan

foreach ($Map in $Mappings) {
    Copy-IfMissing -Source $Map.Source -Target $Map.Target
}

# PowerShell profile
$PwshDir = Join-Path $HOME "Documents\PowerShell"
$PwshProfile = Join-Path $PwshDir "Microsoft.PowerShell_profile.ps1"
$DotfileProfile = Join-Path $RepoRoot "powershell\profile.ps1"

if (!(Test-Path $PwshDir)) {
    New-Item -ItemType Directory -Path $PwshDir -Force | Out-Null
}

if (!(Test-Path $PwshProfile)) {
    New-Item -ItemType File -Path $PwshProfile | Out-Null
}

$content = Get-Content $PwshProfile -Raw -ErrorAction SilentlyContinue
$profileContent = Get-Content $DotfileProfile -Raw

if ($content -notmatch [regex]::Escape($profileContent.Trim())) {
    Add-Content $PwshProfile "`n`n# Imported from dotfiles`n"
    Add-Content $PwshProfile $profileContent
    Write-Host "[OK] Profile PowerShell mis à jour" -ForegroundColor Green
}
else {
    Write-Host "[SKIP] Profile déjà configuré" -ForegroundColor DarkGray
}

# Neovim symlink
$nvimTarget = Join-Path $env:LOCALAPPDATA "nvim"
$nvimSource = Join-Path $RepoRoot "nvim"

if (!(Test-Path $nvimTarget)) {
    New-Item -ItemType SymbolicLink -Path $nvimTarget -Target $nvimSource | Out-Null
    Write-Host "[OK] Symlink Neovim créé" -ForegroundColor Green
}
else {
    Write-Host "[SKIP] Neovim déjà configuré" -ForegroundColor DarkGray
}

Write-Host "=== Setup terminé ===" -ForegroundColor Cyan