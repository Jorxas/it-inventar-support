$ErrorActionPreference = 'Stop'
$projektordner = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Bestaetigen([bool]$Bedingung, [string]$Meldung) {
    if (-not $Bedingung) { throw $Meldung }
}

# Nur diese drei benannten Dateien lesen; Inventarpfade bleiben reine Daten.
$eingelesen = Get-Content -LiteralPath (Join-Path $projektordner 'beispieldaten/inventar.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$inventar = @($eingelesen)
$regeln = Get-Content -LiteralPath (Join-Path $projektordner 'regeln.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$konfiguration = Get-Content -LiteralPath (Join-Path $projektordner 'projekt.json') -Raw -Encoding UTF8 | ConvertFrom-Json

Bestaetigen ($inventar.Count -eq 2) 'Es werden genau zwei synthetische Datensaetze erwartet.'
Bestaetigen ($konfiguration.expectedRecords -eq 2 -and $konfiguration.fixture -ceq 'beispieldaten/inventar.json') 'Projektverweis oder erwartete Anzahl weicht ab.'
$felder = @('geraet', 'verantwortlich', 'pfad', 'gruppen', 'inaktiv')
foreach ($eintrag in $inventar) {
    $vorhandeneFelder = @($eintrag.PSObject.Properties.Name)
    Bestaetigen (@(Compare-Object $felder $vorhandeneFelder).Count -eq 0) 'Die Inventarfelder weichen vom dokumentierten Modell ab.'
    Bestaetigen ($eintrag.geraet -is [string] -and -not [string]::IsNullOrWhiteSpace($eintrag.geraet)) 'Eine Geraetekennung fehlt.'
    Bestaetigen ($null -eq $eintrag.verantwortlich -or ($eintrag.verantwortlich -is [string] -and -not [string]::IsNullOrWhiteSpace($eintrag.verantwortlich))) 'Zustaendigkeit muss Text oder der absichtliche Nullwert sein.'
    Bestaetigen ($eintrag.pfad -ceq 'beispieldaten/demo-dokumente') 'Ein nicht vorgesehener Demopfad ist eingetragen.'
    Bestaetigen ($eintrag.gruppen -is [array] -and $eintrag.gruppen.Count -gt 0) 'Eine Gruppenliste fehlt.'
    foreach ($gruppe in $eintrag.gruppen) {
        Bestaetigen ($gruppe -is [string] -and -not [string]::IsNullOrWhiteSpace($gruppe)) 'Ein Gruppenname fehlt.'
    }
    Bestaetigen ($eintrag.inaktiv -is [bool]) 'Das Inaktivitaetskennzeichen muss boolesch sein.'
}
Bestaetigen (@($inventar.geraet | Select-Object -Unique).Count -eq 2) 'Die Geraetekennungen sind nicht eindeutig.'
$regelfelder = @('erlaubteGruppen', 'verantwortlicherErforderlich', 'inaktivesKontoPruefen', 'modus')
Bestaetigen (@(Compare-Object $regelfelder @($regeln.PSObject.Properties.Name)).Count -eq 0) 'Die Regelangaben sind unvollstaendig oder erweitert.'
Bestaetigen ($regeln.erlaubteGruppen -is [array] -and ($regeln.erlaubteGruppen -join ',') -ceq 'demo-leser,demo-administratoren') 'Die erlaubten Gruppen weichen ab.'
Bestaetigen ($regeln.verantwortlicherErforderlich -is [bool] -and $regeln.verantwortlicherErforderlich) 'Die Zustaendigkeitsregel fehlt.'
Bestaetigen ($regeln.inaktivesKontoPruefen -is [bool] -and $regeln.inaktivesKontoPruefen) 'Die Inaktivitaetsregel fehlt.'
Bestaetigen ($regeln.modus -ceq 'nur-beispieldaten-lesen') 'Der vorgeschriebene Lesemodus fehlt.'

Write-Output ('PowerShell-Version: {0}' -f $PSVersionTable.PSVersion)
Write-Output 'Strukturpruefung bestanden: 2 Datensaetze, je 5 Felder, 4 Regelangaben; Projektverweis stimmt.'
Write-Output 'Nullwert als absichtlicher Datenfehler zugelassen. Inhaltliche Einordnung siehe README.md.'
Write-Output 'Keine Inventarpfade geoeffnet, keine ACLs oder Domaene untersucht oder veraendert.'
