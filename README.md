# IT-Inventar und Zugriffsprüfung

Stand: 1. November 2026 — **P08-T01 abgeschlossen; automatische Rechteprüfung und weitere Basisphasen offen**. Geplanter Abschluss der Basis: 2026-11-06, spätestens 8. November 2026. Geschätzter Basisaufwand: 4 Stunden ohne Einrichtung und Erweiterungen.

Ein IT-Team möchte Geräte erfassen, zu weit gefasste Rechte finden und Supportabläufe beschreiben.

Ergebnis: Inventarprüfung auf Beispieldaten, Rechtebericht, drei Supportfälle und ein Risikoregister.

Vorgesehene Technologien: PowerShell, Windows/AD, Support, Data Governance, Security/GRC, Excel, Office/PowerPoint. Eine Nennung ist kein Nachweis einer Umsetzung.

## Einstieg

1. [Lastenheft](LASTENHEFT.md) lesen.
2. [Erstes Ticket](tickets/P08-T01.md) öffnen.
3. [Technischen Einstieg](START.md) prüfen und ein Ticket nach dem anderen bearbeiten.
4. [Arbeitsjournal](ARBEITSJOURNAL.md) und echte Nachweise aktualisieren.

Abhängigkeiten: keine weiteren Projekte.

## Inventar und Regeln — P08-T01

Die ausdrücklich ausgewählte Datenquelle ist `beispieldaten/inventar.json` mit unverändert zwei synthetischen Einträgen. `regeln.json` beschreibt die Sollregeln. Die Demo-Datei `beispieldaten/demo-dokumente/beispiel.txt` enthält nur einen Beispieltext; Inventarpfade sind Daten und werden nicht zum Durchsuchen eines Dateisystems verwendet.

| Feld | Bedeutung und Vollständigkeitsregel |
|---|---|
| `geraet` | Nicht leere, im Beispiel eindeutige Gerätekennung. |
| `verantwortlich` | Zuständiges synthetisches Team als nicht leerer Text; `null` kennzeichnet die absichtlich fehlende Verantwortung. |
| `pfad` | Projektbezogener relativer Demopfad; hier ausschließlich `beispieldaten/demo-dokumente`. Keine Netzwerkpfade oder Systempfade. |
| `gruppen` | Liste nicht leerer Gruppennamen, die mit der ausdrücklich erlaubten Liste verglichen werden sollen. |
| `inaktiv` | Boolesches Kennzeichen eines im Beispiel zu prüfenden inaktiven Kontos. Eine eigene Kontokennung fehlt; keine Aussage über ein reales Geräte- oder Benutzerkonto. |

| Gerät | Zuständigkeit | Demopfad | Eingetragene Gruppen | Inaktiv | Erwartete Einordnung für P08-T02 |
|---|---|---|---|---|---|
| DEMO-PC-01 | demo-team | beispieldaten/demo-dokumente | demo-leser | nein | Keine der drei vorgesehenen Auffälligkeiten. |
| DEMO-PC-02 | fehlt (`null`) | beispieldaten/demo-dokumente | Jeder | ja | Fehlende Verantwortung, nicht zugelassene Gruppe, Inaktivitätskennzeichen. |

Zulässige Gruppen sind exakt `demo-leser` und `demo-administratoren` (`erlaubteGruppen`). `Jeder` gehört nicht dazu und dient als absichtlicher Fehlerfall. `verantwortlicherErforderlich: true` und `inaktivesKontoPruefen: true` decken die beiden weiteren vorgesehenen Auffälligkeiten ab. `modus: "nur-beispieldaten-lesen"` begrenzt den Ablauf. Gruppen werden als synthetische Namen betrachtet; ihre echten Mitgliedschaften und Berechtigungen werden weder ermittelt noch verändert.

Die manuelle Vollständigkeitsprüfung ergibt: Alle fünf Felder sind in beiden Datensätzen vorhanden; die Zuständigkeit des zweiten Datensatzes ist absichtlich inhaltlich unvollständig. Die vier Regelangaben decken die drei vorgesehenen Auffälligkeiten und den Lesemodus ab. Zugriffsstufen wie Lesen/Schreiben, eine Kontozuordnung und eine tatsächliche ACL-Auswertung sind nicht modelliert. Die Zulassung von `demo-administratoren` ist eine Vorgabe des Beispiels und kein Nachweis angemessener Produktivrechte.

Die tatsächliche Strukturprüfung und der vorhandene Einstieg wurden ausgeführt; Anleitung und Nachweise stehen in [START.md](START.md) und [nachweise/P08-T01-pruefung.txt](nachweise/P08-T01-pruefung.txt). Der Einstieg liest zwei Datensätze und meldet ausdrücklich, dass die Rechteprüfung noch offen ist. Übergreifende Lastenheftkriterien bleiben offen. Weder AD-Administration noch NIS-2-Konformität oder menschliche Eigenleistung werden damit belegt.

[Erweiterungen](VARIANTEN.md) haben einen eigenen Umsetzungsstand. [Private Unternehmenszuordnung](UNTERNEHMEN.lokal.md) bleibt außerhalb der Git-Verwaltung.

## Projektsprache

Dokumentation, selbst gewählte Bezeichner, Kommentare, Meldungen und Beispieldaten werden auf Deutsch geschrieben. Festgelegte API-Schlüssel, Sprachsyntax und Produktnamen bleiben unverändert.
