# 🚀 REDAXO Multi-Instance Manager

> Automatisierte REDAXO-Instanzen für macOS-Entwickler - MAMP war gestern

**Ein Befehl → Komplette REDAXO-Installation mit beliebigen PHP/MariaDB-Versionen**

## ⚡ Quick Start

```bash
# Voraussetzungen (macOS)
brew install mkcert
# + Docker Desktop

# Setup
git clone <repo-url> redaxo-multi-instances && cd redaxo-multi-instances
chmod +x redaxo
./redaxo ssl-setup

# Automatische REDAXO-Installation
./redaxo create myproject --auto

# ✅ Fertig: http://localhost:8080/redaxo/ (admin/admin123)
```

## 🎯 Features

- **🤖 Auto-Install** - Sofort einsatzbereit (`--auto`)
- **🐘 Multi-Version** - PHP 7.4-8.4, MariaDB 10.4-11.0
- **🔒 SSL/HTTPS** - Integriert via mkcert
- **🌐 Webserver-Mode** - Pure PHP-Instanzen
- **🔧 Port-Auto** - Keine Konflikte
- **💾 Backup-System** - Vollständige Datensicherung

## 📚 Befehle

```bash
# Instanz erstellen
./redaxo create <name>                    # Manuelles Setup
./redaxo create <name> --auto             # Automatisches Setup
./redaxo create <name> --php-version 8.3  # Spezifische PHP-Version

# Verwaltung
./redaxo start|stop|remove <name>         # Lebenszyklus
./redaxo list                             # Übersicht
./redaxo urls <name>                      # URLs anzeigen
./redaxo shell <name>                     # Shell in Container

# Backup & Restore
./redaxo backup <name>                    # Backup erstellen
./redaxo restore <name> <backup>          # Backup wiederherstellen
./redaxo backups                          # Alle Backups anzeigen

# System-Wartung
./redaxo cleanup                          # Docker-System bereinigen

# Versionen ändern
./redaxo update <name> --php-version 8.3  # PHP updaten
```

## 🔧 Beispiele

**Automatisches Setup (empfohlen)**
```bash
./redaxo create projekt --auto
# → Sofort einsatzbereit: http://localhost:8080/redaxo/
```

**Verschiedene Versionen**
```bash
# Legacy-Projekt
./redaxo create alt --php-version 7.4 --auto

# Modern 
./redaxo create neu --php-version 8.4 --auto

# API-Server (ohne Datenbank)
./redaxo create api --type webserver --php-version 8.3
```

**Entwicklung**
```bash
# Mehrere Instanzen parallel
./redaxo create kunde-a --auto
./redaxo create kunde-b --auto
./redaxo start kunde-a kunde-b
./redaxo list

# Backup vor größeren Änderungen
./redaxo backup kunde-a
# → Backup: kunde-a_20250526_143022

# Shell für Debugging/Entwicklung
./redaxo shell kunde-a
# → Direkter Zugriff auf Container-Dateisystem
# → REDAXO Console: php bin/console
# → Composer, Git, etc.

# Bei Problemen: Backup wiederherstellen
./redaxo restore kunde-a kunde-a_20250526_143022

# Versions-Matrix testen
./redaxo create test-php83 --php-version 8.3 --auto
./redaxo create test-php74 --php-version 7.4 --auto
```

## 🔍 Häufige Szenarien

**Neuer Kunde**
```bash
./redaxo create kunde-xyz --auto
# Login: admin/admin123
# URL: wird automatisch angezeigt
```

**Legacy-Migration**  
```bash
./redaxo create legacy-migration --php-version 7.4 --mariadb-version 10.4 --auto
```

**API-Entwicklung**
```bash
./redaxo create api-v1 --type webserver --php-version 8.3
# Pure PHP, kein REDAXO/DB
```

**Backup-Workflow**
```bash
# Vor wichtigen Updates
./redaxo backup produktiv-site
# → Erstellt: produktiv-site_20250526_143022

# Updates durchführen, entwickeln...
./redaxo shell produktiv-site

# Alle Backups anzeigen
./redaxo backups

# Bei Problemen: Backup wiederherstellen
./redaxo restore produktiv-site produktiv-site_20250526_143022
# → Komplett zurückgesetzt auf Backup-Stand
```

**System-Wartung**
```bash
# Docker-System bereinigen (Speicherplatz freigeben)
./redaxo cleanup
# → Entfernt verwaiste Container, Images und Build-Cache
# → REDAXO-Instanzen bleiben unberührt
```

**Vollständiger Backup-Test**
```bash
# Neue Instanz mit Auto-Install
./redaxo create backup-test --auto

# Backup vor Änderungen
./redaxo backup backup-test

# Änderungen vornehmen
./redaxo shell backup-test
# → Dateien ändern, Module installieren, etc.

# Backup wiederherstellen
./redaxo restore backup-test backup-test_20250526_143022
# → Alles wieder wie vorher
```

## 🚨 Troubleshooting

```bash
# Status prüfen
./redaxo list

# Logs ansehen
docker logs redaxo-<name>-apache

# Shell öffnen für Debugging
./redaxo shell <name>

# Neustart
./redaxo stop <name> && ./redaxo start <name>

# Docker-System bereinigen (bei Performance-Problemen)
./redaxo cleanup

# Komplett neu
./redaxo remove <name>
./redaxo create <name> --auto
```

## 📁 Struktur

```
redaxo-multi-instances/
├── redaxo                 # Hauptskript
├── instances/             # Ihre Projekte
│   ├── projekt-a/app/    # REDAXO-Dateien hier
│   └── kunde-b/app/      # REDAXO-Dateien hier
├── backups/              # Automatische Backups
│   ├── projekt-a/        # Backups für projekt-a
│   └── kunde-b/          # Backups für kunde-b
└── ssl/                  # SSL-Zertifikate
```

**Ihre REDAXO-Dateien:** `instances/<name>/app/`  
**Ihre Backups:** `backups/<name>/`

> 💡 **Backup-Sicherheit:** Backups werden automatisch von Git ignoriert (.gitignore), da sie sensible Daten enthalten können.

---

**🎯 Typischer Workflow:**

```bash
# 1. Neue Instanz
./redaxo create mein-projekt --auto

# 2. Entwickeln in: instances/mein-projekt/app/

# 3. Bei Bedarf verwalten
./redaxo stop mein-projekt    # Pausieren
./redaxo start mein-projekt   # Fortsetzen
./redaxo remove mein-projekt  # Löschen
```
