param(
    [string]$mode = "auto",
    [switch]$Force
)

# ===============================
# ANSI FIX (CRITIQUE)
# ===============================
if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSStyle.OutputRendering = "Ansi"
} else {
    $env:TERM = "xterm-256color"
}

# ===============================
# Paths - SOURCES (lecture seule, jamais écrites par ce script)
# ===============================
$scriptPath  = "$env:USERPROFILE\dotfiles\powershell\fastfetch"
$asciiStatic = "$scriptPath\ascii_static.txt"   # logo par défaut, figé
$pokeAscii   = "$scriptPath\pokemon_ascii.txt"  # logo pokemon, déjà coloré ANSI par pokemon.ps1
$configPath  = "$scriptPath\config.jsonc"
$quoteFile   = "$scriptPath\quotes.txt"

# ===============================
# Fichiers temporaires - UNIQUES par exécution
# Placés dans $env:TEMP (jamais dans le repo dotfiles) et nommés avec un
# GUID : deux terminaux ouverts en même temps ne se marchent plus jamais
# dessus, et une interruption du process ne laisse aucun fichier "source"
# corrompu (seuls des temp files jetables sont impactés).
# ===============================
$runId      = [System.Guid]::NewGuid().ToString("N").Substring(0, 8)
$tempConfig = Join-Path $env:TEMP "fastfetch_config_$runId.jsonc"
$tempAscii  = Join-Path $env:TEMP "fastfetch_ascii_$runId.txt"

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
$mode = $mode.ToLower()

# ===============================
# Choisir la source ASCII (jamais modifiée)
# ===============================
$needsColoring = $false

switch ($mode) {
    "pokemon" {
        if (!(Test-Path $pokeAscii) -or $Force) {
            & "$scriptPath\pokemon.ps1" -Force:$Force
        }
        $sourceAscii = $pokeAscii
        # Le pokemon récupéré est déjà coloré (codes ANSI 256 couleurs dans
        # le fichier lui-même) : on ne touche à rien, juste une copie brute.
    }
    { $_ -in @("ascii", "auto") } {
        $sourceAscii   = $asciiStatic
        $needsColoring = $true
    }
    default {
        Write-Host "❌ Mode inconnu : $mode"
        exit 1
    }
}

if (!(Test-Path $sourceAscii)) {
    Write-Host "❌ Fichier ASCII source introuvable : $sourceAscii"
    exit 1
}

# ===============================
# Générer le rendu dans le fichier temporaire (la source n'est jamais
# ouverte en écriture)
# ===============================
if ($needsColoring) {
    $ESC      = [char]27
    $fgGreen  = "$ESC[32m"
    $fgYellow = "$ESC[33m"
    $bgBlack  = "$ESC[40m"
    $reset    = "$ESC[0m"

    $asciiLines = Get-Content $sourceAscii

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

    [System.IO.File]::WriteAllLines($tempAscii, $colored, (New-Object System.Text.UTF8Encoding($false)))
} else {
    Copy-Item $sourceAscii $tempAscii -Force
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
# Charger config source (jamais modifiée) + construire le config temporaire
# ===============================
if (!(Test-Path $configPath)) {
    Write-Host "❌ Config introuvable: $configPath"
    exit 1
}

$bytes = [System.IO.File]::ReadAllBytes($configPath)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $bytes = $bytes[3..($bytes.Length - 1)]
}
$configContent = [System.Text.Encoding]::UTF8.GetString($bytes)
if ($configContent.Length -gt 0 -and [int][char]$configContent[0] -eq 65279) {
    $configContent = $configContent.Substring(1)
}
if ([string]::IsNullOrWhiteSpace($configContent)) {
    Write-Host "❌ Config vide !"
    exit 1
}

# Injecter le chemin vers le fichier de rendu temporaire (jamais la source)
$asciiPathForJson = $tempAscii -replace '\\', '/'
$configContent    = $configContent -replace "__ASCII_PATH__", $asciiPathForJson

# Injecter quote
if ($mode -in @("ascii", "auto") -and $lines.Count -gt 0) {

    $quoteEntries = @()
    for ($i = 0; $i -lt 2; $i++) {
        $quoteEntries += '{ "type": "custom", "format": " " }'
    }
    foreach ($line in $lines) {
        if ($line.Trim() -ne "") {
            $safe = $line -replace '"', '\"'
            $quoteEntries += '{ "type": "custom", "format": "\u275d \u001b[3m' + $safe + '\u001b[0m \u275e" }'
        }
    }
    $quoteBlock    = ($quoteEntries -join ",`n        ")
    $configContent = $configContent -replace "__QUOTE_BLOCK__", $quoteBlock
}
else {
    $configContent = $configContent -replace ",?\s*__QUOTE_BLOCK__\s*", ""
}

$utf8NoBom   = New-Object System.Text.UTF8Encoding $false
$outputBytes = $utf8NoBom.GetBytes($configContent)
if ($outputBytes.Length -ge 3 -and $outputBytes[0] -eq 0xEF -and $outputBytes[1] -eq 0xBB -and $outputBytes[2] -eq 0xBF) {
    $outputBytes = $outputBytes[3..($outputBytes.Length - 1)]
}
[System.IO.File]::WriteAllBytes($tempConfig, $outputBytes)

# ===============================
# RUN FASTFETCH
# ===============================
try {
    fastfetch -c $tempConfig
}
finally {
    # Plus aucun backup/restore nécessaire : on ne fait que nettoyer des
    # fichiers jetables, jamais les sources.
    Remove-Item $tempConfig -Force -ErrorAction SilentlyContinue
    Remove-Item $tempAscii  -Force -ErrorAction SilentlyContinue
}