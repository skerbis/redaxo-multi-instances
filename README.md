# 🚀 REDAXO Multi-Instance Manager

**Das moderne Dashboard für REDAXO-Entwickler** - Erstellen und verwalten Sie beliebig viele REDAXO-Instanzen mit einem Klick!

![REDAXO Multi-Instance Dashboard](https://img.shields.io/badge/REDAXO-Multi--Instance-4f7df3?style=for-the-badge&logo=docker)
![Version](https://img.shields.io/badge/Version-2.0-success?style=for-the-badge)

> 🎯 **Perfekt für:** Lokale Entwicklung, Client-Projekte, Testing verschiedener REDAXO-Versionen, Dump-Import

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
- **VS Code Integration** - öffnet Projekte direkt
- **Automatische Port-Verwaltung** - keine Konfiguration nötig
- **Backup/Restore System** für Projekte
- **CLI + Web-Interface** - wie Sie möchten

## 🚀 Quick Start (3 Minuten)

### 1. Installation
```bash
# Repository klonen
git clone https://github.com/skerbis/redaxo-multi-instances.git
cd redaxo-multi-instances

# Automatisches Setup (installiert Docker, Node.js, etc.)
./setup.sh
```

### 2. Dashboard starten
```bash
./dashboard-start
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
- **Backend:** https://localhost:8440/redaxo  
- **phpMyAdmin:** http://localhost:8180
- **Mailpit:** http://localhost:8120

> **💡 Alle URLs werden live im Dashboard angezeigt!**
- ✅ Node.js & npm (für Dashboard)
- ✅ Git & jq (Entwicklungstools)
## 📦 Dump-Import (Bestehende REDAXO-Projekte)

### Ihr Client-Projekt schnell importieren

#### Schritt 1: Dump-Datei vorbereiten
```bash
# Kopieren Sie Ihre REDAXO-Backups in den dump/ Ordner
cp /Downloads/client-projekt.zip dump/
```

#### Schritt 2: Import starten

**🎯 Web-Dashboard (einfach):**
1. **"Neue Instanz"** klicken
2. **"Dump importieren"** aktivieren
3. Dump-Datei aus Dropdown wählen
4. **"Instanz erstellen"** → Import läuft automatisch!

**🎯 Kommandozeile:**
```bash
./import-dump client-projekt client-projekt.zip
```

### 📋 Dump-Format (wichtig!)
```
projekt-backup.zip
├── app/                    # Komplette REDAXO-Installation
│   ├── index.php          
│   ├── redaxo/            # Backend-Ordner
│   ├── assets/            # Frontend-Assets
│   └── media/             # Medienpool
└── database.sql.zip       # ⚠️ MUSS als .sql.zip vorliegen!
```

**⚠️ Wichtig:** Die Datenbank-Datei muss als `.sql.zip` (nicht `.sql`) im Dump enthalten sein!

## 🎛️ Dashboard Features

### **Live-Übersicht aller Instanzen**
- 📊 **Echtzeit-Status:** Läuft/Gestoppt/Wird erstellt
- 🖼️ **Screenshot-Vorschau** der Websites  
- 🔗 **Ein-Klick Zugriff** auf alle URLs
- ⚡ **Sofort-Aktionen:** Start/Stop/Löschen

### **Intelligente Instanz-Erstellung**
- ✅ **Auto-Installation:** Komplettes REDAXO in 2 Minuten
- 📦 **Dump-Import:** Bestehende Projekte in 3-5 Minuten
- 🔧 **Version wählen:** PHP 7.4-8.4, MariaDB 10.4-11.0
- 🚀 **VS Code Button:** Öffnet Projekt direkt im Editor

### **Status-Anzeigen**
- 🟢 **Grün:** Instanz läuft perfekt
- 🟡 **Gelb:** Instanz gestoppt
- 🔵 **Blau (pulsierend):** Wird gerade erstellt...
- ⚙️ **Spinner:** REDAXO wird automatisch installiert

## 🛠️ Die wichtigsten Befehle

### **Schnellstart**
```bash
./redaxo create projekt --auto              # Neue Instanz mit REDAXO
./redaxo list                               # Alle Instanzen anzeigen
./redaxo urls projekt                       # URLs einer Instanz
```

### **Instanz-Management**
```bash
./redaxo start projekt                      # Instanz starten
./redaxo stop projekt                       # Instanz stoppen
./redaxo remove projekt                     # Instanz löschen
```

### **Erweitert**
```bash
# Mit spezifischen Versionen
./redaxo create projekt --php-version 8.3 --mariadb-version 11.0 --auto

# Dump importieren
./import-dump projekt backup.zip

# Backup/Restore
./redaxo backup projekt
./redaxo restore projekt backup.tar.gz
```

## 🏗️ Was brauche ich?

### **System-Anforderungen**
- **macOS 10.15+** (oder Windows/Linux mit Docker)
- **8 GB RAM** (empfohlen: 16 GB für mehrere Instanzen)
- **Docker Desktop** (wird automatisch installiert)
- **5 GB freier Speicher** pro Instanz

### **Automatisch zugewiesene Ports**
- **HTTP:** ab 8080 (8080, 8081, 8082...)
- **HTTPS:** ab 8440 (8440, 8441, 8442...)
- **phpMyAdmin:** ab 8180 (8180, 8181...)
- **Mailpit:** ab 8120 (8120, 8121...)

## 🚨 Problemlösung

### **Dashboard startet nicht**
```bash
# Port prüfen
lsof -i :3000

# Docker neu starten
docker system prune
./dashboard-start
```

### **Instanz startet nicht**  
```bash
# Logs anzeigen
docker logs redaxo-projektname-apache

# Reparatur versuchen
./redaxo repair projektname
```

### **"Wird erstellt..." bleibt hängen**
```bash
# Docker-Status prüfen
docker ps -a

# System bereinigen  
./redaxo cleanup
```

### **SSL-Warnung im Browser**
Das ist normal! Wir verwenden selbstsignierte Zertifikate für lokale Entwicklung.
→ **"Erweitert" → "Trotzdem fortfahren"** klicken

## 🎯 Häufige Use Cases

### **🔬 Lokale REDAXO-Entwicklung**
```bash
./redaxo create dev-projekt --php-version 8.4 --auto
# → Perfekte Entwicklungsumgebung in 2 Minuten
```

### **🧪 Verschiedene PHP-Versionen testen**
```bash
./redaxo create test-php83 --php-version 8.3 --auto
./redaxo create test-php84 --php-version 8.4 --auto
# → Beide laufen parallel!
```

### **📦 Client-Projekt importieren**
```bash
# Dump ins Verzeichnis
cp ~/Downloads/client-backup.zip dump/

# Import via Dashboard oder:
./import-dump client-projekt client-backup.zip
```

### **🚀 Demo für Kunden**
```bash
./redaxo create demo --auto
# → Sofort bereite Demo-Instanz
```

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

## 🔐 Sicherheit & Hinweise

- ⚠️ **Nur für lokale Entwicklung** - nicht für Produktion!
- 🔒 **Selbstsignierte SSL-Zertifikate** (Browser-Warnung normal)
- 🐳 **Isolierte Container** - keine Konflikte zwischen Projekten  
- 🌐 **Keine Exposition** nach außen - alles läuft lokal

## 🤝 Contributing & Support

### **Hilfe benötigt?**
- 🐛 **Bug melden:** [GitHub Issues](https://github.com/skerbis/redaxo-multi-instances/issues)
- 💬 **Fragen stellen:** [GitHub Discussions](https://github.com/skerbis/redaxo-multi-instances/discussions)

### **Mithelfen?**
1. Repository forken
2. Feature-Branch erstellen
3. Pull Request senden

## 📄 Lizenz

MIT-Lizenz - siehe [LICENSE.md](LICENSE.md)

---

<div align="center">

**⭐ Gefällt Ihnen das Projekt? Geben Sie uns einen Stern!**

**Made with ❤️ for the REDAXO Community**

[🚀 Dashboard starten](./dashboard-start) • [📖 Vollständige Docs](./QUICKSTART.md) • [🆘 Support](https://github.com/skerbis/redaxo-multi-instances/issues)

</div>
```

## 🎛️ Dashboard

**Modernes Web-Dashboard mit Morphing Glass Design**

![Dashboard Screenshot](dashboard-preview.png)

### Features:
- 🎨 **Morphing Glass Design** - Moderne, glasartige Benutzeroberfläche
- 📱 **Responsive Layout** - Funktioniert auf Desktop und Mobile
- 🔄 **Real-time Updates** - Live-Status aller Instanzen
- 📊 **Container-Informationen** - PHP/MariaDB Versionen, Port-Info
- 📸 **Screenshots** - Automatische Website-Vorschau mit Puppeteer
- 🔗 **Smart URL-Menü** - Direktlinks + VS Code Integration
- ⚡ **Ein-Klick-Management** - Start/Stop/Create/Delete Instanzen

### Dashboard verwenden:

```bash
# Dashboard starten
./dashboard-start

# Dashboard öffnen
open http://localhost:3000

# Dashboard stoppen
# Ctrl+C im Terminal
```

### Dashboard-Features:

1. **Instanzen verwalten:**
   - ✅ Neue Instanzen erstellen (mit PHP/MariaDB Auswahl)
   - ▶️ Instanzen starten/stoppen
   - 🗑️ Instanzen löschen
   - 📊 Container-Status und Informationen

2. **Smart URL-Menü:**
   - 🌐 REDAXO Frontend
   - ⚙️ REDAXO Backend
   - 📊 Adminer (Datenbank)
   - 💻 VS Code Integration (`vscode://file//pfad/zur/instanz`)

3. **Screenshots:**
   - 📸 Automatische Website-Vorschau
   - 💾 Persistente Speicherung
   - 🔄 Bleibt sichtbar auch wenn Instanz gestoppt

4. **Real-time Updates:**
   - 🔄 Live-Status ohne Seiten-Reload
   - ⚡ Socket.IO für Echtzeit-Kommunikation

**Dashboard-Features:**
- 🎨 **Morphing Glass Design** - Modernes glasmorphisches UI
- 📋 **Instanzen-Übersicht** - Alle REDAXO-Instanzen auf einen Blick  
- 🚀 **Start/Stop-Kontrolle** - Instanzen direkt über das Dashboard steuern
- ➕ **Neue Instanzen erstellen** - Einfache Erstellung mit Formular
- 🗑️ **Instanzen löschen** - Sichere Löschung mit Bestätigung
- 🔗 **Direkte Links** - Frontend, Backend, phpMyAdmin und Mailpit
- 📱 **Responsive Design** - Funktioniert auf Desktop und Mobile
- 🔄 **Live-Updates** - Automatische Aktualisierung des Status

**Dashboard-URL:** http://localhost:3000

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

## 📋 Systemvoraussetzungen

**Minimal:**
- **macOS** 10.15+ (Catalina oder neuer)
- **Docker Desktop** 4.0+ ([Download](https://www.docker.com/products/docker-desktop/))
- **8 GB RAM** (empfohlen: 16 GB)
- **10 GB freier Speicher** für Docker Images

**Installation:**
```bash
# Docker Desktop installieren (GUI)
# Dann Homebrew-Tools:
brew install mkcert git
```

## 🎯 Features

- **🎛️ Dashboard** - Morphing Glass UI für einfache Verwaltung
- **🤖 Auto-Install** - Sofort einsatzbereit (`--auto`)
- **🐘 Multi-Version** - PHP 7.4-8.4, MariaDB 10.4-11.0
- **🔒 SSL/HTTPS** - Integriert via mkcert
- **📁 Flexible Strukturen** - Modern Structure oder klassisches REDAXO
- **💾 Backup-System** - Vollständige Datensicherung
- **🏗️ Container-Isolation** - Jede Instanz komplett isoliert
- **🔧 Repair-System** - Automatische Docker-Problemlösung
- **📦 Import-System** - REDAXO-Dumps importieren
- **🎨 Penpot Integration** - Lokales Design & Prototyping Tool
- **🧹 Smart-Cleanup** - Intelligente Bereinigung

## 📚 Befehlsreferenz

### Instanz-Management

```bash
# Erstellen
./redaxo create <name>                    # Manuelles Setup
./redaxo create <name> --auto             # Automatisches Setup mit admin/admin123
./redaxo create <name> --php-version 8.3  # Spezifische PHP-Version
./redaxo create <name> --repo redaxo/redaxo --auto  # Klassische REDAXO-Struktur

# Lebenszyklus
./redaxo start <name>                     # Instanz starten
./redaxo stop <name>                      # Instanz stoppen
./redaxo remove <name>                    # Instanz löschen
./redaxo remove all                       # Alle Instanzen löschen (mit Sicherheitsabfrage)

# Information
./redaxo list                             # Alle Instanzen anzeigen
./redaxo urls <name>                      # URLs der Instanz anzeigen
./redaxo shell <name>                     # Shell in Container öffnen
```

### Backup & Restore

```bash
./redaxo backup <name>                    # Backup erstellen
./redaxo restore <name> <backup>          # Backup wiederherstellen
./redaxo backups                          # Alle Backups anzeigen
```

### System-Wartung

```bash
./redaxo cleanup                          # Docker-System bereinigen
./redaxo repair <name>                    # Docker-Probleme einer Instanz beheben
./redaxo update <name> --php-version 8.3  # PHP-Version ändern
./redaxo ssl-setup                        # SSL-Zertifikate einrichten
```

### Import von Dumps

```bash
./import-dump <name> <dump.zip>           # REDAXO aus Dump importieren
./import-dump <name> <dump.zip> --php-version 7.4  # Mit spezifischer PHP-Version
./redaxo import-dump <name> <dump.zip>    # Alternative über Hauptscript
```

## 📦 REDAXO-Import aus Dumps

Das Import-System ermöglicht es, bestehende REDAXO-Installationen aus Backup-Dateien zu importieren.

### 🎯 Anwendungsfälle

- **🔄 Migration**: REDAXO-Sites von anderen Servern/MAMP migrieren
- **👥 Teamarbeit**: Kollegen können exakte Kopien von Projekten erhalten
- **🧪 Testing**: Produktionsdaten in isolierter Umgebung testen
- **🚀 Deployment**: Lokale Entwicklungsumgebungen schnell aufsetzen

### 📋 Dump-Struktur

```
dump.zip
├── app/                    # Komplette REDAXO-Installation
│   ├── index.php          # REDAXO Entry Point
│   ├── redaxo/            # REDAXO Backend
│   ├── assets/            # Frontend-Assets
│   └── media/             # Medienpool
└── *.sql.zip              # Datenbank-Dump (gezippt!)
```

**Wichtige Hinweise:**
- ✅ **SQL-Datei muss gezippt sein** (`*.sql.zip`, nicht `.sql`)
- ✅ **Genau eine SQL-Zip-Datei** pro Dump
- ✅ **Automatische Struktur-Erkennung**: Modern Structure oder klassisches REDAXO

### 🚀 Import-Prozess

```bash
# Dump in dump/ Ordner legen
cp /path/to/backup.zip dump/

# Import starten
./import-dump mein-projekt backup.zip

# Automatisch generierte URLs:
# → HTTPS: https://localhost:8441/
# → Backend: https://localhost:8441/redaxo/
# → phpMyAdmin: http://localhost:8442/
```

**Was passiert automatisch:**
1. **Extraktion & Validierung** des Dumps
2. **Struktur-Erkennung** (Modern/Klassisch)
3. **Container-Setup** mit passender Konfiguration
4. **Datenbank-Import** aus SQL-Dump
5. **REDAXO-Konfiguration** für lokale Umgebung
6. **SSL-Zertifikat** generieren

## 🎨 Penpot Design Tool

Zusätzlich zu REDAXO bietet das System auch **Penpot** - ein Open-Source Design & Prototyping Tool als Alternative zu Figma.

### 🎯 Penpot Features

- **🎨 Design & Prototyping** - Vollwertiges Design-Tool für UI/UX
- **👥 Team-Collaboration** - Echtzeit-Zusammenarbeit wie bei Figma
- **🔓 Open Source** - Keine Vendor Lock-ins, volle Kontrolle
- **🚀 Lokale Instanzen** - Jedes Team/Projekt bekommt eigene Instanz
- **💾 Backup-System** - Komplette Projektdaten sicherbar

### 🚀 Penpot Commands

```bash
# Neue Design-Instanz erstellen
./penpot create design-team
./penpot create kunde-a --port 9090

# Instanz-Management
./penpot start design-team           # Penpot-Instanz starten
./penpot stop design-team            # Penpot-Instanz stoppen
./penpot urls design-team            # URLs anzeigen
./penpot list                        # Alle Penpot-Instanzen

# Backup & Restore
./penpot backup design-team          # Design-Daten sichern
./penpot restore design-team backup_20250528_143022
./penpot backups                     # Alle Penpot-Backups

# Wartung
./penpot shell design-team           # Container-Shell öffnen
./penpot logs design-team            # Container-Logs
./penpot repair design-team          # Probleme beheben
./penpot cleanup                     # Docker bereinigen
```

**Automatisch verfügbar:**
- **🎨 Design-Interface**: `https://localhost:9090` (oder custom Port)
- **🔒 SSL-Verschlüsselung** mit mkcert-Zertifikaten
- **🏗️ Isolierte Instanzen** - Jedes Team arbeitet in eigener Umgebung
- **💾 PostgreSQL + Redis** - Vollständige Backend-Infrastruktur

### 🎯 Anwendungsfälle

- **🏢 Agentur-Workflows**: Jeder Kunde bekommt eigene Penpot-Instanz
- **👥 Team-Isolation**: Design-Teams arbeiten in separaten Umgebungen  
- **🧪 Design-Testing**: Experimentelle Designs in Sandbox-Umgebung
- **🔒 Datenschutz**: Sensible Designs bleiben auf eigenem Server

## 🔧 Beispiele & Workflows

### Schnelle Instanz-Erstellung

```bash
# Neue Instanz mit Auto-Setup
./redaxo create kunde-xyz --auto
# → Login: admin/admin123

# Legacy-Projekt
./redaxo create legacy --php-version 7.4 --auto

# Klassische REDAXO-Struktur
./redaxo create klassisch --repo redaxo/redaxo --auto
```

### Backup-Workflow

```bash
# Vor wichtigen Änderungen
./redaxo backup produktiv-site

# Entwickeln...
./redaxo shell produktiv-site

# Bei Problemen zurücksetzen
./redaxo restore produktiv-site produktiv-site_20250528_143022
```

### Team-Collaboration

```bash
# Entwickler A: Backup erstellen
./redaxo backup projekt-v1
# → Teilt projekt-v1_20250528_143022.zip

# Entwickler B: Import
./import-dump projekt-copy projekt-v1_20250528_143022.zip
```

### Mehrere Versionen parallel

```bash
./redaxo create test-php74 --php-version 7.4 --auto
./redaxo create test-php83 --php-version 8.3 --auto
./redaxo create test-php84 --php-version 8.4 --auto
./redaxo list  # Alle parallel verfügbar
```

### Penpot Design-Workflow

```bash
# Design-Umgebung für Agentur
./penpot create kunde-xyz-design
./penpot create interne-projekte --port 9100

# Team-Backup vor großen Änderungen
./penpot backup kunde-xyz-design

# Design-Review
./penpot urls kunde-xyz-design
# → Öffnet: https://localhost:9090

# Bei Problemen: Backup wiederherstellen
./penpot restore kunde-xyz-design kunde-xyz-design_20250528_143022
```

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

### Error-Logs einsehen

```bash
./redaxo shell <name>
tail -f /var/log/php_errors.log
```

## 🚨 Troubleshooting

### Automatische Diagnose

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

### Häufige Probleme

#### 1. Setup-Script schlägt fehl

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

#### 2. Docker Desktop startet nicht

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

#### 3. Dashboard startet nicht

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

#### 4. REDAXO-Instanz startet nicht

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

#### 5. Node.js Version zu alt

**Problem:** Node.js Version < 16 wird verwendet

**Lösung:**
```bash
# Node.js über Homebrew aktualisieren
brew upgrade node

# Version prüfen
node --version  # Sollte >= v16 sein

# Dashboard-Dependencies neu installieren
cd dashboard && npm install
```

#### 6. Puppeteer/Screenshot-Probleme

**Problem:** Screenshots werden nicht erstellt oder zeigen Fehler

**Lösung:**
```bash
# Puppeteer neu installieren
cd dashboard
npm uninstall puppeteer
npm install puppeteer

# Chromium manuell installieren
npx puppeteer browsers install chrome

# Dashboard neu starten
npm start
```

#### 7. Port bereits belegt

**Problem:** Port 3000 oder andere Ports sind bereits in Verwendung

**Diagnose:**
```bash
# Alle belegten Ports anzeigen
./diagnose.sh | grep -A 20 "Port-Status"

# Spezifischen Port prüfen
lsof -i :3000
```

**Lösung:**
```bash
# Dashboard auf anderem Port starten
cd dashboard
PORT=3001 npm start

# Oder belegenden Prozess beenden
kill $(lsof -t -i:3000)
```

#### 8. Fehlende Berechtigungen

**Problem:** Scripts sind nicht ausführbar

**Lösung:**
```bash
# Alle Berechtigungen setzen
chmod +x *.sh redaxo manager dashboard-start import-dump diagnose.sh

# Oder Setup erneut ausführen
./setup.sh
```

#### 9. Docker-Netzwerk Probleme

**Problem:** Container können nicht miteinander kommunizieren

**Lösung:**
```bash
# Docker-Netzwerk neu erstellen
docker network rm redaxo-network
docker network create redaxo-network

# Alle Container stoppen und neu starten
./redaxo stop-all
./redaxo start-all
```

#### 10. Homebrew nicht im PATH

**Problem:** `brew: command not found` nach Installation

**Lösung:**
```bash
# Homebrew zu PATH hinzufügen
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"

# Terminal neu starten
source ~/.zprofile

# Homebrew testen
brew --version
```

### Komplette Neuinstallation

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

### Logs und Debugging

**Dashboard-Logs:**
```bash
# Live-Logs anzeigen
tail -f dashboard.log

# Fehler-Logs filtern
grep -i error dashboard.log
```

**Docker-Logs:**
```bash
# Container-Logs anzeigen
docker logs redaxo-INSTANZNAME

# Live-Logs verfolgen
docker logs -f redaxo-INSTANZNAME
```

**System-Status:**
```bash
# Vollständige Diagnose
./diagnose.sh

# Docker-Status
docker system info

# Node.js und npm Status
node --version && npm --version
```

### Support und Community

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

### Häufige Probleme

**Container startet nicht:**
```bash
./redaxo repair <name>     # Automatische Reparatur
./redaxo list              # Status prüfen
```

**Port-Konflikte:**
```bash
lsof -i :8080             # Port-Usage prüfen
```

**Performance-Probleme:**
```bash
./redaxo cleanup          # Docker-System bereinigen
docker system df          # Speicherverbrauch prüfen
```

**Kompletter Neustart:**
```bash
./redaxo remove all       # Alle Instanzen löschen (Sicherheitsabfrage)
./redaxo cleanup          # System bereinigen
```

### Debugging

```bash
# Container-Logs ansehen
docker logs redaxo-<name>-apache
docker logs redaxo-<name>-mariadb

# Shell für Debugging
./redaxo shell <name>

# Status aller Container
docker ps -a
```

---

## 👨‍💻 Über den Entwickler

Dieses Tool wurde von **[Thomas Skerbis](https://github.com/skerbis)** entwickelt - Geschäftsführer der **[KLXM Crossmedia GmbH](https://klxm.de)** und aktiver **Friend of REDAXO**.

### 🏆 REDAXO-Expertise
- **Core-Contributor** bei [REDAXO](https://github.com/redaxo/redaxo) (336⭐)
- **Maintainer** der [REDAXO-Dokumentation](https://github.com/redaxo/docs)
- **Entwickler** von 50+ REDAXO AddOns bei [FriendsOfREDAXO](https://github.com/FriendsOfREDAXO)

### 🌟 Beliebte REDAXO-AddOns
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