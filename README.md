# REDAXO Multi-Instance Manager

Ein umfassendes System zur Verwaltung mehrerer REDAXO-Instanzen mit Docker, inklusive HTTPS-Unterstützung, automatischer SSL-Zertifikat-Generierung und Backup-Management.

## 🚀 Features

- **Multi-Instance Management**: Erstellen und verwalten Sie beliebig viele REDAXO-Instanzen
- **Aktuelle REDAXO-Versionen**: Automatischer Download der neuesten REDAXO Modern Structure von GitHub
- **HTTPS-Unterstützung**: Automatische SSL-Zertifikat-Generierung für jede Instanz
- **Port-Management**: Automatische Zuweisung verfügbarer Ports
- **Backup & Restore**: Vollständige Sicherung und Wiederherstellung von Instanzen
- **Docker-basiert**: Isolierte Umgebungen für jede Instanz
- **Einfache CLI**: Intuitive Kommandozeilen-Schnittstelle
- **Monitoring**: System-Status und Instanz-Überwachung
- **GitHub-Integration**: Download aktueller Releases direkt von GitHub

## 📋 Systemvoraussetzungen

- **Docker** (Version 20.0 oder höher)
- **Docker Compose** (Version 2.0 oder höher)
- **OpenSSL** (für SSL-Zertifikat-Generierung)
- **Bash** (für Skript-Ausführung)
- **macOS**, **Linux** oder **Windows** mit WSL2

## 🛠 Installation

### 1. Repository klonen oder herunterladen

```bash
git clone <repository-url> redaxo-multi-instances
cd redaxo-multi-instances
```

### 2. Scripts ausführbar machen (macOS/Linux)

Bevor Sie die Scripts ausführen können, müssen Sie diese ausführbar machen:

```bash
# Alle Scripts auf einmal ausführbar machen
chmod +x redaxo scripts/*.sh

# Oder einzeln:
chmod +x redaxo
chmod +x scripts/setup.sh
chmod +x scripts/instance-manager.sh
chmod +x scripts/redaxo-downloader.sh
chmod +x scripts/backup-manager.sh
chmod +x scripts/monitor.sh
```

### 3. Setup ausführen

```bash
./scripts/setup.sh
```

Das Setup-Skript:
- Prüft alle Systemvoraussetzungen
- Erstellt die notwendige Verzeichnisstruktur
- Konfiguriert das System
- Erstellt das Haupt-Interface

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
sh scripts/setup.sh

# Mit explizitem Pfad
bash ./scripts/instance-manager.sh status
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
   chmod +x redaxo scripts/*.sh
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
./scripts/setup.sh
```

#### Über Shell-Interpreter

```bash
bash redaxo create myinstance
sh scripts/setup.sh
```

#### Mit vollständigem Pfad

```bash
/bin/bash ./redaxo create myinstance
/bin/sh ./scripts/setup.sh
```

#### Source-Ausführung (für Scripts mit Umgebungsvariablen)

```bash
source scripts/setup.sh
. scripts/setup.sh
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
./scripts/monitor.sh status

# Kontinuierliche Überwachung
./scripts/monitor.sh watch
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
├── app-template/             # REDAXO-Fallback-Template
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
./scripts/monitor.sh status

# Kontinuierliche Überwachung
./scripts/monitor.sh watch
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
