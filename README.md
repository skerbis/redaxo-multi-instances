# 🚀 REDAXO Multi-Instance Manager

**Vereinfacht - Ein Skript für alles!**

Ein super einfaches System, um mehrere REDAXO-Websites gleichzeitig auf Ihrem Computer zu entwickeln und zu testen. Perfekt für Entwickler, Agenturen und alle, die mit mehreren REDAXO-Projekten arbeiten.

> **✨ Neu: Alles in einem einzigen Befehl!** Das gesamte System wurde vereinfacht - nur noch ein Skript für alle Funktionen.

## 🎯 Was macht dieses Tool?

Stellen Sie sich vor, Sie möchten:
- 🌐 **5 verschiedene REDAXO-Websites** gleichzeitig entwickeln
- 🔧 **Verschiedene REDAXO-Versionen** testen
- 👥 **Kunden-Projekte isoliert** voneinander arbeiten lassen
- 🔒 **HTTPS-Verschlüsselung** für lokale Entwicklung nutzen

**Genau das macht dieser REDAXO Multi-Instance Manager für Sie - mit nur einem einzigen Befehl!**

## ✨ Features im Überblick

- 🏗️ **Ein Skript für alles** - Alle Funktionen in einem einzigen `./redaxo` Befehl
- 🔧 **Einfache Verwaltung** - `./redaxo create mein-projekt` erstellt alles automatisch
- 🔒 **HTTPS-Unterstützung** - Automatische SSL-Zertifikate mit mkcert
- 🐳 **Docker-basiert** - Jede Instanz läuft isoliert
- 📊 **Übersichtliche Verwaltung** - Alle Instanzen auf einen Blick
- 🔧 **Konfiguration anzeigen** - Datenbankdaten für REDAXO-Setup

## 📋 Voraussetzungen

### 1. Docker installieren (einmalig)

