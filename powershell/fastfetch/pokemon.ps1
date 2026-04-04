$pokeAscii = "$env:USERPROFILE\dotfiles\powershell\fastfetch\pokemon_ascii.txt"

try {
    $number  = Get-Random -Minimum 1 -Maximum 650
    $numberFormatted = "{0:D3}" -f $number

    $url = "https://raw.githubusercontent.com/shinya/pokemon-terminal-art/main/compact/256color/bw/$numberFormatted.txt"
    $content = (Invoke-WebRequest $url -UseBasicParsing).Content

    $utf8NoBom = New-Object System.Text.UTF8Encoding $false
    [System.IO.File]::WriteAllText($pokeAscii, $content, $utf8NoBom)
}
catch {
    Write-Host "❌ Erreur récupération Pokémon : $_"
}