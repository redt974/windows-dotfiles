param(
    [string]$mode = "auto",
    [switch]$Force
)

# ===============================
# ANSI FIX (CRITIQUE)
# ===============================
$ESC = [char]27

if ($PSVersionTable.PSVersion.Major -ge 7) {
    $PSStyle.OutputRendering = "Ansi"
} else {
    $env:TERM = "xterm-256color"
}

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
# Charger config + Write temp (BYTES ONLY - PS5.1 safe)
# ===============================
if (!(Test-Path $configPath)) {
    Write-Host "❌ Config introuvable: $configPath"
    exit
}

$bytes = [System.IO.File]::ReadAllBytes($configPath)

# Strip UTF-8 BOM (EF BB BF)
if ($bytes.Length -ge 3 -and $bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and $bytes[2] -eq 0xBF) {
    $bytes = $bytes[3..($bytes.Length - 1)]
}

# Décoder en string SANS BOM
$configContent = [System.Text.Encoding]::UTF8.GetString($bytes)

# Strip U+FEFF si encore présent
if ($configContent.Length -gt 0 -and [int][char]$configContent[0] -eq 65279) {
    $configContent = $configContent.Substring(1)
}

if ([string]::IsNullOrWhiteSpace($configContent)) {
    Write-Host "❌ Config vide !"
    exit
}

# ===============================
# Injecter quote
# ===============================
if ($mode -in @("ascii", "auto") -and $lines.Count -gt 0) {

    $quoteEntries = @()

    # lignes vides
    for ($i = 0; $i -lt 2; $i++) {
        $quoteEntries += '{ "type": "custom", "format": " " }'
    }

    foreach ($line in $lines) {
        if ($line.Trim() -ne "") {
            $safe = $line -replace '"', '\"'
            $quoteEntries += '{ "type": "custom", "format": "\u275d \u001b[3m' + $safe + '\u001b[0m \u275e" }'
        }
    }

    $quoteBlock = ($quoteEntries -join ",`n        ")

    $configContent = $configContent -replace "__QUOTE_BLOCK__", $quoteBlock
}
else {
    # ⚠️ IMPORTANT : supprimer proprement la ligne
    $configContent = $configContent -replace ",?\s*__QUOTE_BLOCK__\s*", ""
}

# ===============================
# Write temp config - BYTES BRUTS, zéro trust PS5.1
# ===============================
$utf8NoBom = New-Object System.Text.UTF8Encoding $false
$outputBytes = $utf8NoBom.GetBytes($configContent)

# Vérification paranoïaque finale sur les bytes de sortie
if ($outputBytes.Length -ge 3 -and $outputBytes[0] -eq 0xEF -and $outputBytes[1] -eq 0xBB -and $outputBytes[2] -eq 0xBF) {
    $outputBytes = $outputBytes[3..($outputBytes.Length - 1)]
}

[System.IO.File]::WriteAllBytes($tempConfig, $outputBytes)

# ===============================
# Colorisation ASCII (FIX ANSI)
# ===============================
if ($mode -in @("ascii", "auto")) {

    $fgGreen  = "$ESC[32m"
    $fgYellow = "$ESC[33m"
    $bgBlack  = "$ESC[40m"
    $reset    = "$ESC[0m"

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

    [System.IO.File]::WriteAllLines(
        $asciiPath,
        $colored,
        (New-Object System.Text.UTF8Encoding($false))
    )
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