**macOS:**
1. [Docker Desktop für Mac](https://www.docker.com/products/docker-desktop) herunterladen
2. Installieren und starten

**Windows:**
1. [Docker Desktop für Windows](https://www.docker.com/products/docker-desktop) herunterladen
2. WSL2 aktivieren (wird angeboten)
3. Installieren und starten

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install docker.io docker-compose-plugin
sudo usermod -aG docker $USER
# Neu anmelden erforderlich
```

### 2. mkcert für SSL (optional aber empfohlen)

**macOS (mit Homebrew):**
```bash
brew install mkcert
```

**Linux:**
```bash
# Installation variiert je nach Distribution
# Siehe: https://github.com/FiloSottile/mkcert#installation
```

**Windows:**
```bash
# Mit Chocolatey
choco install mkcert
```

## 🚀 Schnellstart - In 2 Minuten zur ersten REDAXO-Instanz!

### 1. Projekt herunterladen und vorbereiten
```bash
# Zu Ihrem Arbeitsverzeichnis
cd ~/Documents

# Projekt klonen (URL anpassen)
git clone <repository-url> redaxo-multi-instances
cd redaxo-multi-instances

# Script ausführbar machen
chmod +x redaxo
```

### 2. SSL-Setup (einmalig, optional)
```bash
# SSL-Zertifikate für lokale Entwicklung einrichten
./redaxo ssl-setup
```

### 3. Erste Instanz erstellen
```bash
# Neue REDAXO-Instanz erstellen
./redaxo create mein-projekt
```

### 4. Instanz starten
```bash
./redaxo start mein-projekt
```

**🎉 Fertig!** Ihre REDAXO-Instanz läuft unter `http://localhost:8080`

## 📚 Alle Befehle im Überblick

Das neue `./redaxo` Skript kann alles:

```bash
# ✨ INSTANZ-VERWALTUNG
./redaxo create <name>          # Neue Instanz erstellen
./redaxo create <name> --php-version 8.3 --mariadb-version 10.6  # Mit spezifischen Versionen
./redaxo start <name>           # Instanz starten
./redaxo stop <name>            # Instanz stoppen
./redaxo remove <name>          # Instanz löschen
./redaxo list                   # Alle Instanzen auflisten

# 🌐 INFORMATIONEN
./redaxo urls <name>            # URLs der Instanz anzeigen
./redaxo db <name>              # Datenbankdaten anzeigen
./redaxo versions <name>        # PHP/MariaDB-Versionen anzeigen

# 🔧 VERSIONSVERWALTUNG
./redaxo update <name> --php-version 8.3           # PHP-Version aktualisieren
./redaxo update <name> --mariadb-version 11.0      # MariaDB-Version aktualisieren
./redaxo update <name> --php-version 8.1 --mariadb-version 10.6  # Beide Versionen

# 🔒 SSL & SETUP
./redaxo ssl-setup              # SSL-Zertifikate einrichten

# ❓ HILFE
./redaxo help                   # Alle Befehle anzeigen
./redaxo                        # Auch Hilfe anzeigen
```

### 🐘 Verfügbare PHP-Versionen
- **PHP 7.4** - Legacy-Projekte
- **PHP 8.0** - Stabile Version
- **PHP 8.1** - Weit verbreitet
- **PHP 8.2** - Standard (empfohlen)
- **PHP 8.3** - Neueste Version

### 🗄️ Verfügbare MariaDB-Versionen
- **10.4** - Ältere stabile Version
- **10.5** - Bewährt
- **10.6** - LTS-Version
- **10.11** - Aktuelle LTS
- **11.0** - Neueste Version
- **latest** - Immer die neueste (Standard)

## 🌐 Zugriff auf Ihre REDAXO-Instanz

Nach dem Start einer Instanz:

```bash
./redaxo urls mein-projekt
```

Zeigt Ihnen alle verfügbaren URLs:
- **REDAXO**: `http://localhost:8080` (HTTP) und `https://localhost:8443` (HTTPS)
- **phpMyAdmin**: `http://localhost:8181`
- **MailHog**: `http://localhost:8182` (E-Mail-Testing)

### REDAXO-Setup durchführen

1. **Browser öffnen**: `http://localhost:8080`
2. **REDAXO-Setup folgen**
3. **Datenbankdaten eingeben**:

```bash
# Datenbankdaten anzeigen
./redaxo db mein-projekt
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

### Beispiel 1: Verschiedene PHP-Versionen für Projekte
```bash
# Legacy-Projekt mit PHP 7.4
./redaxo create legacy-kunde --php-version 7.4 --mariadb-version 10.4

# Aktuelles Projekt mit PHP 8.2  
./redaxo create neuer-kunde --php-version 8.2 --mariadb-version 10.11

# Bleeding-Edge Entwicklung mit PHP 8.3
./redaxo create zukunft-projekt --php-version 8.3 --mariadb-version 11.0

# Alle starten
./redaxo start legacy-kunde
./redaxo start neuer-kunde
./redaxo start zukunft-projekt

# Übersicht aller Projekte mit Versionen
./redaxo list
./redaxo versions legacy-kunde
./redaxo versions neuer-kunde
./redaxo versions zukunft-projekt
```

### Beispiel 2: Kundenprojekte verwalten
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
./redaxo list
```

### Beispiel 3: Upgrade-Testing
```bash
# Aktuelle Produktionsumgebung (PHP 8.1)
./redaxo create produktion-test --php-version 8.1 --mariadb-version 10.6

# Test-Umgebung für Upgrade (PHP 8.3)
./redaxo create upgrade-test --php-version 8.3 --mariadb-version 11.0

# Nach Tests: Produktionsumgebung upgraden
./redaxo update produktion-test --php-version 8.3 --mariadb-version 11.0
```

### Beispiel 4: PHP-Version für bestehende Instanz ändern
```bash
# Vor größeren Änderungen Backup erstellen
./redaxo backup wichtiges-projekt

# PHP von 8.1 auf 8.3 upgraden
./redaxo update wichtiges-projekt --php-version 8.3

# Bei Problemen: Backup wiederherstellen
# ./redaxo restore wichtiges-projekt backup-wichtiges-projekt-2025-05-24-14-30.tar.gz
```

## 🔧 Erweiterte Funktionen

### 🐘 PHP- und MariaDB-Versionen wählen

```bash
# Neue Instanz mit spezifischen Versionen erstellen
./redaxo create mein-projekt --php-version 8.3 --mariadb-version 10.6

# Nur PHP-Version angeben (MariaDB bleibt auf "latest")
./redaxo create legacy-projekt --php-version 7.4

# Nur MariaDB-Version angeben (PHP bleibt auf 8.2)
./redaxo create db-test --mariadb-version 11.0

# Aktuelle Versionen einer Instanz anzeigen
./redaxo versions mein-projekt

# Versionen später ändern
./redaxo update mein-projekt --php-version 8.3
./redaxo update mein-projekt --mariadb-version 11.0
./redaxo update mein-projekt --php-version 8.1 --mariadb-version 10.6
```

### 📋 Versionskompatibilität

| REDAXO Version | Empfohlene PHP-Version | Min. PHP | MariaDB |
|----------------|------------------------|----------|---------|
| REDAXO 5.18+   | **PHP 8.2** oder 8.3  | PHP 8.0  | 10.4+   |
| REDAXO 5.15+   | **PHP 8.1** oder 8.2  | PHP 7.4  | 10.2+   |
| Legacy         | **PHP 7.4** oder 8.0  | PHP 7.3  | 5.7+    |

### Mit spezifischen Ports
```bash
# Bestimmte Ports verwenden
./redaxo create mein-projekt --http-port 9000 --https-port 9443
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

## 🚨 Problemlösung

### Häufige Probleme

**"Permission denied"**
```bash
chmod +x redaxo
./redaxo help
```

**"Port already in use"**
```bash
# Ports werden automatisch zugewiesen - das sollte nicht passieren
./redaxo list  # Aktuelle Ports anzeigen
```

**"Docker not running"**
```bash
# Docker Desktop starten (macOS/Windows)
# Linux: sudo systemctl start docker
```

**Instanz startet nicht**
```bash
./redaxo logs mein-projekt  # Logs prüfen
docker ps                   # Container-Status
```

**HTTPS-Warnung im Browser**
Das ist normal bei selbst-signierten Zertifikaten. Klicken Sie auf "Erweitert" → "Trotzdem fortfahren".

## 📁 Dateistruktur

Das vereinfachte System:

```
redaxo-multi-instances/
├── redaxo                    # ✨ HAUPTSKRIPT - alles in einem!
├── redaxo-downloader.sh      # REDAXO-Download
├── README.md                 # Diese Dokumentation  
├── LICENSE.md                # Lizenz
├── instances/                # Alle REDAXO-Instanzen
│   ├── mein-projekt/
│   │   ├── docker-compose.yml
│   │   ├── .env
│   │   └── app/              # REDAXO-Installation hier
│   └── ...
├── ssl/                      # SSL-Zertifikate
├── docker/                   # Docker-Templates
└── downloads/                # REDAXO-Versionen Cache
```

## 🎯 Warum so einfach?

**Vorher:** 15+ verschiedene Skripte - zu kompliziert!
**Jetzt:** NUR EIN Befehl: `./redaxo`

- ✅ **Einfacher zu lernen** - nur ein Befehl
- ✅ **Weniger Fehlerquellen** - alles in einem Skript  
- ✅ **Bessere Übersicht** - keine Script-Verwirrung
- ✅ **Einheitliche Bedienung** - immer gleiche Syntax

## 🚀 Migration vom alten System

Falls Sie das alte System mit vielen Skripten verwenden:

1. **Backup Ihrer Instanzen** (falls vorhanden)
2. **Neue Version herunterladen**  
3. **Alte `instances/` Ordner kopieren** (funktionieren weiterhin)
4. **Neues `./redaxo` Skript verwenden**

Alle bestehenden Instanzen funktionieren mit dem neuen System!

## 🤝 Hilfe & Community

- 🌐 [REDAXO.org](https://redaxo.org) - Offizielle Website
- 💬 [REDAXO Slack](https://redaxo.org/slack/) - Community Chat
- 📖 [REDAXO Dokumentation](https://redaxo.org/doku/) - Offizielle Docs
- 🐛 [GitHub Issues](https://github.com/skerbis/REDAXO_MODERN_STRUCTURE) - Bug Reports

## 📄 Lizenz

MIT-Lizenz - nutzen Sie es frei für Ihre Projekte!

---

**✨ Erstellt mit ❤️ für die REDAXO-Community ✨**

🎉 **Schnellstart in 30 Sekunden:**

```bash
# 1. Script ausführbar machen
chmod +x redaxo

# 2. Erste Instanz erstellen (PHP 8.2, MariaDB latest)
./redaxo create mein-projekt

# 3. URLs anzeigen
./redaxo urls mein-projekt

# 4. Browser öffnen: http://localhost:8080
# 5. REDAXO-Setup durchführen - Fertig! 🚀
```

🔧 **Mit spezifischen Versionen:**

```bash
# PHP 8.3 und MariaDB 11.0 verwenden
./redaxo create modern-projekt --php-version 8.3 --mariadb-version 11.0

# Legacy-Projekt mit PHP 7.4
./redaxo create legacy-projekt --php-version 7.4

# Versionen später ändern
./redaxo update mein-projekt --php-version 8.3
```
