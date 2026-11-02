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

Das vorhandene Startprogramm liest zwei Datensätze und meldet „Rechtepruefung noch offen“. Es erstellt noch keinen Rechtebericht. Tatsächlich verwendete PowerShell-Version und Befehlsausgaben: [P08-T01-pruefung.txt](nachweise/P08-T01-pruefung.txt). Fehlende Bibliotheken und Frameworks erst im passenden Ticket mit ihrer tatsächlichen Version ergänzen.

## Nächste Aufgabe

P08-T01 endet mit der dokumentierten Bestandsaufnahme. Erst in einer später freigegebenen Phase P08-T02 die schreibgeschützte Auswertung und den Bericht entwickeln.

## Technische Quellen

- [Python-CSV-Modul](https://docs.python.org/3/library/csv.html)
- [Offizielle Angular-CLI-Anleitung](https://angular.dev/tools/cli/setup-local)
- [WPF mit .NET](https://learn.microsoft.com/de-de/dotnet/desktop/wpf/get-started/create-app-visual-studio)

Vor dem Einbinden eines Frameworks dessen aktuelle offizielle Anleitung lesen.
