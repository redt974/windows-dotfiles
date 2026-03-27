$pokeAscii = "$env:USERPROFILE\dotfiles\powershell\fastfetch\pokemon_ascii.txt"

try {
    $number = Get-Random -Minimum 1 -Maximum 152
    $numberFormatted = "{0:D3}" -f $number

    $url = "https://raw.githubusercontent.com/shinya/pokemon-terminal-art/main/compact/256color/gold/$numberFormatted.txt"
    $content = (Invoke-WebRequest $url -UseBasicParsing).Content

    $content | Out-File -Encoding utf8 $pokeAscii
}
catch {
    Write-Host "❌ Erreur récupération Pokémon"
}