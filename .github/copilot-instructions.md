# Plesk Dump to instance und kkorrekturen 

## Aufgabe 

### https

Alle Dienste sollen über https erreichbar sein.


### Erstellen Sie ein Skript, das eine Plesk-Dump-Datei auf einen Server überträgt und die Datenbank und die Website wiederherstellt.

- erweitere das System um die Möglichkeit, Plesk Dumps auf eine Instanz zu übertragen und dort zu entpacken.
- Die Lösung soll das dump.zip aus dem Ordner `plesk-dumps` entpacken und eine neue Instanz mit den Inhalten des Dumps erstellen.
- Es handelt sich um eine REDAXO Website
- Es soll erkennen ob es ich um eine moderne Struktur oder klassische Struktur handelt.
- Die Struktur soll automatisch erkannt werden und die entsprechenden Schritte ausgeführt werden.
- Erstellen der Instanz 
- Kopieren der Dateien 
- Import der Datenbank die in einer db.zip liegt im dump 
- config.yml der redaxo Website anpassen an den container also domain und Datenbank korrigieren
- Die Instanz soll über localhost mit entsprechendem port https://localhost:port erreichbar sein. so wie alle anderen Instanzen auch.
Alternativ
- Die Instanz soll alternativ über die Domain erreichbar sein, die in der config.yml hinterlegt ist. Falls möglich 




