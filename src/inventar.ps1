param([string]$Beispieldatei = (Join-Path $PSScriptRoot "../beispieldaten/inventar.json"))
$demoVerzeichnis = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "../beispieldaten"))
$dateipfad = [IO.Path]::GetFullPath($Beispieldatei)
if (-not $dateipfad.StartsWith($demoVerzeichnis + [IO.Path]::DirectorySeparatorChar, [StringComparison]::OrdinalIgnoreCase)) {
    throw "Nur eine Datei aus dem Beispieldatenordner dieses Projekts verwenden."
}
$datensaetze = Get-Content -LiteralPath $dateipfad -Raw -Encoding UTF8 | ConvertFrom-Json
Write-Output ("P08: {0} Datensaetze eingelesen; Rechtepruefung noch offen. Kein echtes System untersucht." -f @($datensaetze).Count)
# P08-T02: Daten mit den Regeln vergleichen, ohne Zugriffsrechte zu veraendern.
