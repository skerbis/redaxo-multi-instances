# 🚀 REDAXO Multi-Instance Manager

> Automatisierte REDAXO-Instanzen + Penpot Design Tool für macOS-Entwickler - MAMP war gestern

**Ein Befehl → Komplette REDAXO-Installation mit beliebigen PHP/MariaDB-Versionen + Penpot Design-Umgebung**

## 📋 Inhaltsverzeichnis

- [⚡ Quick Start](#-quick-start)
- [🆚 Warum besser als MAMP?](#-warum-besser-als-mamp)
- [📋 Systemvoraussetzungen](#-systemvoraussetzungen)
- [🎯 Features](#-features)
- [📚 Befehlsreferenz](#-befehlsreferenz)
  - [Instanz-Management](#instanz-management)
  - [Backup & Restore](#backup--restore)
  - [System-Wartung](#system-wartung)
  - [Import von Dumps](#import-von-dumps)
- [📦 REDAXO-Import aus Dumps](#-redaxo-import-aus-dumps)
- [🎨 Penpot Design Tool](#-penpot-design-tool)
- [🔧 Beispiele & Workflows](#-beispiele--workflows)
- [⚙️ PHP-Konfiguration](#️-php-konfiguration)
- [🚨 Troubleshooting](#-troubleshooting)

## ⚡ Quick Start

```bash
# 1. Voraussetzungen installieren
brew install mkcert git

# 2. Projekt einrichten
git clone https://github.com/skerbis/redaxo-multi-instances.git && cd redaxo-multi-instances
chmod +x redaxo import-dump penpot
./redaxo ssl-setup

# 3. Erste REDAXO-Instanz erstellen
./redaxo create myproject --auto

# ✅ Fertig: https://localhost:8080/redaxo/ (admin/admin123)
```

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