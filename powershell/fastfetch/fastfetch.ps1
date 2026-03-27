param(
    [string]$mode = "auto",
    [switch]$Force
)

# ===============================
# Paths
# ===============================
$scriptPath   = "$env:USERPROFILE\dotfiles\powershell\fastfetch"
$asciiPath    = "$scriptPath\ascii.txt"
$pokeAscii    = "$scriptPath\pokemon_ascii.txt"
$configPath   = "$scriptPath\config.jsonc"
$tempConfig   = "$scriptPath\config_temp.jsonc"
$quoteFile    = "$scriptPath\quotes.txt"

# ===============================
# Détection intelligente depuis args
# ===============================
if (-not $PSBoundParameters.ContainsKey('mode')) {
    foreach ($arg in $args) {
        switch ($arg.ToLower()) {
            "pokemon" { $mode = "pokemon" }
            "ascii"   { $mode = "ascii" }
            "auto"    { $mode = "auto" }
        }
    }
}

# ===============================
# Déterminer ASCII
# ===============================
switch ($mode.ToLower()) {

    "pokemon" {
        # Génère un nouveau Pokémon
        & "$scriptPath\pokemon.ps1"

        $tmpAscii = $pokeAscii
    }

    "ascii" { $tmpAscii = $asciiPath }
    "auto"  { $tmpAscii = $asciiPath }

    default {
        Write-Host "❌ Mode inconnu : $mode"
        exit
    }
}

# ===============================
# Vérifier ASCII
# ===============================
if (!(Test-Path $tmpAscii)) {
    Write-Host "❌ Fichier ASCII introuvable : $tmpAscii"
    exit
}

# ===============================
# Backup ASCII
# ===============================
$backupAscii = "$asciiPath.bak"
if (Test-Path $asciiPath) {
    Copy-Item $asciiPath $backupAscii -Force
}

# ===============================
# Copier ASCII si nécessaire
# ===============================
if ($tmpAscii -ne $asciiPath) {
    Copy-Item $tmpAscii $asciiPath -Force
}

# ===============================
# Charger quotes
# ===============================
$quote = ""
if (Test-Path $quoteFile) {
    $quotes = Get-Content $quoteFile | Where-Object { $_.Trim() -ne "" }
    if ($quotes.Count -gt 0) { $quote = (Get-Random $quotes).Trim() }
}

$quote = $quote -replace "\\n", "`n" -replace "\\t", "`t" -replace '\\"', '"'
$lines = $quote -split "`r?`n"

# ===============================
# Charger config
# ===============================
if (!(Test-Path $configPath)) {
    Write-Host "❌ Config introuvable: $configPath"
    exit
}

$configContent = Get-Content $configPath -Raw
if ([string]::IsNullOrWhiteSpace($configContent)) {
    Write-Host "❌ Config vide !"
    exit
}

# ===============================
# Injecter quote (PAS en pokemon)
# ===============================
if ($mode -in @("ascii", "auto")) {

    $quoteBlock = ""

    for ($i = 0; $i -lt 2; $i++) {
        $quoteBlock += '{ "type": "custom", "format": " " },'
    }

    foreach ($line in $lines) {
        if ($line.Trim() -ne "") {
            $lineBlock = $line -replace '"', '\"'
            $quoteBlock += '{ "type": "custom", "format": "❝ \u001b[3m' + $lineBlock + '\u001b[0m ❞" },'
        }
    }

    $configContent = $configContent -replace "__QUOTE_BLOCK__", $quoteBlock.TrimEnd(',')
}
else {
    $configContent = $configContent -replace "__QUOTE_BLOCK__", ""
}

# ===============================
# Write temp config
# ===============================
Set-Content -Path $tempConfig -Value $configContent -Encoding UTF8

# ===============================
# Colorisation (ASCII ONLY)
# ===============================
if ($mode -in @("ascii", "auto")) {

    $fgGreen  = "`e[32m"
    $fgYellow = "`e[33m"
    $bgBlack  = "`e[40m"
    $reset    = "`e[0m"

    $asciiLines = Get-Content $asciiPath

    $colored = foreach ($line in $asciiLines) {
        $newLine = ""
        foreach ($c in $line.ToCharArray()) {
            if ($c -match '[@%#]') {
                $newLine += "$bgBlack$fgGreen$c$reset"
            } else {
                $newLine += "$bgBlack$fgYellow$c$reset"
            }
        }
        $newLine
    }

    $colored | Set-Content $asciiPath -Encoding UTF8
}

# ===============================
# RUN FASTFETCH
# ===============================
try {
    fastfetch -c $tempConfig
}
finally {
    if (Test-Path $backupAscii) {
        Copy-Item $backupAscii $asciiPath -Force
        Remove-Item $backupAscii -Force
    }

    if (Test-Path $tempConfig) {
        Remove-Item $tempConfig -Force -ErrorAction SilentlyContinue
    }
}