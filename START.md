# Technischer Einstieg — P08

## P08-T01 nachvollziehen

Im Projektordner ausführen:

~~~powershell
powershell -NoProfile -File nachweise/P08-T01-pruefen.ps1
~~~

Prüft ausschließlich die Struktur der ausdrücklich benannten lokalen JSON-Dateien `beispieldaten/inventar.json`, `regeln.json` und `projekt.json`. Erwartet zwei synthetische Datensätze mit fünf Feldern, die dokumentierten Regeln und den Projekt-Lesepfad. Absichtlich fehlende Verantwortung bleibt erhalten. Der Prüfbeleg ist keine Implementierung der automatischen Rechteauswertung aus P08-T02.

Der Aufruf funktioniert auch aus einem anderen Arbeitsverzeichnis: Die Dateipfade werden relativ zum Prüfskript bestimmt. Keine Inventarpfade öffnen, keine ACLs auslesen oder ändern, keine AD-Befehle und keine Systemsuche.

## Einstiegspunkt ausführen

Voraussetzungen: PowerShell; Für die Basis ist keine echte Domäne erforderlich.

~~~powershell
powershell -NoProfile -File src/inventar.ps1
~~~

Das Startprogramm wertet die zwei unveränderten Beispieldatensätze mit `regeln.json` aus und erstellt bzw. ersetzt `ausgabe/rechtebericht.json`. Erwartet: drei Auffälligkeiten ausschließlich für DEMO-PC-02; DEMO-PC-01 ohne Meldung. Der Bericht enthält einen echten Erstellungszeitpunkt, Quelle, Anzahl, Meldungen und die Modellgrenze. Erfolg: Exitcode 0. Meldungen über absichtliche Datenauffälligkeiten sind kein Programmfehler.

Die Pfade werden aus dem Skriptort bestimmt; der Aufruf funktioniert auch aus einem anderen Arbeitsverzeichnis mit absolutem Skriptpfad. Der optionale Parameter `-Beispieldatei` erlaubt ausschließlich `beispieldaten/inventar.json` dieses Projekts. Andere Dateien werden vor dem Lesen abgewiesen. Der Bericht wird erst nach der Auswertung geschrieben. Eingaben, ACLs und Domäne werden nicht verändert; Demopfade werden nicht geöffnet.

## Lokale Abnahme — P08-T02

~~~powershell
powershell -NoProfile -File nachweise/P08-T02-pruefen.ps1
~~~

Tatsächlich ausgeführt mit Windows PowerShell **5.1.26100.9818**, ohne zusätzliche Module oder Domäne. Die Prüfung startet den Berichtslauf aus `nachweise`, prüft Anzahl, Zuordnung und Arten der Meldungen sowie den Gruppenhinweis `Jeder`. Als Fehlerfall wird ausschließlich die vorhandene lokale `regeln.json` über `-Beispieldatei` angeboten: erwarteter Exitcode 1 und unveränderter Bericht. SHA256 vorher/nachher bestätigt unveränderte Beispieldateien und Regeln. Gesamtabnahme: Exitcode 0.

Ausgaben: `nachweise/P08-T02-pruefung.txt`, `nachweise/P08-T02-beispieldaten-sha256.json`, `nachweise/P08-T02-rechtebericht.json`. Eine Wiederholung ersetzt diese Belege und den Laufbericht. Der korrigierte Startfehler der Wiederaufnahme ist separat in `nachweise/P08-T02-pruefung-fehlversuch.txt` erhalten.

Grenze: Nicht zugelassene Gruppennamen stehen für zu breite Beispielrechte; das Inaktivitätskennzeichen enthält keine Kontokennung. Keine echte ACL-Auswertung, AD-Administration oder NIS-2-Abnahme. Der freigegebene Endpunkt P08-T02 ist beendet. Weitere Tickets benötigen eine eigene Freigabe.

## Lokale Fallübung und Abnahme — P08-T03

Voraussetzung: vorhandene PowerShell, keine Domäne und keine zusätzlichen Module. Zuerst `nachweise/P08-T03-supportfaelle.md` lesen. Dann im Projektordner ausführen:

~~~powershell
powershell -NoProfile -File nachweise/P08-T03-pruefen.ps1
~~~

Tatsächlich ausgeführt unter Windows PowerShell **5.1.26100.9818**, Exitcode 0. Das Skript liest das feste Beispielinventar und `nachweise/P08-T03-szenarien.json`, wertet genau drei unabhängige Karten aus und prüft deren Voraussetzungen und Ergebniszustände. Erwartet: DNS-Fall im Modell behoben; Schreibzugriff bleibt verweigert und wird zur Entscheidung eskaliert; ausgeschalteter Rechner ist in der Nachkontrolle erreichbar. Die fehlende Pingantwort allein begründet dabei keine Diagnose; die Karte enthält zusätzlich den lokalen Ausschaltbefund.

Beobachtungen und Nachkontrollen sind vollständig vorgegeben und synthetisch. Das Skript stellt keine Netzverbindung her, fragt keine ACLs ab und ändert keine Rechte oder Geräte. Es automatisiert nur die lokale Fallauswertung, keine Produktdiagnose. Pfade sind relativ zum Skriptort aufgelöst. Der Skriptrumpf und die Fallbeschreibung erklären die Entscheidungen; das Inventar enthält weiterhin zwei Einträge ohne echte Konten oder ACLs.

Ausgaben: `nachweise/P08-T03-pruefung.txt` (Zeitpunkte, Laufzeitversion, drei bearbeitete Fälle) und `nachweise/P08-T03-beispieldaten-sha256.json` (unveränderte Beispieldaten, Regeln und Karten). Wiederholen ersetzt diese beiden Nachweise; vorhandene T01-/T02-Belege werden nicht überschrieben. Der begrenzte Endpunkt ist beendet, weitere Phasen benötigen eine eigene Freigabe. Lastenheftkriterien und Gesamtstatus werden hier nicht abgehakt.

## Technische Quellen

- [Python-CSV-Modul](https://docs.python.org/3/library/csv.html)
- [Offizielle Angular-CLI-Anleitung](https://angular.dev/tools/cli/setup-local)
- [WPF mit .NET](https://learn.microsoft.com/de-de/dotnet/desktop/wpf/get-started/create-app-visual-studio)

Vor dem Einbinden eines Frameworks dessen aktuelle offizielle Anleitung lesen.
