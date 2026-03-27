param(
    [string]$mode = "ascii",
    [switch]$Force
)

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
        if (Test-Path $pokeAscii) {
            Copy-Item $pokeAscii $asciiPath -Force
        } else {
            & "$scriptPath\pokemon.ps1" -Force:$Force
            Copy-Item $pokeAscii $asciiPath -Force
        }
    }
    "auto" {
        # Par défaut, auto = ASCII classique
        & "$scriptPath\ascii.ps1" -mode "ascii" -Force:$Force
    }
    default {
        Write-Host "Mode inconnu : $mode"
    }
}