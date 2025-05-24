# 🚀 REDAXO Multi-Instance Manager

**Einfach mehrere REDAXO-Instanzen verwalten - auch für Anfänger!**

Ein benutzerfreundliches System, um mehrere REDAXO-Websites gleichzeitig auf Ihrem Computer zu entwickeln und zu testen. Perfekt für Entwickler, Agenturen und alle, die mit mehreren REDAXO-Projekten arbeiten.

## 🎯 Was macht dieses Tool?

Stellen Sie sich vor, Sie möchten:
- 🌐 **5 verschiedene REDAXO-Websites** gleichzeitig entwickeln
- 🔧 **Verschiedene REDAXO-Versionen** testen
- 👥 **Kunden-Projekte isoliert** voneinander arbeiten lassen
- 💾 **Sichere Backups** Ihrer Projekte erstellen
- 🔒 **HTTPS-Verschlüsselung** für lokale Entwicklung nutzen

**Genau das macht dieser REDAXO Multi-Instance Manager für Sie!**

## ✨ Features im Überblick

| Feature | Beschreibung | Nutzen für Sie |
|---------|-------------|----------------|
| 🏗️ **Automatische Installation** | REDAXO wird automatisch von GitHub heruntergeladen | Keine manuelle Installation nötig |
| 🔧 **Einfache Verwaltung** | Ein Befehl erstellt eine komplette REDAXO-Instanz | `./redaxo create mein-projekt` |
| 🔒 **HTTPS-Unterstützung** | Automatische SSL-Zertifikate für jede Instanz | Sichere lokale Entwicklung |
| 🐳 **Docker-basiert** | Jede Instanz läuft isoliert | Keine Konflikte zwischen Projekten |
| 💾 **Backup-System** | Vollständige Sicherung mit einem Befehl | Ihre Arbeit ist immer geschützt |
| 📊 **Übersichtliche Verwaltung** | Alle Instanzen auf einen Blick | Behalten Sie den Überblick |
| 🔧 **Konfiguration anzeigen** | Datenbankdaten für REDAXO-Setup | Einfache Einrichtung neuer Projekte |

## 📋 Was brauchen Sie?

### Für Anfänger - Schritt für Schritt:

#### 1. **Docker installieren** (einmalig)
Docker ist wie ein "virtueller Computer" für jede REDAXO-Instanz.

