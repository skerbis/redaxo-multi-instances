# 🚀 REDAXO Multi-Instance Manager - Quick Start Beispiele

## Komplette Installation (5 Minuten)

```bash
# 1. Repository klonen
git clone https://github.com/skerbis/redaxo-multi-instances.git
cd redaxo-multi-instances

# 2. Automatisches Setup (installiert alles)
./setup.sh
# ✅ Installiert: Docker Desktop, Node.js, Dashboard, Dependencies

# 3. Dashboard öffnen
open http://localhost:3000
# ✅ Schönes Glass-Design Dashboard ist verfügbar
```

## Dashboard verwenden

### Neue REDAXO-Instanz erstellen:
1. Dashboard öffnen: http://localhost:3000
2. "Neue Instanz erstellen" klicken
3. Instanz-Name eingeben (z.B. "mein-projekt")
4. PHP-Version wählen (8.1, 8.2, 8.3, 8.4)
5. MariaDB-Version wählen
6. "Auto-Install REDAXO" aktivieren
7. "Erstellen" klicken
8. ✅ Instanz ist nach 1-2 Minuten verfügbar

### Instanz verwenden:
1. In der Instanz-Karte auf das "⋮" Menü klicken
2. "REDAXO Backend" wählen
3. Login: `admin` / `admin123`
4. ✅ REDAXO ist sofort einsatzbereit

## Kommandozeilen-Beispiele

### Schnelle Test-Instanz:
```bash
# REDAXO mit neuester PHP-Version erstellen
./redaxo create test --auto
# ✅ Verfügbar unter: http://localhost:8080

# Mit spezifischer PHP-Version
./redaxo create projekt-php81 --php-version 8.1 --auto
```

### Mehrere Projekte parallel:
```bash
# Kunde A - PHP 8.2
./redaxo create kunde-a --php-version 8.2 --port 8080 --auto

# Kunde B - PHP 8.4 
./redaxo create kunde-b --php-version 8.4 --port 8081 --auto

# Internes Projekt - PHP 8.3
./redaxo create intern --php-version 8.3 --port 8082 --auto

# Alle anzeigen
./redaxo list
```

### Instanz-Management:
```bash
# Instanz stoppen
./redaxo stop kunde-a

# Instanz starten
./redaxo start kunde-a

# Alle Instanzen stoppen
./redaxo stop-all

# Instanz löschen
./redaxo delete kunde-a
```

## Dashboard-Features nutzen

### Screenshots:
- 📸 **Automatisch:** Screenshots werden beim Erstellen/Starten erstellt
- 💾 **Persistent:** Bleiben sichtbar auch wenn Instanz gestoppt ist
- 🔄 **Manuell:** "Screenshot erstellen" Button in der Instanz-Karte

### Smart URL-Menü:
- 🌐 **Frontend:** Website-Vorschau
- ⚙️ **Backend:** REDAXO-Administration
- 📊 **Adminer:** Datenbank-Verwaltung
- 💻 **VS Code:** Öffnet Instanz direkt in VS Code

### Container-Informationen:
- 📊 **PHP-Version:** Aktuell verwendete PHP-Version
- 🗄️ **MariaDB-Version:** Datenbank-Version
- 🔌 **Port:** Aktuelle Port-Zuordnung
- ⚡ **Status:** Container-Status (läuft/gestoppt)

## Typische Workflows

### Agentur-Setup:
```bash
# Projekt-Template erstellen
./redaxo create template --php-version 8.4 --auto
# → REDAXO konfigurieren, AddOns installieren, Theme einrichten

# Kunden-Projekte basierend auf Template
./redaxo backup template
./import-dump kunde1 template_backup.zip
./import-dump kunde2 template_backup.zip
./import-dump kunde3 template_backup.zip
```

### Entwicklung & Testing:
```bash
# Development
./redaxo create projekt-dev --php-version 8.4 --port 8080 --auto

# Staging (Test)
./redaxo backup projekt-dev
./import-dump projekt-staging projekt-dev_backup.zip
./redaxo change-port projekt-staging 8081

# Production Preview
./import-dump projekt-prod live-dump.zip
./redaxo change-port projekt-prod 8082
```

### PHP-Kompatibilitätstests:
```bash
# Projekt auf verschiedenen PHP-Versionen testen
./redaxo backup mein-projekt

./import-dump test-php81 mein-projekt_backup.zip --php-version 8.1
./import-dump test-php82 mein-projekt_backup.zip --php-version 8.2  
./import-dump test-php83 mein-projekt_backup.zip --php-version 8.3
./import-dump test-php84 mein-projekt_backup.zip --php-version 8.4

# Dashboard öffnen → Alle Versionen parallel testen
```

## Troubleshooting Quick-Fixes

### Dashboard startet nicht:
```bash
# Port prüfen
lsof -i :3000

# Dashboard neu installieren
cd dashboard
rm -rf node_modules package-lock.json
npm install
npm start
```

### REDAXO-Instanz nicht erreichbar:
```bash
# Container-Status prüfen
docker ps

# Container neu starten
./redaxo stop INSTANZNAME
./redaxo start INSTANZNAME

# Logs prüfen
docker logs redaxo-INSTANZNAME
```

### Komplette Diagnose:
```bash
# Automatische Problemerkennung
./diagnose.sh

# Zeigt Status aller Komponenten und Empfehlungen
```

### Docker-Probleme:
```bash
# Docker Desktop neu starten
# → Docker Desktop App öffnen und neu starten

# Docker-Netzwerk neu erstellen
docker network rm redaxo-network
docker network create redaxo-network
```

## Performance-Tipps

### Docker-Optimierung:
- **Docker Desktop:** Mindestens 4GB RAM zuweisen
- **Container-Limits:** Werden automatisch gesetzt
- **Volume-Performance:** Verwendet Named Volumes für bessere Performance

### Dashboard-Performance:
- **Screenshots:** Werden asynchron erstellt (blockiert nicht)
- **Real-time Updates:** Effiziente Socket.IO-Verbindung
- **Caching:** Browser-Cache für statische Assets

### System-Performance:
```bash
# Nicht verwendete Container aufräumen
docker system prune

# Nicht verwendete Images löschen
docker image prune

# Logs begrenzen
docker system prune --volumes
```

## Nützliche Shortcuts

### Dashboard:
- **F5:** Seite neu laden
- **Cmd+R:** Seite aktualisieren
- **Cmd+Shift+I:** Entwicklertools (Browser)

### Terminal:
```bash
# Schneller Dashboard-Start
alias rd='cd ~/redaxo-multi-instances && ./dashboard-start'

# Diagnose-Shortcut
alias rdfix='cd ~/redaxo-multi-instances && ./diagnose.sh'

# Neue Instanz mit Standard-Einstellungen
alias rnew='cd ~/redaxo-multi-instances && ./redaxo create'
```

## Support

### Schnelle Hilfe:
1. **Diagnose ausführen:** `./diagnose.sh`
2. **Logs prüfen:** `cat dashboard.log`
3. **GitHub Issues:** Mit Diagnose-Output

### Community:
- **REDAXO Slack:** #entwicklung Channel
- **GitHub:** Issues und Discussions
- **Forum:** REDAXO Community Forum

---

**💡 Tipp:** Speichern Sie diese Datei als Lesezeichen für schnelle Referenz!
