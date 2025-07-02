# 🔄 REDAXO Multi-Instance Manager - Update-Anleitung

## 📋 Überblick

Diese Anleitung erklärt, wie Sie Ihren bestehenden REDAXO Multi-Instance Manager aktualisieren können, **ohne alles neu aufsetzen zu müssen**.

## 🚀 Update-Optionen

### 1. **Vollständiges GitHub-Update (Empfohlen)**
```bash
./update-manager.sh
```
**Was passiert:**
- ✅ Lädt neueste Dateien vom GitHub-Repository herunter
- ✅ Backup der aktuellen Konfiguration
- ✅ System-Abhängigkeiten aktualisieren (Homebrew, Node.js)
- ✅ Dashboard-Pakete und Sicherheits-Updates
- ✅ Docker-System bereinigen und optimieren
- ✅ Script-Berechtigungen aktualisieren
- ✅ Neue Features hinzufügen

**Repository:** https://github.com/skerbis/redaxo-multi-instances

### 2. **Git-Update (für Git-Benutzer)**
```bash
./git-update.sh
```
**Für Benutzer die Git verwenden und ihre Änderungen verwalten möchten**

### 3. **Schnelles Update (nur das Wichtigste)**
```bash
./quick-update
```
**oder**
```bash
./update-manager.sh --quick
```

### 4. **Update über REDAXO-Hauptscript**
```bash
./redaxo system-update
```

## 🛠️ Spezifische Update-Bereiche

### **Dashboard aktualisieren**
```bash
cd dashboard
npm update
npm audit fix
```

### **Docker-System optimieren**
```bash
./maintenance.sh
```

### **Einzelne Instanz-Versionen aktualisieren**
```bash
# PHP-Version ändern
./redaxo update meine-instanz --php-version 8.4

# MariaDB-Version ändern  
./redaxo update meine-instanz --mariadb-version 11.0

# Beide gleichzeitig
./redaxo update meine-instanz --php-version 8.3 --mariadb-version 10.6
```

### **REDAXO-Downloader aktualisieren**
```bash
./redaxo-downloader.sh clean
./redaxo-downloader.sh check-latest
```

## 🎯 Was wird beim Update NICHT verändert

- ✅ **Bestehende Instanzen** bleiben unverändert
- ✅ **SSL-Zertifikate** werden beibehalten
- ✅ **Dashboard-Konfiguration** (.env) wird gesichert
- ✅ **Docker-Volumes** mit Ihren Daten bleiben erhalten
- ✅ **Backups** werden nicht gelöscht

## 📦 Update-Umfang im Detail

### **System-Ebene:**
- Homebrew-Pakete aktualisieren
- Node.js auf neueste LTS-Version
- Git und andere Tools
- Docker Desktop (automatisch)

### **Manager-Ebene:**
- Dashboard-Abhängigkeiten (npm packages)
- Sicherheits-Updates für npm
- Script-Berechtigungen
- Neue Features und Funktionen

### **Instanz-Ebene:**
- PHP-Versionen (7.4 → 8.4)
- MariaDB-Versionen (10.4 → 11.0)
- Docker-Images aktualisieren

## 🔄 Regelmäßige Wartung

### **Wöchentlich empfohlen:**
```bash
./maintenance.sh
```

### **Monatlich empfohlen:**
```bash
./update-manager.sh
```

### **Bei Bedarf:**
```bash
# Vollständige Diagnose
./diagnose.sh

# System-Status
./status.sh

# Docker-Probleme beheben
./redaxo cleanup
```

## 🚨 Notfall-Recovery

Falls ein Update Probleme verursacht:

### **1. Backup wiederherstellen**
```bash
# Backup-Ordner finden
ls -la backup-*

# Konfiguration wiederherstellen
cp backup-YYYYMMDD_HHMMSS/dashboard/.env dashboard/
cp -r backup-YYYYMMDD_HHMMSS/ssl/* ssl/
```

### **2. Container neu starten**
```bash
# Alle Container stoppen
docker stop $(docker ps -q --filter "name=redaxo-")

# Spezifische Instanz reparieren
./redaxo repair meine-instanz
```

### **3. Komplett-Neuinstallation (letzter Ausweg)**
```bash
# Nur wenn wirklich nötig!
./setup.sh
```

## � Update-Strategien

### **Für alle Benutzer (Empfohlen):**
```bash
./update-manager.sh
```
- Lädt immer die neueste Version vom GitHub-Repository
- Funktioniert ohne Git-Kenntnisse
- Preserviert alle wichtigen Konfigurationen

### **Für Git-Benutzer:**
```bash
./git-update.sh
```
- Verwendet Git Pull für Updates
- Erlaubt eigene Änderungen und Branches
- Automatisches Stashing bei uncommitted changes

### **Für Produktivumgebungen:**
1. **Backup erstellen:** `./redaxo backup meine-prod-instanz`
2. **Test-Update:** Erst an Test-Instanz testen
3. **Wartungsfenster:** Update außerhalb der Geschäftszeiten
4. **Monitoring:** Status nach Update prüfen

### **Für Entwicklungsumgebungen:**
1. **Direktes Update:** `./update-manager.sh`
2. **Neueste Features:** Immer aktuelle Versionen verwenden

## 🔍 Troubleshooting

### **Problem: Update-Manager nicht gefunden oder veraltet**
```bash
# Neueste Version herunterladen
curl -L -o update-manager.sh https://raw.githubusercontent.com/skerbis/redaxo-multi-instances/main/update-manager.sh
chmod +x update-manager.sh
./update-manager.sh
```

### **Problem: Git-Repository out of sync**
```bash
# Repository-Status zurücksetzen
git fetch origin
git reset --hard origin/main
./git-update.sh
```

### **Problem: Npm-Pakete können nicht aktualisiert werden**
```bash
cd dashboard
rm -rf node_modules package-lock.json
npm install
```

### **Problem: Docker-Container starten nicht**
```bash
# Docker-System zurücksetzen
docker system prune -f
./redaxo repair meine-instanz
```

### **Problem: Ports sind belegt**
```bash
# Verwendete Ports prüfen
./redaxo list
lsof -i :3000
```

## 📋 Update-Checkliste

**Vor dem Update:**
- [ ] Backup wichtiger Instanzen erstellen
- [ ] Dashboard läuft und ist erreichbar
- [ ] Docker Desktop läuft
- [ ] Keine wichtigen Arbeiten laufen

**Nach dem Update:**
- [ ] Dashboard neu starten: `./dashboard-start`
- [ ] Status prüfen: `./status.sh`
- [ ] Instanzen testen: URLs aufrufen
- [ ] Log-Dateien prüfen: `ls -la logs/`

## 🎉 Neue Features nach Update

Nach einem erfolgreichen Update haben Sie Zugriff auf:

- 🔧 **Verbesserte Version-Updates** im Dashboard
- 🚀 **Schnellere Update-Prozesse**
- 🛡️ **Automatische Sicherheits-Updates**
- 📊 **Erweiterte System-Diagnose**
- ⚡ **Quick-Update Shortcuts**

---

## 🆘 Support

Bei Problemen oder Fragen:

1. **Diagnose ausführen:** `./diagnose.sh`
2. **Logs prüfen:** `cat logs/error.log`
3. **System-Status:** `./status.sh`
4. **Komplett-Neuinstallation:** `./setup.sh` (nur als letzter Ausweg)

**💡 Tipp:** Verwenden Sie `./update-manager.sh` mindestens einmal im Monat für optimale Performance!