**macOS:**
1. Gehen Sie zu [docker.com](https://www.docker.com/products/docker-desktop)
2. Laden Sie "Docker Desktop für Mac" herunter
3. Installieren Sie es wie eine normale App
4. Starten Sie Docker Desktop

**Windows:**
1. Laden Sie "Docker Desktop für Windows" herunter
2. Aktivieren Sie WSL2 (wird während Installation angeboten)
3. Starten Sie Docker Desktop

**Linux (Ubuntu/Debian):**
```bash
# Docker installieren
sudo apt update
sudo apt install docker.io docker-compose
sudo usermod -aG docker $USER
# Neu anmelden erforderlich
```

#### 2. **Terminal/Kommandozeile öffnen**

**macOS:** Drücken Sie `Cmd + Leertaste`, tippen Sie "Terminal" und drücken Enter
**Windows:** Drücken Sie `Win + R`, tippen Sie "cmd" und drücken Enter
**Linux:** Drücken Sie `Ctrl + Alt + T`

#### 3. **Projekt herunterladen**
```bash
# Zu Ihrem gewünschten Arbeitsverzeichnis navigieren
cd ~/Documents  # oder wo Sie arbeiten möchten

# Projekt herunterladen (ersetzen Sie <repository-url> mit der echten URL)
git clone <repository-url> redaxo-multi-instances
cd redaxo-multi-instances
```

## 🛠️ Installation - Ganz einfach!

### Schritt 1: Scripts ausführbar machen (macOS/Linux)
```bash
# Alle Scripts auf einmal ausführbar machen
chmod +x *.sh
```

### Schritt 2: Automatisches Setup
```bash
# Das Setup macht alles für Sie
./setup.sh
```

**Das Setup:**
- ✅ Prüft ob Docker läuft
- ✅ Erstellt alle notwendigen Ordner
- ✅ Konfiguriert das System
- ✅ Zeigt Ihnen alle verfügbaren Befehle

### Schritt 3: Ihre erste REDAXO-Instanz erstellen
```bash
# Eine neue REDAXO-Instanz namens "mein-projekt" erstellen
./redaxo create mein-projekt
```

**Was passiert dabei:**
1. 📥 Neueste REDAXO-Version wird automatisch heruntergeladen
2. 🐳 Docker-Container werden erstellt (Apache, MariaDB, phpMyAdmin, MailHog)
3. 🔒 SSL-Zertifikat wird generiert
4. 🌐 Automatische Port-Zuweisung
5. ⚙️ Konfigurationsdateien werden erstellt

### Schritt 4: Instanz starten
```bash
./redaxo start mein-projekt
```

**Fertig!** 🎉 Ihre REDAXO-Instanz läuft jetzt!

## 🌐 Wie greife ich auf meine REDAXO-Instanz zu?

Nach dem Start zeigt Ihnen das System alle URLs:

```bash
# URLs einer Instanz anzeigen
./redaxo urls mein-projekt
```

**Typische Ausgabe:**
```
URLs für Instanz 'mein-projekt':
═══════════════════════════════════════════════

REDAXO Anwendung:
  HTTP:   http://localhost:8080
  HTTPS:  https://localhost:8443
  Domain: https://mein-projekt.local (wenn DNS konfiguriert)

Development Tools:
  phpMyAdmin: http://localhost:8181
  MailHog:    http://localhost:8182

✓ Instanz ist aktiv - URLs sind verfügbar
```

### REDAXO-Setup durchführen

1. **Browser öffnen** und zu `http://localhost:8080` gehen
2. **REDAXO-Setup startet automatisch**
3. **Datenbankdaten eingeben** - hier hilft Ihnen das Tool:

```bash
# Datenbankdaten für das REDAXO-Setup anzeigen
./redaxo db-config mein-projekt
```

**Ausgabe:**
```
Datenbankonfiguration für REDAXO-Setup:
═══════════════════════════════════════════════

Im REDAXO-Setup eingeben:
┌─────────────────────────────────────────────┐
│ Database Server: mariadb                    │
│ Database Name:   redaxo_mein_projekt        │
│ Username:        redaxo_mein_projekt        │
│ Password:        redaxo_mein_projekt_pass   │
│ Host:            mariadb                    │
│ Port:            3306                       │
└─────────────────────────────────────────────┘

⚠ Wichtig: Verwenden Sie 'mariadb' als Host, nicht 'localhost'!
```

4. **Diese Werte ins REDAXO-Setup kopieren**
5. **Setup abschließen** - Fertig!

## 📖 Häufig verwendete Befehle

### Grundlegende Verwaltung

```bash
# Neue Instanz erstellen
./redaxo create projekt-name

# Instanz starten
./redaxo start projekt-name

# Instanz stoppen
./redaxo stop projekt-name

# Alle Instanzen anzeigen
./redaxo list

# Status aller Instanzen
./redaxo status
```

### Konfiguration anzeigen

```bash
# Vollständige Konfiguration einer Instanz
./redaxo config mein-projekt

# Nur Datenbankdaten (für REDAXO-Setup)
./redaxo db-config mein-projekt

# URLs einer Instanz
./redaxo urls mein-projekt

# Übersicht aller Instanzen
./redaxo config-all summary
```

### Backup und Wiederherstellung

```bash
# Backup erstellen
./redaxo backup mein-projekt

# Backup wiederherstellen
./redaxo restore neues-projekt backup-datei.tar.gz

# Alle Backups anzeigen
./redaxo backups

# Alte Backups löschen (älter als 30 Tage)
./redaxo cleanup
```

### Updates und Wartung

```bash
# Instance-spezifische Updates (empfohlen)
./instance-update.sh mein-projekt          # Update einer spezifischen Instanz
./instance-update.sh mein-projekt php      # Nur PHP-Version aktualisieren
./instance-update.sh mein-projekt mariadb  # Nur MariaDB-Version aktualisieren
./instance-update.sh mein-projekt all      # Vollständiges Update

# Alternative: Redirect-Tool für Benutzerfreundlichkeit
./update.sh                                 # Zeigt verfügbare Instanzen und Anweisungen
```

**💡 Tipp:** Das `update.sh` Tool leitet Sie automatisch zum korrekten `instance-update.sh` Tool weiter und zeigt alle verfügbaren Instanzen an.

## 🎨 Praktische Beispiele

### Beispiel 1: Kundenprojekte verwalten
```bash
# Drei Kundenprojekte erstellen
./redaxo create kunde-mueller
./redaxo create kunde-schmidt  
./redaxo create kunde-weber

# Alle starten
./redaxo start kunde-mueller
./redaxo start kunde-schmidt
./redaxo start kunde-weber

# Übersicht aller Projekte
./redaxo config-all summary
```

### Beispiel 2: Verschiedene REDAXO-Versionen testen
```bash
# Test-Instanz für neue Features
./redaxo create redaxo-test

# Entwicklungs-Instanz
./redaxo create meine-entwicklung

# Live-Test mit SSL
./redaxo create live-test --domain test.local
```

### Beispiel 3: Backup vor größeren Änderungen
```bash
# Vor großen Änderungen Backup erstellen
./redaxo backup wichtiges-projekt

# Nach den Änderungen bei Problemen wiederherstellen
./redaxo restore wichtiges-projekt backup-wichtiges-projekt-2024-05-24-14-30.tar.gz
```

## 🔧 Erweiterte Funktionen

### Mit spezifischen Ports
```bash
# Bestimmte Ports verwenden
./redaxo create mein-projekt --http-port 9000 --https-port 9443
```

### SSL deaktivieren
```bash
# Ohne HTTPS (nur HTTP)
./redaxo create einfaches-projekt --no-ssl
```

### Alternative REDAXO-Repositories
```bash
# Offizielles REDAXO statt Modern Structure
./redaxo create standard-redaxo --repo redaxo/redaxo
```

### Logs und Debugging
```bash
# Logs einer Instanz anzeigen
./redaxo logs mein-projekt

# In Container einloggen (für Experten)
./redaxo shell mein-projekt
```

## 📁 Wo wird alles gespeichert?

Ihre Projekte werden strukturiert gespeichert:

```
redaxo-multi-instances/
├── instances/              # Ihre REDAXO-Projekte
│   ├── mein-projekt/      # Ein einzelnes Projekt
│   │   ├── app/           # REDAXO-Dateien (Ihre Website)
│   │   └── docker/        # Docker-Konfiguration
│   └── kunde-mueller/     # Weiteres Projekt
├── backups/               # Ihre Backups
├── ssl/                   # SSL-Zertifikate
└── logs/                  # System-Logs
```

**Ihre REDAXO-Dateien** finden Sie in: `instances/projekt-name/app/`
**Ihre Backups** finden Sie in: `backups/`

## 🚨 Problemlösung für Anfänger

### "Permission denied" - Script kann nicht ausgeführt werden
```bash
# Lösung: Script ausführbar machen
chmod +x redaxo
./redaxo help
```

### "Port already in use" - Port ist bereits belegt
```bash
# Lösung: Anderen Port verwenden
./redaxo create mein-projekt --http-port 9000
```

### "Docker not running" - Docker läuft nicht
```bash
# Lösung: Docker Desktop starten
# macOS: Docker Desktop App öffnen
# Windows: Docker Desktop aus Startmenü starten
```

### Instanz startet nicht
```bash
# Problem analysieren
./redaxo logs mein-projekt

# Status prüfen
./redaxo status mein-projekt
```

### Browser zeigt "Nicht sicher" bei HTTPS
**Das ist normal!** Sie verwenden selbst-signierte Zertifikate für die Entwicklung.
- Klicken Sie auf "Erweitert" → "Trotzdem fortfahren"
- Oder verwenden Sie HTTP statt HTTPS

## 🔍 Übersicht aller Befehle

| Befehl | Beschreibung | Beispiel |
|--------|-------------|----------|
| `create` | Neue Instanz erstellen | `./redaxo create mein-projekt` |
| `start` | Instanz starten | `./redaxo start mein-projekt` |
| `stop` | Instanz stoppen | `./redaxo stop mein-projekt` |
| `restart` | Instanz neustarten | `./redaxo restart mein-projekt` |
| `remove` | Instanz löschen | `./redaxo remove mein-projekt` |
| `list` | Alle Instanzen auflisten | `./redaxo list` |
| `status` | Status anzeigen | `./redaxo status` |
| `config` | Konfiguration anzeigen | `./redaxo config mein-projekt` |
| `config-all` | Alle Konfigurationen | `./redaxo config-all summary` |
| `db-config` | Datenbankdaten anzeigen | `./redaxo db-config mein-projekt` |
| `urls` | URLs anzeigen | `./redaxo urls mein-projekt` |
| `backup` | Backup erstellen | `./redaxo backup mein-projekt` |
| `restore` | Backup wiederherstellen | `./redaxo restore projekt backup.tar.gz` |
| `backups` | Backups auflisten | `./redaxo backups` |
| `cleanup` | Alte Backups löschen | `./redaxo cleanup` |
| `logs` | Logs anzeigen | `./redaxo logs mein-projekt` |
| `shell` | Container-Shell öffnen | `./redaxo shell mein-projekt` |
| `ssl` | SSL-Zertifikat erneuern | `./redaxo ssl mein-projekt` |
| `help` | Hilfe anzeigen | `./redaxo help` |

## 💡 Tipps für Anfänger

### 1. **Kleine Schritte**
- Beginnen Sie mit einer Test-Instanz
- Probieren Sie erst alle Grundfunktionen aus
- Machen Sie Backups vor wichtigen Änderungen

### 2. **Benennung von Instanzen**
```bash
# Gute Namen (ohne Leerzeichen, nur Kleinbuchstaben, Bindestriche)
./redaxo create kunde-mueller
./redaxo create test-projekt
./redaxo create meine-website

# Vermeiden Sie:
./redaxo create "Kunde Müller"  # Leerzeichen problematisch
./redaxo create KundeMüller     # Umlaute problematisch
```

### 3. **Regelmäßige Backups**
```bash
# Automatisches Backup-Script erstellen (für Fortgeschrittene)
#!/bin/bash
for instance in kunde-mueller kunde-schmidt meine-website; do
    ./redaxo backup $instance
done
```

### 4. **Ports im Überblick behalten**
```bash
# Alle aktiven Instanzen mit Ports anzeigen
./redaxo config-all summary
```

### 5. **Browser-Lesezeichen**
Erstellen Sie Lesezeichen für Ihre wichtigsten Instanzen:
- `http://localhost:8080` - Hauptprojekt
- `http://localhost:8181` - phpMyAdmin
- `http://localhost:8082` - Testprojekt

## 🎓 Für Fortgeschrittene

### JSON-Export für Automatisierung
```bash
# Alle Konfigurationen als JSON exportieren
./redaxo config-all json > meine-instanzen.json

# Einzelne Instanz als JSON
./redaxo config mein-projekt json
```

### Eigene Docker-Images
Sie können die Docker-Konfiguration in `instances/projekt-name/docker/` anpassen.

### Automatisierung mit Cron
```bash
# Tägliche Backups um 2 Uhr nachts
0 2 * * * /pfad/zu/redaxo backup wichtiges-projekt

# Wöchentliche Bereinigung
0 3 * * 0 /pfad/zu/redaxo cleanup 30
```

## 🤝 Hilfe und Community

### Bei Problemen
1. **Logs prüfen**: `./redaxo logs instanz-name`
2. **Status prüfen**: `./redaxo status`  
3. **Docker prüfen**: Ist Docker Desktop gestartet?
4. **GitHub Issues**: Erstellen Sie ein Issue mit Fehlerbeschreibung

### REDAXO-Community
- 🌐 [REDAXO.org](https://redaxo.org) - Offizielle Website
- 💬 [REDAXO Slack](https://redaxo.org/slack/) - Community Chat
- 📖 [REDAXO Dokumentation](https://redaxo.org/doku/) - Offizielle Docs

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz - nutzen Sie es frei für Ihre Projekte!

---

## 🎉 Schnellstart-Zusammenfassung

```bash
# 1. Scripts ausführbar machen
chmod +x *.sh

# 2. Setup ausführen
./setup.sh

# 3. Erste Instanz erstellen
./redaxo create mein-erstes-projekt

# 4. Instanz starten
./redaxo start mein-erstes-projekt

# 5. Datenbankdaten für REDAXO-Setup abrufen
./redaxo db-config mein-erstes-projekt

# 6. Browser öffnen: http://localhost:8080
# 7. REDAXO-Setup mit den Datenbankdaten durchführen
# 8. Fertig! 🎉
```

**Viel Erfolg mit Ihren REDAXO-Projekten!** 🚀

*Erstellt mit ❤️ für die REDAXO-Community - Von Entwicklern für Entwickler (und die, die es werden wollen)*

## 🍎 macOS Script-Ausführung

### Script-Berechtigungen verstehen

Auf macOS müssen Scripts ausführbare Rechte haben. Das System verwendet verschiedene Ausführungsmethoden:

#### 1. Mit Execute-Berechtigung (empfohlen)

```bash
# Script ausführbar machen
chmod +x redaxo

# Ausführen mit ./
./redaxo help
```

#### 2. Über Shell-Interpreter

Falls ein Script nicht ausführbar ist:

```bash
# Mit bash ausführen
bash redaxo help

# Mit sh ausführen  
sh setup.sh

# Mit explizitem Pfad
bash ./instance-manager.sh status
```

#### 3. Berechtigung prüfen

```bash
# Dateiberechtigungen anzeigen
ls -la redaxo
ls -la scripts/

# Ausgabe sollte x-Flag enthalten: -rwxr-xr-x
```

### macOS-spezifische Hinweise

#### Terminal.app verwenden

1. **Terminal öffnen**: `Cmd + Leertaste` → "Terminal" eingeben
2. **Zum Projektverzeichnis navigieren**:
   ```bash
   cd /pfad/zu/redaxo-multi-instances
   ```
3. **Scripts ausführbar machen und ausführen**:
   ```bash
   chmod +x *.sh
   ./redaxo help
   ```

#### Finder Integration

Sie können Scripts auch über den Finder ausführbar machen:

1. **Rechtsklick auf Script** → "Informationen"
2. **Freigabe & Zugriffsrechte** erweitern
3. **Berechtigung auf "Lesen & Schreiben" setzen**
4. **Terminal öffnen und Script ausführen**

#### Homebrew Terminal-Tools (optional)

Für erweiterte Terminal-Funktionen:

```bash
# iTerm2 als Terminal-Alternative
brew install --cask iterm2

# Bash als Standard-Shell (falls gewünscht)
brew install bash
chsh -s /opt/homebrew/bin/bash
```

### Häufige macOS-Probleme lösen

#### "Permission denied" Fehler

```bash
# Fehler: ./redaxo: Permission denied
# Lösung: Script ausführbar machen
chmod +x redaxo
./redaxo help
```

#### Gatekeeper-Warnung

Wenn macOS eine Sicherheitswarnung zeigt:

1. **Systemeinstellungen** → **Sicherheit & Datenschutz**
2. **"Trotzdem erlauben"** klicken
3. Oder Terminal mit administrativen Rechten verwenden

#### Shebang-Probleme

Falls Scripts nicht korrekt interpretiert werden:

```bash
# Script-Header prüfen
head -n 1 redaxo
# Sollte zeigen: #!/bin/bash

# Falls anders, explizit mit bash ausführen
bash redaxo help
```

### Verschiedene Ausführungsmethoden

#### Direkte Ausführung (nach chmod +x)

```bash
./redaxo create myinstance
./setup.sh
```

#### Über Shell-Interpreter

```bash
bash redaxo create myinstance
sh setup.sh
```

#### Mit vollständigem Pfad

```bash
/bin/bash ./redaxo create myinstance
/bin/sh ./setup.sh
```

#### Source-Ausführung (für Scripts mit Umgebungsvariablen)

```bash
source setup.sh
. setup.sh
```

### Automatisierung für macOS

#### .zshrc/.bash_profile Alias erstellen

```bash
# In ~/.zshrc oder ~/.bash_profile hinzufügen
echo 'alias redaxo="/pfad/zu/redaxo-multi-instances/redaxo"' >> ~/.zshrc
source ~/.zshrc

# Dann von überall ausführbar:
redaxo create myinstance
```

#### PATH-Variable erweitern

```bash
# Projektverzeichnis zum PATH hinzufügen
export PATH="/pfad/zu/redaxo-multi-instances:$PATH"
echo 'export PATH="/pfad/zu/redaxo-multi-instances:$PATH"' >> ~/.zshrc
```

## 📖 Verwendung

### Grundlegende Befehle

Das System bietet ein einfaches Interface über das `redaxo`-Skript:

```bash
./redaxo <befehl> [optionen]
```

### Instanz-Management

#### Neue Instanz erstellen

```bash
# Einfache Erstellung (automatische Port-Zuweisung)
./redaxo create meine-instanz

# Mit spezifischen Ports
./redaxo create meine-instanz --http-port 8080 --https-port 8443

# Mit eigener Domain
./redaxo create meine-instanz --domain example.local

# Ohne SSL
./redaxo create meine-instanz --no-ssl
```

#### Instanz starten

```bash
./redaxo start meine-instanz
```

#### Instanz stoppen

```bash
./redaxo stop meine-instanz
```

#### Instanz neustarten

```bash
./redaxo restart meine-instanz
```

#### Alle Instanzen auflisten

```bash
./redaxo list
```

#### Instanz-Status anzeigen

```bash
# Alle Instanzen
./redaxo status

# Spezifische Instanz
./redaxo status meine-instanz
```

#### Instanz löschen

```bash
./redaxo remove meine-instanz
```

### Backup & Restore

#### Backup erstellen

```bash
# Vollständiges Backup (Dateien + Datenbank)
./redaxo backup meine-instanz

# Nur Dateien sichern
./redaxo backup meine-instanz --no-db

# Unkomprimiert sichern
./redaxo backup meine-instanz --no-compress
```

#### Backup wiederherstellen

```bash
./redaxo restore neue-instanz backup-datei.tar.gz
```

#### Alle Backups auflisten

```bash
./redaxo backups
```

#### Alte Backups löschen

```bash
# Backups älter als 30 Tage löschen (Standard)
./redaxo cleanup

# Backups älter als 7 Tage löschen
./redaxo cleanup 7
```

### Tools & Utilities

#### Logs anzeigen

```bash
./redaxo logs meine-instanz
```

#### Shell in Instanz öffnen

```bash
./redaxo shell meine-instanz
```

#### SSL-Zertifikat erneuern

```bash
./redaxo ssl meine-instanz
```

#### System-Monitoring

```bash
# Einmaliger Status
./monitor.sh status

# Kontinuierliche Überwachung
./monitor.sh watch
```

## 🗂 Verzeichnisstruktur

```
redaxo-multi-instances/
├── instances/                 # Instanz-Verzeichnisse
│   ├── instanz1/             # Einzelne Instanz
│   │   ├── app/              # REDAXO-Dateien (von GitHub)
│   │   ├── docker/           # Docker-Konfiguration
│   │   ├── .env              # Umgebungsvariablen
│   │   └── docker-compose.yml
│   └── instanz2/
├── scripts/                  # Management-Skripte
│   ├── instance-manager.sh   # Hauptverwaltung
│   ├── backup-manager.sh     # Backup/Restore
│   ├── redaxo-downloader.sh  # GitHub-Download-Manager
│   ├── setup.sh             # Initial-Setup
│   ├── monitor.sh            # System-Monitoring
│   └── logger.sh             # Logging-Funktionen
├── downloads/                # Download-Cache für REDAXO-Versionen
├── ssl/                      # SSL-Zertifikate
│   ├── instanz1/
│   │   ├── cert.crt
│   │   ├── private.key
│   │   └── combined.pem
│   └── instanz2/
├── backups/                  # Backup-Dateien
├── logs/                     # System-Logs
├── config.yml               # Hauptkonfiguration
├── redaxo                   # Haupt-Interface
└── README.md
```

## 📥 REDAXO-Download-Manager

Das System lädt automatisch die neueste REDAXO Modern Structure von GitHub herunter:

### Automatischer Download bei Instanz-Erstellung

Beim Erstellen einer neuen Instanz wird automatisch die neueste REDAXO-Version heruntergeladen:

```bash
# Erstellt Instanz mit aktuellster REDAXO-Version von GitHub
./redaxo create meine-instanz
```

### Manuelle Download-Befehle

```bash
# Neueste Version herunterladen
./scripts/redaxo-downloader.sh download latest

# Verfügbare Versionen anzeigen
./scripts/redaxo-downloader.sh list-releases

# Aktuelle Version prüfen
./scripts/redaxo-downloader.sh check-latest

# Download-Cache bereinigen
./scripts/redaxo-downloader.sh clean

# Download mit spezifischem Extraktionspfad
./scripts/redaxo-downloader.sh download latest --extract-to /pfad/zum/ziel
```

### GitHub-Repository

Das System verwendet standardmäßig das REDAXO Modern Structure Repository:
- **Standard-Repository**: `skerbis/REDAXO_MODERN_STRUCTURE`
- **Releases**: https://github.com/skerbis/REDAXO_MODERN_STRUCTURE/releases

#### Alternative Repositories verwenden

Sie können alternative GitHub-Repositories verwenden, die **exakt die gleiche Struktur** haben:

```bash
# Mit alternativem Repository erstellen
./redaxo create meine-instanz --repo ihr-username/ihr-redaxo-setup

# Repository für Download ändern
./redaxo download latest --repo ihr-username/ihr-redaxo-setup
```

**Wichtig**: Alternative Repositories müssen:
- Die gleiche Verzeichnisstruktur wie `REDAXO_MODERN_STRUCTURE` haben
- ZIP-Files mit dem Pattern `redaxo-setup-*.zip` in den Releases bereitstellen
- Kompatible REDAXO-Installation enthalten

## 🔧 Konfiguration

### Hauptkonfiguration (`config.yml`)

```yaml
# Standard-Ports für neue Instanzen
default_ports:
  http_start: 8080
  https_start: 8443
  phpmyadmin_start: 8180
  mailhog_start: 8280

# SSL-Konfiguration
ssl:
  enabled: true
  country: "DE"
  state: "Germany"
  city: "City"
  organization: "Organization"
  validity_days: 365

# Backup-Konfiguration
backup:
  retention_days: 30
  compress: true
  include_database: true
```

### Instanz-spezifische Konfiguration (`.env`)

Jede Instanz hat ihre eigene `.env`-Datei:

```bash
# REDAXO Instance: meine-instanz
INSTANCE_NAME=meine-instanz
DOMAIN=meine-instanz.local

# MariaDB-Konfiguration
MYSQL_ROOT_PASSWORD=redaxo_meine-instanz_root
MYSQL_DATABASE=redaxo_meine-instanz
MYSQL_USER=redaxo_meine-instanz
MYSQL_PASSWORD=redaxo_meine-instanz_pass

# Portmapping
HTTP_PORT=8080
HTTPS_PORT=8443
PHPMYADMIN_PORT=8180
MAILHOG_PORT=8280
```

## 🔒 HTTPS & SSL

### Automatische Zertifikat-Generierung

Bei der Erstellung einer Instanz wird automatisch ein selbstsigniertes SSL-Zertifikat generiert:

```bash
# Instanz mit SSL erstellen
./redaxo create meine-instanz --domain example.local
```

### Zertifikat-Details

- **Gültigkeit**: 365 Tage (konfigurierbar)
- **Typ**: Selbstsigniert (für Entwicklung)
- **Unterstützte Domains**: Angegebene Domain + localhost + 127.0.0.1
- **Speicherort**: `ssl/<instanz-name>/`

### Zertifikat erneuern

```bash
./redaxo ssl meine-instanz
```

### Browser-Vertrauen einrichten

Für selbstsignierte Zertifikate:

1. Browser öffnen und zu `https://localhost:<port>` navigieren
2. Sicherheitswarnung akzeptieren
3. Oder Zertifikat in Browser-Vertrauensspeicher importieren

## 🐳 Docker-Services

Jede Instanz besteht aus folgenden Services:

### Apache + PHP
- **Image**: `php:8.2-apache`
- **Ports**: HTTP (automatisch) + HTTPS (falls aktiviert)
- **Volumes**: App-Dateien, SSL-Zertifikate

### MariaDB
- **Image**: `mariadb:latest`
- **Volumes**: Persistente Datenbank-Speicherung
- **Credentials**: Instanz-spezifisch generiert

### phpMyAdmin
- **Image**: `phpmyadmin/phpmyadmin`
- **Port**: Automatisch zugewiesen
- **Zugriff**: Über Web-Interface

### MailHog
- **Image**: `mailhog/mailhog`
- **Port**: Automatisch zugewiesen
- **Funktion**: SMTP-Debugging für E-Mail-Tests

## 📊 Monitoring & Logging

### System-Status

```bash
# Aktueller Status aller Instanzen
./monitor.sh status

# Kontinuierliche Überwachung
./monitor.sh watch
```

### Log-Dateien

- **System-Logs**: `logs/redaxo-YYYY-MM-DD.log`
- **Instanz-Logs**: Über `./redaxo logs <instanz>`
- **Docker-Logs**: Automatisch über Docker Compose

### Log-Rotation

- Automatische Bereinigung nach 30 Tagen
- Konfigurierbar über Environment-Variable

## 🔄 Backup-Strategien

### Vollständige Backups

Enthalten:
- Alle REDAXO-Dateien (`app/`-Verzeichnis)
- Datenbank-Dump
- Konfigurationsdateien
- Metadaten (Backup-Info)

### Inkrementelle Backups

Für regelmäßige Sicherungen:

```bash
# Tägliches Backup (Cron-Job)
0 2 * * * /pfad/zu/redaxo backup meine-instanz

# Wöchentliche Bereinigung
0 3 * * 0 /pfad/zu/redaxo cleanup 30
```

## 🚨 Troubleshooting

### Häufige Probleme

#### Port bereits belegt

```bash
# Prüfe belegte Ports
netstat -tuln | grep :8080

# Verwende anderen Port
./redaxo create instanz --http-port 8090
```

#### Docker-Probleme

```bash
# Docker-Status prüfen
docker info

# Docker neu starten
sudo systemctl restart docker
```

#### SSL-Zertifikat-Probleme

```bash
# Zertifikat neu generieren
./redaxo ssl meine-instanz

# SSL deaktivieren
./redaxo create instanz --no-ssl
```

#### Instanz startet nicht

```bash
# Logs überprüfen
./redaxo logs meine-instanz

# Container-Status prüfen
cd instances/meine-instanz
docker-compose ps
```

### Log-Analyse

```bash
# System-Logs
tail -f logs/redaxo-$(date +%Y-%m-%d).log

# Instanz-spezifische Logs
./redaxo logs meine-instanz

# Docker-Container-Logs
docker logs redaxo-meine-instanz-apache
```

## 🔧 Erweiterte Konfiguration

### Custom Docker Images

Erstellen Sie eigene Docker-Images für spezielle Anforderungen:

```dockerfile
# instances/meine-instanz/docker/apache/Dockerfile
FROM php:8.2-apache

# Zusätzliche PHP-Extensions
RUN docker-php-ext-install pdo_mysql gd

# Custom PHP-Konfiguration
COPY custom-php.ini /usr/local/etc/php/conf.d/
```

### Environment-spezifische Anpassungen

```bash
# Development
./redaxo create dev-instanz --http-port 8080

# Staging
./redaxo create staging-instanz --http-port 8090

# Testing
./redaxo create test-instanz --http-port 8100
```

## 📈 Performance-Optimierung

### Ressourcen-Limits

```yaml
# docker-compose.yml (automatisch generiert)
services:
  apache:
    deploy:
      resources:
        limits:
          memory: 512M
        reservations:
          memory: 256M
```

### Volume-Optimierung

```yaml
volumes:
  mariadb_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /pfad/zu/schnellem/storage
```

## 🤝 Beitragen

### Entwicklung

1. Repository forken
2. Feature-Branch erstellen: `git checkout -b feature/neue-funktion`
3. Änderungen committen: `git commit -am 'Neue Funktion hinzugefügt'`
4. Branch pushen: `git push origin feature/neue-funktion`
5. Pull Request erstellen

### Bug Reports

Erstellen Sie Issues mit:
- Detaillierte Fehlerbeschreibung
- Schritte zur Reproduktion
- System-Informationen
- Log-Ausgaben

## 📄 Lizenz

Dieses Projekt steht unter der MIT-Lizenz. Siehe `LICENSE.md` für Details.

## 🙏 Danksagungen

- REDAXO CMS Community
- Docker Community
- Alle Beitragenden

---

**Erstellt mit ❤️ für die REDAXO-Community**

Für Fragen und Support besuchen Sie die [REDAXO-Community](https://redaxo.org) oder erstellen Sie ein Issue in diesem Repository.
