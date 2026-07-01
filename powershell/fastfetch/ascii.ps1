param(
    [string]$mode = "ascii",
    [switch]$Force
)

# Utilitaire manuel : matérialise ascii.txt à partir des sources figées,
# pour un usage externe éventuel (autre outil, inspection, etc.).
# fastfetch.ps1 n'en a plus besoin : il génère son propre rendu temporaire.

$scriptPath = "$env:USERPROFILE\dotfiles\powershell\fastfetch"
$asciiPath  = "$scriptPath\ascii.txt"
$pokeAscii  = "$scriptPath\pokemon_ascii.txt"
$staticPath = "$scriptPath\ascii_static.txt"

switch ($mode) {
    "ascii" {
        if (!(Test-Path $asciiPath) -or $Force) {
            Copy-Item $staticPath $asciiPath -Force
        }
    }
    "pokemon" {
        if ((Test-Path $pokeAscii) -and -not $Force) {
            Copy-Item $pokeAscii $asciiPath -Force
        } else {
            & "$scriptPath\pokemon.ps1" -Force:$Force
            Copy-Item $pokeAscii $asciiPath -Force
        }
    }
    "auto" {
        & "$scriptPath\ascii.ps1" -mode "ascii" -Force:$Force
    }
    default {
        Write-Host "Mode inconnu : $mode"
    }
}