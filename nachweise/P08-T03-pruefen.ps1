$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$projektordner = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '..'))

function Bestaetigen([bool]$Bedingung, [string]$Meldung) {
    if (-not $Bedingung) { throw $Meldung }
}

function Eingabepruefsummen {
    foreach ($pfad in @('beispieldaten/inventar.json', 'beispieldaten/demo-dokumente/beispiel.txt', 'regeln.json', 'nachweise/P08-T03-szenarien.json')) {
        [pscustomobject]@{ pfad = $pfad; sha256 = (Get-FileHash -LiteralPath (Join-Path $projektordner $pfad) -Algorithm SHA256).Hash }
    }
}

Start-Transcript -LiteralPath (Join-Path $PSScriptRoot 'P08-T03-pruefung.txt') -Force | Out-Null
try {
    Write-Output ('Beginn: {0}; PowerShell: {1}' -f [DateTimeOffset]::Now.ToString('o'), $PSVersionTable.PSVersion)
    Write-Output 'Befehl: powershell -NoProfile -File nachweise/P08-T03-pruefen.ps1'
    Write-Output 'Reine Fallauswertung: vorgegebene Beobachtungen, keine Netzwerk- oder AD-Befehle.'
    $vorher = @(Eingabepruefsummen)
    $inventar = Get-Content -LiteralPath (Join-Path $projektordner 'beispieldaten/inventar.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $szenarien = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'P08-T03-szenarien.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    Bestaetigen (@($inventar).Count -eq 2) 'Erwartet: unveraendert zwei Inventareintraege.'
    Bestaetigen ($szenarien.modus -ceq 'vorgegebene-synthetische-beobachtungen') 'Nur die synthetische Falluebung ist freigegeben.'
    Bestaetigen (@($szenarien.faelle).Count -eq 3) 'Erwartet: genau drei Supportfaelle.'
    $erwarteteFaelle = @('netzwerk', 'zugriffsverweigerung', 'rechner-unerreichbar')
    Bestaetigen (@(Compare-Object $erwarteteFaelle @($szenarien.faelle.kennung)).Count -eq 0) 'Die drei vorgesehenen Fallarten muessen genau einmal vorkommen.'

    foreach ($fall in $szenarien.faelle) {
        Bestaetigen (@($inventar | Where-Object { $_.geraet -ceq $fall.geraet }).Count -eq 1) 'Fallgeraet muss eindeutig im Inventar vorkommen.'
        $anfang = $fall.vorher
        $ende = $fall.nachher
        Write-Output ('Fall: {0}; Geraet: {1}' -f $fall.kennung, $fall.geraet)
        switch -CaseSensitive ($fall.kennung) {
            'netzwerk' {
                Bestaetigen ($anfang.verbindung -and $anfang.gateway -and $anfang.dienstPerAdresse -and -not $anfang.namensaufloesung -and $anfang.dnsServer -cne $fall.sollDnsServer) 'Die Beobachtungen tragen die DNS-Diagnose nicht.'
                Write-Output 'Diagnose: Verbindung, Gateway und Dienst per Adresse verfuegbar; Namensaufloesung scheitert; DNS-Wert weicht vom Soll ab.'
                Write-Output 'Massnahme der Karte: freigegebenen DNS-Sollwert statt 192.0.2.54 verwenden, alten Wert fuer Rueckbau festhalten.'
                Bestaetigen ($ende.verbindung -and $ende.gateway -and $ende.dienstPerAdresse -and $ende.namensaufloesung -and $ende.dnsServer -ceq $fall.sollDnsServer) 'DNS-Nachkontrolle fehlgeschlagen.'
                Write-Output 'Ergebnispruefung bestanden: DNS 192.0.2.53, Name aufloesbar und Dienst per Adresse weiterhin erreichbar; im Modell behoben.'
                Write-Output 'Eskalation: bei fehlender Freigabe oder weiterem DNS-Fehler an Netzwerkbetreuung mit Vorher-/Nachher-Befunden.'
            }
            'zugriffsverweigerung' {
                Bestaetigen ($anfang.dienstErreichbar -and $anfang.angemeldet -and $anfang.lesen -and -not $anfang.schreiben -and $anfang.gruppe -ceq 'demo-leser') 'Die Beobachtungen tragen die Diagnose fehlenden Schreibrechts nicht.'
                $geraet = $inventar | Where-Object { $_.geraet -ceq $fall.geraet }
                Bestaetigen (@($geraet.gruppen).Count -eq 1 -and $geraet.gruppen[0] -ceq $anfang.gruppe) 'Die Modellrolle muss zum Beispielinventar passen.'
                Write-Output 'Diagnose: Dienst erreichbar, Anmeldung und Lesen erfolgreich; Schreiben gemaess Modellrolle demo-leser verweigert.'
                Write-Output 'Massnahme der Karte: Schreibbedarf zur Freigabe weitergeben; keine Gruppen- oder ACL-Aenderung.'
                Bestaetigen ($ende.dienstErreichbar -and $ende.angemeldet -and $ende.lesen -and -not $ende.schreiben -and $ende.gruppe -ceq $anfang.gruppe) 'Ablehnung oder bestehender Lesezugriff wurde unerwartet veraendert.'
                Write-Output 'Ergebnispruefung bestanden: Lesen bleibt erlaubt, Schreiben bleibt verweigert, Gruppe unveraendert; Schreibbedarf offen.'
                Write-Output 'Eskalation: offene Freigabeentscheidung an Datenverantwortung; Ressource, Taetigkeit, Rolle und Testbefunde uebergeben. Konkrete Zustaendigkeit nicht modelliert.'
            }
            'rechner-unerreichbar' {
                Bestaetigen (-not $anfang.pingAntwort -and -not $anfang.dienstErreichbar -and -not $anfang.lokalEingeschaltet) 'Die zusaetzliche lokale Beobachtung zum Ausschaltzustand fehlt.'
                Write-Output 'Diagnose: Ping und Dienst ohne Antwort; lokale Sichtkontrolle bestaetigt ausgeschalteten Rechner. Ping allein reicht nicht.'
                Write-Output 'Massnahme der Karte: berechtigte Kontaktperson schaltet nach Abstimmung regulaer ein; kein erzwungener Neustart.'
                Bestaetigen ($ende.lokalEingeschaltet -and $ende.pingAntwort -and $ende.dienstErreichbar) 'Rechner-Nachkontrolle fehlgeschlagen.'
                Write-Output 'Ergebnispruefung bestanden: eingeschaltet, Ping und Dienst erreichbar; im Modell behoben. Inventarmeldungen bleiben bestehen.'
                Write-Output 'Eskalation: bei Einschaltfehler an Geraetebetreuung, bei verbleibendem Dienstfehler an Netzwerk-/Systembetreuung; ohne Kontaktperson zuerst Zustaendigkeit klaeren.'
            }
        }
    }

    $nachher = @(Eingabepruefsummen)
    Bestaetigen (($vorher | ConvertTo-Json -Compress) -ceq ($nachher | ConvertTo-Json -Compress)) 'Beispieldaten, Regeln oder Karten wurden veraendert.'
    [ordered]@{ vorher = $vorher; nachher = $nachher; unveraendert = $true } |
        ConvertTo-Json -Depth 4 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'P08-T03-beispieldaten-sha256.json') -Encoding UTF8
    Write-Output 'Bestanden: drei Faelle ausgewertet; zwei Inventareintraege sowie Eingabe-SHA256 unveraendert.'
    Write-Output 'Grenze: keine reale Diagnose, Reparatur, Rechteaenderung, AD-Administration oder Produktbeherrschung belegt.'
    Write-Output ('Abnahme bestanden: {0}' -f [DateTimeOffset]::Now.ToString('o'))
} finally { Stop-Transcript | Out-Null }
