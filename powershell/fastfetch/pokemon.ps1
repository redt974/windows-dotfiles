param(
    [switch]$Force
)

$scriptPath = "$env:USERPROFILE\dotfiles\powershell\fastfetch"
$pokeAscii  = "$scriptPath\pokemon_ascii.txt"
$tempFile   = "$pokeAscii.tmp"

# Cache : on ne re-télécharge que si demandé explicitement ou si rien n'existe.
if ((Test-Path $pokeAscii) -and -not $Force) {
    return
}

try {
    $number          = Get-Random -Minimum 1 -Maximum 650
    $numberFormatted = "{0:D3}" -f $number
    $url             = "https://raw.githubusercontent.com/shinya/pokemon-terminal-art/main/compact/256color/bw/$numberFormatted.txt"

    $content = (Invoke-WebRequest $url -UseBasicParsing).Content

    # Ecriture atomique : on écrit d'abord dans un fichier .tmp, puis on
    # renomme. Move-Item sur le même volume est atomique côté NTFS, donc
    # si le process est tué pendant le téléchargement ou l'écriture,
    # pokemon_ascii.txt existant (le bon) n'est JAMAIS touché ni corrompu.
    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($tempFile, $content, $utf8NoBom)
    Move-Item -Path $tempFile -Destination $pokeAscii -Force
}
catch {
    Write-Host "❌ Erreur récupération Pokémon : $_"
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
}