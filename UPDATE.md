# 🔄 REDAXO Multi-Instance Manager - Update Guide

![Version](https://img.shields.io/badge/Update-Guide-success?style=for-the-badge)

**So aktualisieren Sie Ihren REDAXO Multi-Instance Manager auf die neueste Version**

---

## 📋 Inhaltsverzeichnis

- [Vor dem Update](#-vor-dem-update)
- [Update durchführen](#-update-durchführen)
- [Nach dem Update](#-nach-dem-update)
- [Rollback bei Problemen](#-rollback-bei-problemen)
- [Version prüfen](#-version-prüfen)

---

## ⚠️ Vor dem Update

### 1. Backup erstellen

```bash
# Alle Instanzen stoppen
./manager stop-all

# Backup erstellen (empfohlen)
./snapshot.sh
```

### 2. Aktuelle Version notieren

```bash
# Aktuelle Version in einer Datei speichern (für Rollback)
echo "$(date): Backup vor Update" > version_backup.txt
./manager --version >> version_backup.txt 2>/dev/null || echo "Version unbekannt" >> version_backup.txt
```

### 3. Laufende Services prüfen

```bash
# Status aller Instanzen prüfen
./status.sh

# Dashboard-Status prüfen
./dashboard-pm2 status
```

---

## 🚀 Update durchführen

> **⚠️ Wichtig**: Es gibt keine automatischen Updates! Sie müssen die neue Version komplett herunterladen und Ihre Daten manuell übertragen.

### 📦 Was muss gesichert werden?

Diese Ordner enthalten Ihre Daten und müssen gesichert werden:

- **`instances/`** - Alle Ihre REDAXO-Instanzen mit Datenbanken
- **`ssl/`** - SSL-Zertifikate für HTTPS
- **`backups/`** - Ihre Snapshot-Backups

### Schritt 1: Alle Services stoppen

```bash
# 1. Alle Instanzen stoppen
./manager stop-all

# 2. Dashboard stoppen
./dashboard-pm2 stop
```

### Schritt 2: Wichtige Daten sichern

```bash
# Sichere Daten auf Desktop (mit Datum)
cp -r instances/ ~/Desktop/instances_backup_$(date +%Y%m%d_%H%M%S)/
cp -r ssl/ ~/Desktop/ssl_backup_$(date +%Y%m%d_%H%M%S)/
cp -r backups/ ~/Desktop/backups_backup_$(date +%Y%m%d_%H%M%S)/

# Bestätigung der Sicherung
echo "✅ Gesichert:"
ls -la ~/Desktop/*backup*
```

### Schritt 3: Neue Version herunterladen

```bash
# 1. Ins übergeordnete Verzeichnis wechseln
cd ..

# 2. Altes Verzeichnis umbenennen (als Fallback)
mv redaxo-multi-instances redaxo-multi-instances_old_$(date +%Y%m%d)

# 3. Neue Version herunterladen
curl -L https://github.com/skerbis/redaxo-multi-instances/archive/main.zip -o redaxo-multi-instances.zip

# 4. Entpacken
unzip redaxo-multi-instances.zip
mv redaxo-multi-instances-main redaxo-multi-instances
rm redaxo-multi-instances.zip

# 5. In neues Verzeichnis wechseln
cd redaxo-multi-instances
```

### Schritt 4: Gesicherte Daten wiederherstellen

```bash
# Gesicherte Ordner in neue Version kopieren
cp -r ~/Desktop/instances_backup_*/. ./instances/
cp -r ~/Desktop/ssl_backup_*/. ./ssl/
cp -r ~/Desktop/backups_backup_*/. ./backups/

# Berechtigungen setzen
chmod +x *.sh
chmod +x manager
```

### Schritt 5: Setup ausführen

```bash
# Komplettes Setup für neue Version
./setup.sh

# Bei Problemen: Setup forcieren
./setup.sh --force
```

### 🖱️ Alternative: Manueller Download (für weniger Terminal-Erfahrene)

1. **Neue Version herunterladen:**
   - Gehen Sie zu: https://github.com/skerbis/redaxo-multi-instances
   - Klicken Sie auf **"Code"** → **"Download ZIP"**
   - Entpacken Sie die ZIP-Datei

2. **Daten sichern:**
   - Kopieren Sie aus Ihrem **alten** `redaxo-multi-instances` Ordner:
     - `instances/` → auf Desktop
     - `ssl/` → auf Desktop  
     - `backups/` → auf Desktop

3. **Alte Version ersetzen:**
   - Benennen Sie Ihren alten `redaxo-multi-instances` Ordner um (z.B. `redaxo-multi-instances_alt`)
   - Verschieben Sie den **neuen** entpackten Ordner an die gleiche Stelle
   - Benennen Sie ihn zu `redaxo-multi-instances` um

4. **Daten wiederherstellen:**
   - Kopieren Sie die gesicherten Ordner (`instances/`, `ssl/`, `backups/`) in den neuen `redaxo-multi-instances` Ordner

5. **Setup ausführen:**
   ```bash
   cd redaxo-multi-instances
   ./setup.sh
   ```

---

## ✅ Nach dem Update

### 1. Services neustarten

```bash
# Dashboard neustarten
./dashboard-pm2 restart

# Alle Instanzen neustarten
./manager restart-all
```

### 2. Update verifizieren

```bash
# Dashboard testen
open http://localhost:3000

# Status aller Services
./status.sh

# Manager-Version prüfen (falls verfügbar)
./manager --version || echo "Update erfolgreich - Manager läuft"
```

### 3. Neue Features testen

```bash
# Hilfe anzeigen (zeigt neue Commands)
./manager --help

# Dashboard Features testen
# - Neue Instanz erstellen
# - Bestehende Instanz starten/stoppen
```

---

## 🔙 Rollback bei Problemen

Falls nach dem Update Probleme auftreten:

### Option 1: Zurück zur alten Version

```bash
# 1. Services stoppen
./manager stop-all
./dashboard-pm2 stop

# 2. Daten aus neuer Version sichern (falls neue Instanzen erstellt)
cp -r instances/ ~/Desktop/instances_new_backup/

# 3. Alte Version wiederherstellen
cd ..
mv redaxo-multi-instances redaxo-multi-instances_problematisch
mv redaxo-multi-instances_old_* redaxo-multi-instances
cd redaxo-multi-instances

# 4. Services wieder starten
./dashboard-pm2 start
./manager start-all
```

### Option 2: Gesicherte Daten wiederherstellen

```bash
# Falls nur die Daten das Problem sind
cp -r ~/Desktop/instances_backup_*/. ./instances/
cp -r ~/Desktop/ssl_backup_*/. ./ssl/

# Services neustarten
./manager restart-all
./dashboard-pm2 restart
```

---

## 🏷️ Version prüfen

### Neue Version verifizieren

```bash
# Manager-Version prüfen (falls verfügbar)
./manager --version || echo "Manager läuft"

# Dashboard testen
open http://localhost:3000

# Letzte Änderung am System anzeigen
ls -la | head -10
```

### Updates verfügbar?

Prüfen Sie regelmäßig auf GitHub:
- **[GitHub Repository](https://github.com/skerbis/redaxo-multi-instances)** - Neue Releases
- **[Releases Seite](https://github.com/skerbis/redaxo-multi-instances/releases)** - Download neuer Versionen

---

## 🆕 Was ist neu?

### Nach jedem Update lesen:

- **[CHANGELOG.md](CHANGELOG.md)** - Detaillierte Änderungen
- **[README.md](README.md)** - Neue Features und Dokumentation
- **[GitHub Releases](https://github.com/skerbis/redaxo-multi-instances/releases)** - Release Notes

### Wichtige Änderungen beachten:

- **Breaking Changes** - Können manuelle Anpassungen erfordern
- **Neue Dependencies** - Werden automatisch installiert
- **Neue Commands** - Erweitern die Funktionalität
- **Security Updates** - Sollten sofort installiert werden

---

## 📝 Update-Protokoll

### Update dokumentieren:

```bash
# Update-Log erstellen
echo "$(date): Update durchgeführt - Version von GitHub heruntergeladen" >> update.log
echo "Instances gesichert: $(ls ~/Desktop/*backup* 2>/dev/null | wc -l) Backups" >> update.log
```

### ⚠️ Hinweis zu automatischen Updates

Automatische Updates sind **nicht empfohlen**, da:
- Ihre Instanz-Daten könnten überschrieben werden
- Manuelle Kontrolle über den Update-Prozess ist sicherer
- Sie sollten Updates zunächst in einer Test-Umgebung prüfen

---

## 🚨 Troubleshooting

### Häufige Update-Probleme:

1. **Daten verschwunden**
   ```bash
   # Gesicherte Daten wiederherstellen
   cp -r ~/Desktop/instances_backup_*/. ./instances/
   cp -r ~/Desktop/ssl_backup_*/. ./ssl/
   ./manager restart-all
   ```

2. **Permission-Probleme**
   ```bash
   sudo chown -R $(whoami) .
   chmod +x *.sh
   chmod +x manager
   ```

3. **Docker-Probleme**
   ```bash
   docker system prune -f
   ./manager restart-all
   ```

4. **Dashboard lädt nicht**
   ```bash
   cd dashboard
   rm -rf node_modules package-lock.json
   npm install
   cd ..
   ./dashboard-pm2 restart
   ```

5. **Setup schlägt fehl**
   ```bash
   # Setup mit Force-Option
   ./setup.sh --force
   
   # Oder Docker komplett neu starten
   docker system prune -af
   ./setup.sh
   ```

---

## 💡 Pro-Tipps

- **Regelmäßige Updates**: Einmal pro Woche prüfen
- **Test-Umgebung**: Updates erst in Test-Instanz testen
- **Backup-Strategie**: Vor jedem größeren Update
- **Watch-Repository**: GitHub-Benachrichtigungen aktivieren
- **Issues verfolgen**: Bei Problemen GitHub Issues checken

---

## 📞 Support

Bei Update-Problemen:

1. **[GitHub Issues](https://github.com/skerbis/redaxo-multi-instances/issues)** - Probleme melden
2. **[REDAXO Slack](https://redaxo.org/slack/)** - Community-Support
3. **Dokumentation prüfen** - README.md und Wiki

---

**✨ Immer aktuell bleiben für die beste Performance und neueste Features!**
