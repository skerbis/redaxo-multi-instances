# 🚀 REDAXO Multi-Instance Manager

![Screenshot](https://github.com/skerbis/redaxo-multi-instances/blob/assets/screen.png?raw=true)

**Das moderne Dashboard für REDAXO-Entwickler** - Erstellen und verwalten Sie beliebig viele REDAXO-Instanzen mit einem Klick!

![REDAXO Multi-Instance Dashboard](https://img.shields.io/badge/REDAXO-Multi--Instance-4f7df3?style=for-the-badge&logo=docker)
![Version](https://img.shields.io/badge/Version-2.1-success?style=for-the-badge)

> 🎯 **Perfekt für:** Lokale Entwicklung, Client-Projekte, Testing verschiedener REDAXO-Versionen, Dump-Import

---

## 📋 Inhaltsverzeichnis

### 🚀 Erste Schritte
- [Was macht dieses Tool besonders?](#-was-macht-dieses-tool-besonders)
- [Warum besser als MAMP?](#-warum-besser-als-mamp)
- [Quick Start (3 Minuten)](#-quick-start-3-minuten)
- [Systemvoraussetzungen](#-systemvoraussetzungen)

### 💡 Kernfunktionen
- [Features](#-features)
- [Dashboard Features](#️-dashboard-features)
- [Dump-Import (Bestehende REDAXO-Projekte)](#-dump-import-bestehende-redaxo-projekte)
- [Webserver-Only-Instanzen](#-webserver-only-instanzen)

### 🛠️ Praktische Anwendung
- [Entwickler-Integration](#-entwickler-integration)
- [Befehlsreferenz](#-befehlsreferenz)
- [Beispiele & Workflows](#-beispiele--workflows)
- [Häufige Use Cases](#-häufige-use-cases)

### ⚙️ Technische Details
- [PHP-Konfiguration](#️-php-konfiguration)
- [Dashboard](#️-dashboard)
- [Port-Zuweisungen](#automatisch-zugewiesene-ports)

### 🔧 Wartung & Support
- [Troubleshooting](#-troubleshooting)
- [Pro-Tipps](#-pro-tipps)
- [Sicherheit & Hinweise](#-sicherheit--hinweise)

### 🤝 Community
- [Contributing & Support](#-contributing--support)
- [Über den Entwickler](#-über-den-entwickler)
- [Support](#️-support)

---

## 🆕 Neueste Updates (Juni 2025)

### **🚀 Erweiterte Entwickler-Integration**
- ✨ **VS Code Integration:** Ein-Klick-Öffnung von Projekten im Editor
- ✨ **Finder Integration:** Direkter Zugriff auf Projektordner im macOS Finder  
- ✨ **DB-Management-UI:** Vollständige Datenbankinfo mit Kopier-Buttons und phpMyAdmin-Integration
- ✨ **Version-Updates:** PHP/MariaDB-Versionen direkt im Dashboard ändern
- ✨ **REDAXO-Branding:** Professionelles Logo und UI-Verbesserungen

### **⚙️ Verbesserungen**
- 🔧 **Live-Versionsanzeige:** Aktuelle PHP/MariaDB-Versionen werden dynamisch erkannt
- 🔧 **Robuste Update-Prozesse:** Timeout-Handling und bessere Fehlerbehandlung
- 🔧 **Webserver-Only-Support:** Vollständige Integration in alle neuen Features
- 🔧 **UI/UX-Polish:** Bessere Button-Designs, Modal-Verbesserungen, responsives Layout

---

## ✨ Was macht dieses Tool besonders?

### 🎛️ **Elegantes Web-Dashboard**
- **Glass-Design UI** mit Live-Updates
- **Ein-Klick Instanz-Erstellung** mit Auto-Installation
- **Screenshot-Vorschau** aller laufenden Websites
- **Dump-Import** für bestehende REDAXO-Projekte
- **Real-time Status** aller Instanzen

### 🐳 **Docker-powered**
- **Isolierte Container** - keine Konflikte zwischen Projekten
- **Automatische SSL-Zertifikate** für alle Instanzen
- **Beliebige PHP/MariaDB-Versionen** parallel
- **Integrierte Tools:** phpMyAdmin, Mailpit für E-Mail-Testing

### ⚡ **Entwicklerfreundlich**
- **VS Code Integration** - öffnet Projekte direkt im Editor
- **Finder Integration** - Dateien per Drag & Drop verwalten
- **DB-Management** - phpMyAdmin mit Root-Rechten, Kopier-Buttons für Credentials
- **Version-Updates** - PHP/MariaDB-Versionen per Klick ändern
- **Automatische Port-Verwaltung** - keine Konfiguration nötig
- **Backup/Restore System** für Projekte
- **CLI + Web-Interface** - wie Sie möchten

---

## 🆚 Warum besser als MAMP?

| Feature | MAMP Pro | REDAXO Multi-Instance |
|---------|----------|----------------------|
| **Kosten** | 💰 $99/Jahr | 🆓 Kostenlos / Sponsoring welcome|
| **PHP-Versionen** | ⚠️ Begrenzt | ✅ PHP 7.4-8.4 parallel |
| **Parallele Instanzen** | ⚠️ Komplex | ✅ Ein Befehl pro Instanz |
| **Isolation** | ❌ Shared Environment | ✅ Container-Isolation |
| **Version-Conflicts** | ❌ Häufig | ✅ Unmöglich |
| **REDAXO Auto-Install** | ❌ Manual | ✅ `--auto` Flag |
| **SSL/HTTPS** | ⚠️ Basic | ✅ mkcert Integration |
| **Backup-System** | ❌ Fehlt | ✅ Ein-Klick Backup/Restore |
| **Performance** | ⚠️ Overhead | ✅ Optimiert für REDAXO |
| **Portabilität** | ❌ macOS only | ✅ Docker überall |

**Konkrete Vorteile:**
- **🚀 Schneller**: REDAXO in 30 Sekunden statt 10 Minuten
- **🔧 Flexibler**: PHP 7.4 + 8.4 parallel ohne Konflikte  
- **💡 Entwicklerfreundlich**: Shell-Zugriff, Composer, Git direkt verfügbar
- **🔒 Sicherer**: Komplette Isolation zwischen Projekten
- **💾 Backup-Ready**: Automatische Datensicherung mit einem Befehl

---

## 🚀 Quick Start (3 Minuten)

### 1. Installation
```bash
# Repository klonen
git clone https://github.com/skerbis/redaxo-multi-instances.git
cd redaxo-multi-instances

# Automatisches Setup (installiert Docker, Node.js, etc.)
./setup.sh
```

### 2. Dashboard starten & stoppen
```bash
./dashboard-start         # Startet das Dashboard
./dashboard-start stop   # Beendet das Dashboard (Port 3000)
```
**Dashboard öffnet sich automatisch:** http://localhost:3000

### 3. Erste REDAXO-Instanz erstellen

#### 🎯 **Option A: Web-Dashboard (empfohlen)**
1. Klick auf **"Neue Instanz"**
2. Name eingeben (z.B. "mein-projekt")  
3. **"Auto-Install"** aktivieren
4. **"Instanz erstellen"** → Fertig!

#### 🎯 **Option B: Kommandozeile**
```bash
./redaxo create mein-projekt --auto
```

### 4. Ihre REDAXO-Instanz ist bereit! 🎉
- **Frontend:** https://localhost:8440
- **Backend:** https://localhost:8440/redaxo (user: admin / Passwort: admin123)
- **phpMyAdmin:** http://localhost:8180
- **Mailpit:** http://localhost:8120

> **💡 Alle URLs werden live im Dashboard angezeigt!**

---

## 📋 Systemvoraussetzungen

### **Minimal:**
- **macOS** 10.15+ (Catalina oder neuer)
- **Docker Desktop** 4.0+ ([Download](https://www.docker.com/products/docker-desktop/))
- **8 GB RAM** (empfohlen: 16 GB)
- **10 GB freier Speicher** für Docker Images

### **Was wird automatisch installiert:**
- ✅ Docker Desktop (falls nicht vorhanden)
- ✅ mkcert (SSL-Zertifikate)
- ✅ Node.js & npm (für Dashboard)
- ✅ Git & jq (Entwicklungstools)

### **Installation:**
```bash
# Docker Desktop installieren (GUI)
# Dann Homebrew-Tools:
brew install mkcert git
```

### **Automatisch zugewiesene Ports**
- **HTTP:** ab 8080 (8080, 8081, 8082...)
- **HTTPS:** ab 8440 (8440, 8441, 8442...)
- **phpMyAdmin:** ab 8180 (8180, 8181...)
- **Mailpit:** ab 8120 (8120, 8121...)

---

## 🎯 Features

- **🎛️ Dashboard** - Morphing Glass UI für einfache Verwaltung
- **🤖 Auto-Install** - Sofort einsatzbereit (`--auto`)
- **🐘 Multi-Version** - PHP 7.4-8.4, MariaDB 10.4-11.0
- **🔒 SSL/HTTPS** - Integriert via mkcert
- **📁 Flexible Strukturen** - Modern Structure oder klassisches REDAXO
- **💾 Backup-System** - Vollständige Datensicherung
- **📸 Snapshot-Funktion** - Schnappschuss einer Instanz anlegen & wiederherstellen
- **🏗️ Container-Isolation** - Jede Instanz komplett isoliert
- **🔧 Repair-System** - Automatische Docker-Problemlösung
- **📦 Import-System** - REDAXO-Dumps importieren
- **🧹 Smart-Cleanup** - Intelligente Bereinigung
- **🌐 Webserver-Only** - Reine PHP/Apache/MariaDB-Instanzen ohne REDAXO
- **🗄️ DB-Zugangsdaten** - Vollständige Datenbankinfo mit phpMyAdmin-Integration
- **💻 VS Code Integration** - Projekte direkt im Editor öffnen
- **📁 Finder Integration** - Direkter Zugriff auf Projektordner
- **🔐 Root-Berechtigung** - phpMyAdmin mit Admin-Rechten für Datenbank-Management
- **⚙️ Version-Updates** - PHP/MariaDB-Versionen direkt im Dashboard ändern
- **🎨 REDAXO-Logo** - Professionelles Branding im Dashboard-Header

---

## 🎛️ Dashboard Features

**Modernes Web-Dashboard mit Morphing Glass Design**

### **Live-Übersicht aller Instanzen**
- 📊 **Echtzeit-Status:** Läuft/Gestoppt/Wird erstellt
- 🖼️ **Screenshot-Vorschau** der Websites  
- 🔗 **Ein-Klick Zugriff** auf alle URLs
- ⚡ **Sofort-Aktionen:** Start/Stop/Löschen
- 🎨 **REDAXO-Logo:** Professionelles Branding im Header
- ⚙️ **Live-Versionsanzeige:** Aktuelle PHP/MariaDB-Versionen bei jeder Instanz

### **Intelligente Instanz-Erstellung**
- ✅ **Auto-Installation:** Komplettes REDAXO in 2 Minuten
- 📦 **Dump-Import:** Bestehende Projekte in 3-5 Minuten
- 🔧 **Version wählen:** PHP 7.4-8.4, MariaDB 10.4-11.0
- 🌐 **Webserver-Only:** Reine PHP/Apache/MariaDB-Instanzen
- 🚀 **VS Code Button:** Öffnet Projekt direkt im Editor
- 📸 **Snapshot:** Erstelle einen Schnappschuss deiner Instanz (inkl. Datenbank & Dateien) und stelle ihn bei Bedarf wieder her

### **Entwickler-Integration**
- 💻 **VS Code Integration:** Projekte mit einem Klick im Editor öffnen
- 📁 **Finder Integration:** Direkter Zugriff auf den Projektordner
- 🗄️ **DB-Zugangsdaten:** Vollständige Datenbankinfo mit Kopier-Buttons
- 🔐 **phpMyAdmin Root:** Vollständige Datenbank-Verwaltung mit Admin-Rechten
- 🐳 **Docker Terminal:** Direkter Container-Zugriff für Debugging
- ⚙️ **Version-Updates:** PHP/MariaDB-Versionen direkt im Dashboard ändern

### **Status-Anzeigen**
- 🟢 **Grün:** Instanz läuft perfekt
- 🟡 **Gelb:** Instanz gestoppt
- 🔵 **Blau (pulsierend):** Wird gerade erstellt...
- ⚙️ **Spinner:** REDAXO wird automatisch installiert

### **Dashboard verwenden:**

```bash
# Dashboard starten
./dashboard-start

# Dashboard öffnen
open http://localhost:3000

# Dashboard stoppen
./dashboard-start stop
```

**Dashboard-URL:** http://localhost:3000

---

## 📦 Dump-Import (Bestehende REDAXO-Projekte)

### **Ihr Client-Projekt schnell importieren**

#### **Schritt 1: Dump-Datei vorbereiten**
```bash
# Kopieren Sie Ihre REDAXO-Backups in den dump/ Ordner
cp /Downloads/client-projekt.zip dump/
```

#### **Schritt 2: Import starten**

**🎯 Web-Dashboard (einfach):**
1. **"Neue Instanz"** klicken
2. **"Dump importieren"** aktivieren
3. Dump-Datei aus Dropdown wählen
4. **"Instanz erstellen"** → Import läuft automatisch!

**🎯 Kommandozeile:**
```bash
./import-dump client-projekt client-projekt.zip
```

### **📋 Dump-Format (wichtig!)**
```
projekt-backup.zip
# Komplette REDAXO-Installation
├── index.php          
├── redaxo/            # Backend-Ordner
├── assets/            # Frontend-Assets
└── media/             # Medienpool
└── database.sql.zip       # ⚠️ MUSS als .sql.zip vorliegen!
```

**⚠️ Wichtig:** Die Datenbank-Datei muss als `.sql.zip` (nicht `.sql`) im Dump enthalten sein!

### **🎯 Anwendungsfälle**

- **🔄 Migration**: REDAXO-Sites von anderen Servern/MAMP migrieren
- **👥 Teamarbeit**: Kollegen können exakte Kopien von Projekten erhalten
- **🧪 Testing**: Produktionsdaten in isolierter Umgebung testen
- **🚀 Deployment**: Lokale Entwicklungsumgebungen schnell aufsetzen

---

## 🌐 Webserver-Only-Instanzen

**Reine PHP/Apache/MariaDB-Umgebungen ohne REDAXO** - Perfekt für eigene PHP-Projekte oder als Basis für andere CMS.

### **🎯 Wann Webserver-Only verwenden?**
- 🏗️ **Eigene PHP-Projekte** entwickeln
- 🎯 **Laravel, Symfony, CodeIgniter** und andere Frameworks
- 📊 **WordPress, Drupal** oder andere CMS installieren
- 🧪 **API-Entwicklung** mit reinem PHP
- 📚 **PHP-Learning** und Experimente

### **🚀 Webserver-Instanz erstellen**

#### **Web-Dashboard:**
1. **"Neue Instanz"** klicken
2. **"Nur Webserver"** aktivieren
3. PHP-Version wählen (7.4-8.4)
4. **"Instanz erstellen"** → Fertig!

#### **Kommandozeile:**
```bash
# Einfache Webserver-Instanz
./redaxo create mein-webserver --type webserver

# Mit spezifischer PHP-Version
./redaxo create api-projekt --type webserver --php-version 8.1

# Mit eigenen Ports
./redaxo create test-server --type webserver --http-port 8090 --https-port 8490
```

### **🔧 Was ist enthalten?**
- ✅ **Apache 2.4** mit mod_rewrite, SSL
- ✅ **PHP** (7.4-8.4) mit allen Standard-Extensions
- ✅ **MariaDB** mit vollem Admin-Zugriff
- ✅ **phpMyAdmin** mit Root-Berechtigung
- ✅ **SSL-Zertifikate** via mkcert
- ✅ **Informative index.php** mit allen Zugangsdaten

### **🗄️ Datenbankzugangsd Daten**
Webserver-Instanzen erhalten automatisch:
- **Host:** `mariadb` (Container-intern) / `localhost` (extern)
- **Database:** `{instanz-name}_db`
- **User:** `{instanz-name}_user`
- **Password:** `password123`
- **Root-Password:** `root123`

> 💡 **Im Dashboard:** Klick auf **"DB-Zugangsdaten"** zeigt alle Informationen mit Kopier-Buttons

### **📁 Projektstruktur**
```
instances/mein-webserver/
├── app/                    # Ihr Projektverzeichnis
│   └── index.php          # Informationsseite (überschreibbar)
├── docker-compose.yml     # Container-Konfiguration
└── .env                   # Umgebungsvariablen
```

> 🚀 **Direkt loslegen:** Ersetzen Sie `app/index.php` mit Ihrem PHP-Projekt!

---

## 📚 Befehlsreferenz

### **Instanz-Management**

```bash
# Snapshot einer Instanz anlegen
./redaxo snapshot <name>
# Snapshot wiederherstellen
./redaxo snapshot-recover <name>
```

```bash
# Dashboard starten
./dashboard-start
# Dashboard stoppen
./dashboard-start stop
# REDAXO-Instanzen erstellen
./redaxo create <name>                    # Manuelles Setup
./redaxo create <name> --auto             # Automatisches Setup mit admin/admin123
./redaxo create <name> --php-version 8.3  # Spezifische PHP-Version
./redaxo create <name> --repo redaxo/redaxo --auto  # Klassische REDAXO-Struktur

# Webserver-Only-Instanzen (ohne REDAXO)
./redaxo create <name> --type webserver                  # Nur Apache, PHP, MariaDB
./redaxo create <name> --type webserver --php-version 8.1  # Mit spezifischer PHP-Version

# Lebenszyklus
./redaxo start <name>                     # Instanz starten
./redaxo stop <name>                      # Instanz stoppen
./redaxo remove <name>                    # Instanz löschen
./redaxo remove all                       # Alle Instanzen löschen (mit Sicherheitsabfrage)

# Information
./redaxo list                             # Alle Instanzen anzeigen
./redaxo urls <name>                      # URLs der Instanz anzeigen
./redaxo db <name>                        # Datenbankzugangsdaten anzeigen
./redaxo shell <name>                     # Shell in Container öffnen
```

### **System-Wartung**

```bash
./redaxo cleanup                          # Docker-System bereinigen
./redaxo repair <name>                    # Docker-Probleme einer Instanz beheben
./redaxo update <name> --php-version 8.3  # PHP-Version ändern
./redaxo ssl-setup                        # SSL-Zertifikate einrichten
```

### **Import von Dumps**

```bash
./import-dump <name> <dump.zip>           # REDAXO aus Dump importieren
./import-dump <name> <dump.zip> --php-version 7.4  # Mit spezifischer PHP-Version
./redaxo import-dump <name> <dump.zip>    # Alternative über Hauptscript
```

---

## 🔧 Beispiele & Workflows

### **Schnelle Instanz-Erstellung**

```bash
# Neue Instanz mit Auto-Setup
./redaxo create kunde-xyz --auto
# → Login: admin/admin123

# Legacy-Projekt
./redaxo create legacy --php-version 7.4 --auto

# Klassische REDAXO-Struktur
./redaxo create klassisch --repo redaxo/redaxo --auto
```

### **Entwickler-Integration**

```bash
# Projekt im VS Code öffnen
./redaxo shell mein-projekt
code .

# Im Finder öffnen
open instances/mein-projekt/app
```

### **Testing mit Dump-Import**

```bash
# Neue Instanz für Testing
./redaxo create test-import --auto

# Dump importieren
./import-dump test-import mein-projekt.zip

# URLs anzeigen
./redaxo urls test-import
```

---

## 💻 Entwickler-Integration

**Nahtlose Integration in Ihren Entwicklungs-Workflow** - Das Dashboard bietet direkte Verbindungen zu Ihren bevorzugten Tools.

### **🚀 VS Code Integration**
- **Ein-Klick-Öffnung:** Projekt direkt im VS Code öffnen
- **Automatische Installation:** Setup-Script installiert VS Code und fügt `code`-Befehl hinzu
- **Fallback-Unterstützung:** Funktioniert auch ohne `code`-Befehl im PATH

**Verwendung:**
1. Im Dashboard: **3-Punkte-Menü → "VS Code öffnen"**
2. VS Code öffnet das `app/`-Verzeichnis der Instanz
3. Sofort entwicklungsbereit!

### **📁 Finder Integration**
- **Direkter Dateizugriff:** Projektordner im macOS Finder öffnen
- **Drag & Drop:** Einfaches Hochladen von Dateien und Assets
- **Datei-Management:** Schnelle Übersicht über Projektstruktur

**Verwendung:**
1. Im Dashboard: **3-Punkte-Menü → "Im Finder öffnen"**
2. Finder öffnet das `app/`-Verzeichnis
3. Direkter Zugriff auf alle Projektdateien

### **🗄️ Datenbank-Management**
- **Vollständige DB-Info:** Alle Zugangsdaten übersichtlich angezeigt
- **Kopier-Buttons:** Einfaches Kopieren von Credentials
- **phpMyAdmin-Integration:** Ein-Klick-Zugriff mit Root-Berechtigung
- **Neue Datenbanken erstellen:** Volle Admin-Rechte

**Verwendung:**
1. Im Dashboard: **3-Punkte-Menü → "DB-Zugangsdaten"**
2. Modal zeigt alle Informationen:
   - Host, Database, User, Password
   - Root-Password für Admin-Zugriff
   - Direkter phpMyAdmin-Link
3. **"phpMyAdmin öffnen"** für Datenbank-Verwaltung

### **⚙️ Version-Management**
- **PHP/MariaDB Updates:** Versionen direkt im Dashboard ändern
- **Live-Anzeige:** Aktuelle Versionen werden dynamisch erkannt
- **Ein-Klick-Update:** Keine Terminal-Befehle nötig
- **Timeout-Handling:** Robuste Update-Prozesse mit Fehlerbehandlung

**Verwendung:**
1. Im Dashboard: Bei jeder Instanz werden **aktuelle Versionen** angezeigt
2. **"PHP X.X" oder "MariaDB X.X"** Button klicken
3. Neue Version aus Dropdown wählen
4. **"Version aktualisieren"** → Update läuft automatisch
5. **Progress-Feedback** mit Timeout-Schutz

**Verfügbare Versionen:**
- **PHP:** 7.4, 8.0, 8.1, 8.2, 8.3, 8.4
- **MariaDB:** 10.4, 10.5, 10.6, 10.11, 11.0

### **�🐳 Docker Terminal**
- **Container-Zugriff:** Direkt in den Apache-Container einsteigen
- **Debugging:** Log-Dateien, Konfigurationen prüfen
- **Package-Installation:** Zusätzliche PHP-Extensions installieren

**Verwendung:**
1. Im Dashboard: **3-Punkte-Menü → "Docker Terminal"**
2. Terminal öffnet sich im Container
3. Voller Root-Zugriff auf Container-Umgebung

> 💡 **Pro-Tipp:** Alle Integrations-Features sind sowohl für REDAXO- als auch Webserver-Only-Instanzen verfügbar!

---

## ⚙️ PHP-Konfiguration

Alle Instanzen sind mit optimierten PHP-Einstellungen konfiguriert:

**Performance:**
- **OPcache aktiviert** für bessere Performance
- **256MB Speicherlimit**
- **64MB Upload-Limit** für Medien

**Fehlerbehandlung (produktionsfreundlich):**
- **Fehler werden geloggt**, aber nicht im Browser angezeigt
- **Error-Logs** unter `/var/log/php_errors.log`
- **Debugging** ohne Sicherheitsrisiko

### **Error-Logs einsehen**

```bash
./redaxo shell <name>
tail -f /var/log/php_errors.log
```

---

## 🚨 Troubleshooting

### **Automatische Diagnose**

```bash
# Vollständige System-Diagnose ausführen
./diagnose.sh

# Zeigt Status von:
# - Docker Desktop
# - Node.js & npm
# - Dashboard
# - REDAXO-Instanzen
# - Ports und Netzwerk
# - Log-Dateien
```

### **Häufige Probleme**

#### **1. Setup-Script schlägt fehl**

**Problem:** `./setup.sh` bricht mit Fehlern ab

**Lösung:**
```bash
# Prüfen Sie die Berechtigung
chmod +x setup.sh

# Homebrew manuell installieren
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Setup erneut versuchen
./setup.sh
```

#### **2. Docker Desktop startet nicht**

**Problem:** Docker Desktop läuft nicht oder ist nicht installiert

**Lösung:**
```bash
# Docker Desktop Status prüfen
docker info

# Falls nicht installiert:
# 1. Besuchen Sie: https://www.docker.com/products/docker-desktop/
# 2. Laden Sie Docker Desktop für Mac herunter
# 3. Installieren und starten Sie es
# 4. Setup erneut ausführen: ./setup.sh
```

#### **3. Dashboard startet nicht**

**Problem:** Dashboard ist nicht erreichbar unter http://localhost:3000

**Diagnose:**
```bash
# Port-Konflikt prüfen
lsof -i :3000

# Dashboard-Logs prüfen
cat dashboard.log

# Dependencies prüfen
cd dashboard && npm list
```

**Lösung:**
```bash
# Dependencies neu installieren
cd dashboard
rm -rf node_modules package-lock.json
npm install

# Dashboard manuell starten
npm start

# Oder anderen Port verwenden
PORT=3001 npm start
```

#### **4. REDAXO-Instanz startet nicht**

**Problem:** Container startet nicht oder ist nicht erreichbar

**Diagnose:**
```bash
# Container-Status prüfen
docker ps -a

# Container-Logs prüfen
docker logs redaxo-INSTANZNAME

# Docker-Netzwerk prüfen
docker network ls | grep redaxo
```

**Lösung:**
```bash
# Container stoppen und neu starten
./redaxo stop INSTANZNAME
./redaxo start INSTANZNAME

# Bei Port-Konflikten anderen Port verwenden
./redaxo create INSTANZNAME --port 8081

# Docker-Netzwerk neu erstellen
docker network rm redaxo-network
docker network create redaxo-network
```

### **Komplette Neuinstallation**

Wenn alle anderen Lösungen fehlschlagen:

```bash
# 1. Alle Container stoppen und löschen
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)

# 2. Docker-Netzwerk entfernen
docker network rm redaxo-network

# 3. Dashboard-Dependencies löschen
rm -rf dashboard/node_modules dashboard/package-lock.json

# 4. Setup komplett neu ausführen
./setup.sh
```

### **Support und Community**

**Bei weiterhin bestehenden Problemen:**

1. **GitHub Issues:** Erstellen Sie ein Issue mit:
   - Ausgabe von `./diagnose.sh`
   - Fehlermeldungen und Logs
   - Ihre macOS-Version und Hardware

2. **REDAXO Community:** 
   - REDAXO Slack
   - REDAXO Forum

3. **Debug-Informationen sammeln:**
```bash
# Debug-Informationen sammeln
./diagnose.sh > debug-info.txt
echo "=== Dashboard Log ===" >> debug-info.txt
tail -n 50 dashboard.log >> debug-info.txt
echo "=== Docker Info ===" >> debug-info.txt
docker system info >> debug-info.txt 2>&1

# debug-info.txt mit Issue anhängen
```

---

## 💡 Pro-Tipps

### **⚡ Performance**
- **16+ GB RAM** für viele parallele Instanzen
- **SSD** für bessere Docker-Performance
- **`./redaxo cleanup`** regelmäßig ausführen

### **🔧 Entwicklung**
- **VS Code Button** im Dashboard nutzen
- **Screenshot-Feature** für Client-Präsentationen
- **Mailpit** für E-Mail-Testing

### **🗂️ Organisation**
- **Sprechende Namen** verwenden: `client-website`, `test-php84`
- **Backup vor größeren Änderungen:** `./redaxo backup projektname`
- **Dashboard immer offen** lassen für Live-Updates

---

## 🔐 Sicherheit & Hinweise

- ⚠️ **Nur für lokale Entwicklung** - nicht für Produktion!
- 🔒 **Selbstsignierte SSL-Zertifikate** (Browser-Warnung normal)
- 🐳 **Isolierte Container** - keine Konflikte zwischen Projekten  
- 🌐 **Keine Exposition** nach außen - alles läuft lokal

---

## 🤝 Contributing & Support

### **Hilfe benötigt?**
- 🐛 **Bug melden:** [GitHub Issues](https://github.com/skerbis/redaxo-multi-instances/issues)
- 💬 **Fragen stellen:** [GitHub Discussions](https://github.com/skerbis/redaxo-multi-instances/discussions)

### **Mithelfen?**
1. Repository forken
2. Feature-Branch erstellen
3. Pull Request senden

---

## 👨‍💻 Über den Entwickler

Dieses Tool wurde von **[Thomas Skerbis](https://github.com/skerbis)** entwickelt - Geschäftsführer der **[KLXM Crossmedia GmbH](https://klxm.de)** und aktiver **Friend of REDAXO**.

### **🏆 REDAXO-Expertise**
- **Core-Contributor** bei [REDAXO](https://github.com/redaxo/redaxo) (336⭐)
- **Maintainer** der [REDAXO-Dokumentation](https://github.com/redaxo/docs)
- **Entwickler** von 50+ REDAXO AddOns bei [FriendsOfREDAXO](https://github.com/FriendsOfREDAXO)

### **🌟 Beliebte REDAXO-AddOns**
- **[Quick Navigation](https://github.com/FriendsOfREDAXO/quick_navigation)** (67⭐) - Backend-Navigation
- **[erecht24](https://github.com/FriendsOfREDAXO/erecht24)** (18⭐) - Rechtstexte-Integration
- **[sA11y](https://github.com/FriendsOfREDAXO/for_sa11y)** (18⭐) - Accessibility-Check
- **[Vidstack](https://github.com/FriendsOfREDAXO/vidstack)** (10⭐) - Moderne Video-Player 

---

## ❤️ Support

Wenn dir dieses Tool gefällt und du die Entwicklung unterstützen möchtest:

[![GitHub Sponsors](https://img.shields.io/badge/Sponsor-❤-red?style=for-the-badge&logo=github)](https://github.com/sponsors/skerbis)

**🎯 Entwickelt für REDAXO-Entwickler und Design-Teams**

Das System ersetzt MAMP komplett und bietet zusätzlich Penpot als lokale Figma-Alternative - alles mit deutlich mehr Flexibilität bei geringeren Kosten und besserer Performance.

---

## 📄 Lizenz

MIT-Lizenz - siehe [LICENSE.md](LICENSE.md)

---

<div align="center">

**⭐ Gefällt Ihnen das Projekt? Geben Sie uns einen Stern!**

**Made with ❤️ for the REDAXO Community**

[🚀 Dashboard starten](./dashboard-start) • [📖 Vollständige Docs](./QUICKSTART.md) • [🆘 Support](https://github.com/skerbis/redaxo-multi-instances/issues)

</div>
