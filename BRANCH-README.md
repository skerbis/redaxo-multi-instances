# 🔄 Update Manager Branch - Feature Development

## 📋 Überblick

Dieser Branch (`feature/update-manager`) enthält eine umfassende Update-Lösung für den REDAXO Multi-Instance Manager.

## 🎯 Entwickelte Features

### **Haupt-Scripts:**
- `update-manager.sh` - Hauptupdate-Script mit GitHub-Integration
- `git-update.sh` - Git-basiertes Update für Entwickler
- `quick-update` - Schnelles Update-Script
- `dashboard/update-dashboard.sh` - Dashboard-spezifisches Update

### **Dokumentation:**
- `UPDATE-GUIDE.md` - Vollständige Update-Anleitung
- Erweiterte Hilfe in allen Scripts

### **Erweiterte Scripts:**
- `redaxo` - Erweitert um `system-update` Befehl
- `maintenance.sh` - Erweitert um Manager-Update-Checks

## 🚀 Hauptfunktionen

### **GitHub-Integration:**
- Lädt automatisch die neueste Version vom Repository
- Preserviert bestehende Konfigurationen
- Intelligente Backup-Erstellung

### **Sicherheit:**
- Automatische Backups vor Updates
- Rollback-Optionen
- Test-Modus für sichere Updates

### **Benutzerfreundlichkeit:**
- Multiple Update-Strategien
- Interaktive Bestätigungen
- Umfassende Fehlerbehandlung

## 🛠️ Testing

### **Alle Update-Modi testen:**
```bash
# Test-Update (simuliert, keine Änderungen)
./update-manager.sh --test

# Schnelles Update
./update-manager.sh --quick

# Vollständiges Update
./update-manager.sh

# Git-Update (falls .git vorhanden)
./git-update.sh

# Dashboard-Update
cd dashboard && ./update-dashboard.sh
```

### **Rollback testen:**
```bash
# Backup-Verzeichnisse anzeigen
ls -la backup-*

# Konfiguration wiederherstellen
cp backup-*/dashboard/.env dashboard/
```

## 📦 Branch-Status

### **Neue Dateien:**
- ✅ `update-manager.sh` - Hauptupdate-Script
- ✅ `git-update.sh` - Git-Update-Script  
- ✅ `UPDATE-GUIDE.md` - Umfassende Dokumentation
- ✅ `dashboard/update-dashboard.sh` - Dashboard-Update
- ✅ `BRANCH-README.md` - Diese Datei

### **Modifizierte Dateien:**
- ✅ `redaxo` - Erweitert um system-update
- ✅ `maintenance.sh` - Manager-Update-Checks

### **Preservierte Funktionalität:**
- ✅ Alle bestehenden Features funktionieren weiterhin
- ✅ Bestehende Instanzen bleiben unverändert
- ✅ Konfigurationen werden bewahrt

## 🔀 Branch-Management

### **Aktueller Branch:**
```bash
git branch  # * feature/update-manager
```

### **Zwischen Branches wechseln:**
```bash
# Zurück zum main branch
git checkout main

# Zurück zum feature branch
git checkout feature/update-manager
```

### **Updates vom main branch holen:**
```bash
git checkout main
git pull origin main
git checkout feature/update-manager
git merge main
```

## 🎉 Bereit für Merge

Diese Update-Lösung ist vollständig getestet und bereit für den Merge in den main branch:

### **Vorteile:**
- 🔄 Automatische Updates vom GitHub-Repository
- 💾 Sichere Backup-Erstellung
- 🛡️ Preservierung aller Benutzerdaten
- 📚 Umfassende Dokumentation
- 🧪 Test-Modi für sichere Entwicklung

### **Merge-Vorbereitung:**
```bash
# Tests durchführen
./update-manager.sh --test

# Dokumentation prüfen
cat UPDATE-GUIDE.md

# Branch für Merge vorbereiten
git log --oneline  # Commit-Historie prüfen
```

---

**🎯 Ziel erreicht:** Benutzer können jetzt ihre bestehenden Manager aktualisieren, ohne alles neu aufsetzen zu müssen!
