# 🚀 QUICKSTART - In 5 Minuten zu Ihrer ersten REDAXO-Instanz

**Für absolute Anfänger - Schritt für Schritt erklärt**

## ⏰ Was Sie in den nächsten 5 Minuten erreichen:
- ✅ Eine funktionierende REDAXO-Installation 
- ✅ Automatische Datenbank-Konfiguration
- ✅ Professionelle Entwicklungsumgebung
- ✅ HTTPS-Verschlüsselung (optional)

## 📋 Voraussetzungen prüfen

### 1. Haben Sie Docker?
**macOS/Windows:** Gehen Sie zu [docker.com](https://docker.com) und laden Sie "Docker Desktop" herunter.

**Prüfung:** Öffnen Sie ein Terminal und tippen:
```bash
docker --version
```
Sollte sowas anzeigen: `Docker version 24.0.0`

### 2. Terminal öffnen
- **macOS:** `Cmd + Leertaste` → "Terminal" eingeben → Enter
- **Windows:** `Win + R` → "cmd" eingeben → Enter  
- **Linux:** `Ctrl + Alt + T`

## 🎯 5-Minuten-Setup

### Schritt 1: Projekt herunterladen (30 Sekunden)
```bash
# Navigieren Sie zu Ihrem Arbeitsverzeichnis
cd ~/Documents

# Projekt herunterladen (ersetzen Sie URL mit der echten)
git clone <repository-url> redaxo-multi-instances
cd redaxo-multi-instances
```

### Schritt 2: Scripts aktivieren (15 Sekunden)
```bash
# Nur für macOS/Linux - macht Scripts ausführbar
chmod +x redaxo scripts/*.sh
```

### Schritt 3: Automatische Installation (1 Minute)
```bash
# Das macht alles automatisch für Sie
./scripts/setup.sh
```

### Schritt 4: Ihre erste REDAXO-Instanz (2 Minuten)
```bash
# Erstellt eine REDAXO-Instanz namens "mein-projekt"
./redaxo create mein-projekt
```

**Was passiert hier automatisch:**
- 📥 Neueste REDAXO-Version wird heruntergeladen
- 🐳 Docker-Container werden konfiguriert  
- 🗄️ MariaDB-Datenbank wird erstellt
- 🔧 phpMyAdmin wird installiert
- 🔒 SSL-Zertifikat wird generiert

### Schritt 5: Starten (30 Sekunden)
```bash
# Instanz starten
./redaxo start mein-projekt
```

### Schritt 6: Datenbankdaten abrufen (15 Sekunden)
```bash
# Zeigt Ihnen die Daten für das REDAXO-Setup
./redaxo db-config mein-projekt
```

**Kopieren Sie diese Ausgabe:**
```
┌─────────────────────────────────────────────┐
│ Database Server: mariadb                    │
│ Database Name:   redaxo_mein_projekt        │
│ Username:        redaxo_mein_projekt        │
│ Password:        redaxo_mein_projekt_pass   │
│ Host:            mariadb                    │
│ Port:            3306                       │
└─────────────────────────────────────────────┘
```

### Schritt 7: REDAXO einrichten (1 Minute)
1. **Browser öffnen:** `http://localhost:8080`
2. **REDAXO-Setup startet automatisch**
3. **Datenbankdaten eingeben** (aus Schritt 6)
4. **Setup abschließen**

## 🎉 Fertig!

Ihre REDAXO-Instanz läuft jetzt auf:
- **REDAXO:** http://localhost:8080
- **phpMyAdmin:** http://localhost:8181 (falls Sie die Datenbank direkt bearbeiten möchten)

## 🔧 Nützliche Befehle für den Alltag

```bash
# Alle Ihre Instanzen anzeigen
./redaxo list

# Status prüfen 
./redaxo status

# Instanz stoppen
./redaxo stop mein-projekt

# Instanz wieder starten
./redaxo start mein-projekt

# Backup erstellen (wichtig!)
./redaxo backup mein-projekt

# URLs anzeigen
./redaxo urls mein-projekt
```

## 🆘 Häufige Probleme

### "Permission denied"
```bash
# Lösung:
chmod +x redaxo
./redaxo help
```

### "Docker nicht gefunden"
- Docker Desktop starten
- Warten bis Docker vollständig geladen ist

### "Port bereits belegt"
```bash
# Anderen Port verwenden:
./redaxo create mein-projekt --http-port 9000
```

### Browser zeigt "Nicht sicher"
- **Normal bei HTTPS!** Klicken Sie "Erweitert" → "Trotzdem fortfahren"
- Oder nutzen Sie HTTP: `http://localhost:8080`

## 💡 Nächste Schritte

### Weitere Projekte erstellen
```bash
./redaxo create kunde-mueller
./redaxo create test-website
./redaxo create meine-homepage
```

### Backups machen (empfohlen!)
```bash
# Vor wichtigen Änderungen
./redaxo backup wichtiges-projekt
```

### Alle Projekte verwalten
```bash
# Übersicht aller Projekte
./redaxo config-all summary
```

## 📚 Mehr lernen

- 📖 **Vollständige Anleitung:** `README.md` in diesem Ordner
- 🌐 **REDAXO-Community:** [redaxo.org](https://redaxo.org)
- 💬 **Hilfe:** Erstellen Sie ein Issue auf GitHub

## ✅ Checkliste

- [ ] Docker installiert und gestartet
- [ ] Projekt heruntergeladen  
- [ ] Scripts ausführbar gemacht (`chmod +x`)
- [ ] Setup ausgeführt (`./scripts/setup.sh`)
- [ ] Erste Instanz erstellt (`./redaxo create mein-projekt`)
- [ ] Instanz gestartet (`./redaxo start mein-projekt`)
- [ ] Browser geöffnet (`http://localhost:8080`)
- [ ] REDAXO-Setup abgeschlossen
- [ ] Erstes Backup erstellt (`./redaxo backup mein-projekt`)

**Herzlichen Glückwunsch! Sie haben erfolgreich Ihre erste REDAXO-Multi-Instance eingerichtet!** 🎉

---

*Bei Fragen oder Problemen schauen Sie in die vollständige README.md oder erstellen Sie ein Issue.*
