$ErrorActionPreference = 'Stop'
$projektordner = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$skriptpfad = Join-Path $projektordner 'src/inventar.ps1'
$berichtspfad = Join-Path $projektordner 'ausgabe/rechtebericht.json'
$protokollpfad = Join-Path $PSScriptRoot 'P08-T02-pruefung.txt'

function Bestaetigen([bool]$Bedingung, [string]$Meldung) {
    if (-not $Bedingung) { throw $Meldung }
}

function Eingabepruefsummen {
    foreach ($relativpfad in @('beispieldaten/inventar.json', 'beispieldaten/demo-dokumente/beispiel.txt', 'regeln.json')) {
        [pscustomobject]@{
            pfad = $relativpfad
            sha256 = (Get-FileHash -LiteralPath (Join-Path $projektordner $relativpfad) -Algorithm SHA256).Hash
        }
    }
}

Start-Transcript -LiteralPath $protokollpfad -Force | Out-Null
try {
    Write-Output ('Beginn: {0}; PowerShell: {1}' -f [DateTimeOffset]::Now.ToString('o'), $PSVersionTable.PSVersion)
    $vorher = @(Eingabepruefsummen)
    Write-Output 'Befehl: powershell -NoProfile -File src/inventar.ps1 (Arbeitsverzeichnis: nachweise)'
    Push-Location -LiteralPath $PSScriptRoot
    try {
        & powershell -NoProfile -File $skriptpfad
        Bestaetigen ($LASTEXITCODE -eq 0) 'Der Berichtslauf ist fehlgeschlagen.'
    } finally { Pop-Location }
    $bericht = Get-Content -LiteralPath $berichtspfad -Raw -Encoding UTF8 | ConvertFrom-Json
    Bestaetigen ($bericht.anzahlDatensaetze -eq 2 -and $bericht.anzahlMeldungen -eq 3) 'Erwartet: zwei Datensaetze, drei Meldungen.'
    Bestaetigen ($bericht.quelle -ceq 'beispieldaten/inventar.json' -and $bericht.modus -ceq 'nur-beispieldaten-lesen') 'Quelle oder Lesemodus weicht ab.'
    Bestaetigen (@($bericht.meldungen).Count -eq 3) 'Die Meldungsliste muss drei Eintraege enthalten.'
    Bestaetigen (@($bericht.meldungen | Where-Object { $_.geraet -cne 'DEMO-PC-02' }).Count -eq 0) 'Nur DEMO-PC-02 darf Meldungen erhalten.'
    $erwarteteArten = @('nicht-erlaubte-gruppe', 'fehlende-verantwortung', 'inaktivitaetskennzeichen')
    Bestaetigen (@(Compare-Object $erwarteteArten @($bericht.meldungen.art)).Count -eq 0) 'Die drei fachlichen Meldungsarten weichen ab.'
    Bestaetigen ($bericht.meldungen[0].meldung -cmatch 'Jeder') 'Die abgelehnte Gruppe muss benannt werden.'
    Write-Output 'Bestanden: DEMO-PC-01 ohne Meldung; DEMO-PC-02 mit Gruppe Jeder, fehlender Verantwortung und Inaktivitaetskennzeichen.'

    # Lokale Regeldatei als unzulaessige Inventareingabe; keine privaten Dateien.
    $berichtHash = (Get-FileHash -LiteralPath $berichtspfad -Algorithm SHA256).Hash
    $abweispfad = Join-Path $projektordner 'regeln.json'
    Write-Output 'Befehl: powershell -NoProfile -File src/inventar.ps1 -Beispieldatei <Projekt>/regeln.json'
    $alteFehlerbehandlung = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    $fehlerausgabe = & powershell -NoProfile -File $skriptpfad -Beispieldatei $abweispfad 2>&1
    $fehlercode = $LASTEXITCODE
    $ErrorActionPreference = $alteFehlerbehandlung
    Bestaetigen ($fehlercode -ne 0) 'Die unzulaessige Eingabe wurde nicht abgewiesen.'
    Bestaetigen (($fehlerausgabe | Out-String) -match 'Nur beispieldaten/inventar.json') 'Der erwartete Ablehnungsgrund fehlt.'
    Bestaetigen ((Get-FileHash -LiteralPath $berichtspfad -Algorithm SHA256).Hash -eq $berichtHash) 'Der Fehlerfall hat den Bericht veraendert.'
    Write-Output ('Bestanden: unzulaessige Eingabe vor dem Lesen abgewiesen, Exitcode {0}; Bericht unveraendert.' -f $fehlercode)

    $nachher = @(Eingabepruefsummen)
    Bestaetigen (($vorher | ConvertTo-Json -Compress) -ceq ($nachher | ConvertTo-Json -Compress)) 'Beispieldaten oder Regeln wurden veraendert.'
    [ordered]@{ vorher = $vorher; nachher = $nachher; unveraendert = $true } |
        ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'P08-T02-beispieldaten-sha256.json') -Encoding UTF8
    Copy-Item -LiteralPath $berichtspfad -Destination (Join-Path $PSScriptRoot 'P08-T02-rechtebericht.json') -Force
    Write-Output 'Bestanden: Eingabe-SHA256 vorher/nachher identisch; zwei Beispieldatensaetze erhalten.'
    Write-Output 'Pruefumfang: synthetische Gruppennamen und Kennzeichen, keine ACL-/AD-Auswertung.'
    Write-Output ('Abnahme bestanden: {0}' -f [DateTimeOffset]::Now.ToString('o'))
} finally { Stop-Transcript | Out-Null }
