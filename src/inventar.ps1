[CmdletBinding()]
param([string]$Beispieldatei)

$ErrorActionPreference = 'Stop'
$projektordner = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))
$inventarpfad = Join-Path $projektordner 'beispieldaten/inventar.json'
$regelpfad = Join-Path $projektordner 'regeln.json'
$ausgabeordner = Join-Path $projektordner 'ausgabe'
$berichtspfad = Join-Path $ausgabeordner 'rechtebericht.json'
if (-not $PSBoundParameters.ContainsKey('Beispieldatei')) {
    $Beispieldatei = $inventarpfad
}

# Genau diese Beispieldatei zulassen, bevor irgendeine Eingabe gelesen wird.
if (-not [string]::Equals([IO.Path]::GetFullPath($Beispieldatei),
        [IO.Path]::GetFullPath($inventarpfad), [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Nur beispieldaten/inventar.json dieses Projekts ist zugelassen.'
}

# Vorhandene Verknuepfungen koennten die festgelegten Dateigrenzen verlassen.
foreach ($pruefpfad in @($projektordner, (Join-Path $projektordner 'beispieldaten'),
        $inventarpfad, $regelpfad, $ausgabeordner, $berichtspfad)) {
    if (Test-Path -LiteralPath $pruefpfad) {
        $datei = Get-Item -LiteralPath $pruefpfad -Force
        if (($datei.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0) {
            throw 'Verknuepfungen sind fuer Eingaben und Bericht nicht zugelassen.'
        }
    }
}

$regeln = Get-Content -LiteralPath $regelpfad -Raw -Encoding UTF8 | ConvertFrom-Json
if ($regeln.modus -cne 'nur-beispieldaten-lesen' -or
        $regeln.erlaubteGruppen -isnot [array] -or $regeln.erlaubteGruppen.Count -eq 0 -or
        $regeln.verantwortlicherErforderlich -isnot [bool] -or
        $regeln.inaktivesKontoPruefen -isnot [bool]) {
    throw 'Die Regeln enthalten keinen gueltigen Beispiel-Lesemodus oder unvollstaendige Angaben.'
}
foreach ($gruppe in $regeln.erlaubteGruppen) {
    if ($gruppe -isnot [string] -or [string]::IsNullOrWhiteSpace($gruppe)) {
        throw 'Die erlaubten Gruppen muessen nicht leere Namen enthalten.'
    }
}
$eingelesen = Get-Content -LiteralPath $inventarpfad -Raw -Encoding UTF8 | ConvertFrom-Json
if ($eingelesen -isnot [array] -or $eingelesen.Count -eq 0) {
    throw 'Das Beispielinventar muss eine nicht leere Liste sein.'
}
$inventar = @($eingelesen)
$meldungen = @()
foreach ($eintrag in $inventar) {
    foreach ($feld in @('geraet', 'verantwortlich', 'pfad', 'gruppen', 'inaktiv')) {
        if ($eintrag.PSObject.Properties.Name -cnotcontains $feld) {
            throw ('Inventarfeld fehlt: {0}.' -f $feld)
        }
    }
    if ($eintrag.geraet -isnot [string] -or [string]::IsNullOrWhiteSpace($eintrag.geraet) -or
            ($null -ne $eintrag.verantwortlich -and $eintrag.verantwortlich -isnot [string]) -or
            $eintrag.pfad -cne 'beispieldaten/demo-dokumente' -or
            $eintrag.gruppen -isnot [array] -or $eintrag.inaktiv -isnot [bool]) {
        throw 'Ein Inventareintrag entspricht nicht dem dokumentierten Beispielmodell.'
    }
    # Der Demopfad bleibt ein Datenfeld und wird niemals geoeffnet.
    foreach ($gruppe in $eintrag.gruppen) {
        if ($gruppe -isnot [string] -or [string]::IsNullOrWhiteSpace($gruppe)) {
            throw 'Die Gruppenliste enthaelt einen ungueltigen Namen.'
        }
        if ($regeln.erlaubteGruppen -cnotcontains $gruppe) {
            $meldungen += [pscustomobject]@{
                geraet = $eintrag.geraet; art = 'nicht-erlaubte-gruppe'
                meldung = ('Gruppe {0} ist im Beispiel nicht zugelassen; Hinweis auf zu breite Rechte.' -f $gruppe)
            }
        }
    }
    if ($regeln.verantwortlicherErforderlich -and [string]::IsNullOrWhiteSpace($eintrag.verantwortlich)) {
        $meldungen += [pscustomobject]@{
            geraet = $eintrag.geraet; art = 'fehlende-verantwortung'; meldung = 'Eine Verantwortung fehlt.'
        }
    }
    if ($regeln.inaktivesKontoPruefen -and $eintrag.inaktiv) {
        $meldungen += [pscustomobject]@{
            geraet = $eintrag.geraet; art = 'inaktivitaetskennzeichen'
            meldung = 'Inaktives Konto im Beispiel gekennzeichnet; keine eigene Kontokennung vorhanden.'
        }
    }
}

$bericht = [ordered]@{
    projekt = 'P08'; modus = $regeln.modus
    erstelltAm = [DateTimeOffset]::Now.ToString('o')
    quelle = 'beispieldaten/inventar.json'; regeln = 'regeln.json'
    anzahlDatensaetze = $inventar.Count; anzahlMeldungen = $meldungen.Count
    meldungen = @($meldungen)
    grenze = 'Nur synthetische Daten. Keine ACL- oder AD-Pruefung; kein Nachweis von NIS-2-Konformitaet.'
}
if (-not (Test-Path -LiteralPath $ausgabeordner)) {
    New-Item -ItemType Directory -Path $ausgabeordner | Out-Null
}
$bericht | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $berichtspfad -Encoding UTF8
Write-Output ('P08: {0} Datensaetze, {1} Auffaelligkeiten. Bericht: ausgabe/rechtebericht.json' -f $inventar.Count, $meldungen.Count)
Write-Output $bericht.grenze
