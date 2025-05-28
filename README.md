# 🚀 REDAXO Multi-Instance Manager

> Automatisierte REDAXO-Instanzen für macOS-Entwickler - MAMP war gestern

**Ein Befehl → Komplette REDAXO-Installation mit beliebigen PHP/MariaDB-Versionen**

## 📋 Systemvoraussetzungen

**Minimal:**
- **macOS** 10.15+ (Catalina oder neuer)
- **Docker Desktop** 4.0+ ([Download](https://www.docker.com/products/docker-desktop/))
- **Homebrew** ([Installation](https://brew.sh/))
- **8 GB RAM** (empfohlen: 16 GB)
- **10 GB freier Speicher** für Docker Images

**Installation:**
```bash
# Docker Desktop installieren (GUI-Installation)
# Dann Homebrew-Tools:
brew install mkcert git
```

## 🆚 Warum besser als MAMP?

| Feature | MAMP Pro | REDAXO Multi-Instance |
|---------|----------|----------------------|
| **Kosten** | 💰 $99/Jahr | 🆓 Kostenlos / Sponsoring welcome |
| **PHP-Versionen** | ⚠️ Begrenzt | ✅ Alle verfügbaren |
| **Parallele Instanzen** | ⚠️ Komplex | ✅ Einfach: `./redaxo create` |
| **Isolation** | ❌ Shared Environment | ✅ Container-Isolation |
| **Version-Conflicts** | ❌ Häufig | ✅ Unmöglich |
| **REDAXO Auto-Install** | ❌ Manual | ✅ `--auto` Flag |
| **SSL/HTTPS** | ⚠️ Basic | ✅ mkcert Integration |
| **Backup-System** | ❌ Fehlt | ✅ Ein-Klick Backup/Restore |
| **Performance** | ⚠️ Overhead | ✅ Optimiert |
| **Portabilität** | ❌ macOS only | ✅ Docker überall |

**Konkrete Vorteile:**
- **🚀 Schneller**: REDAXO in 30 Sekunden statt 10 Minuten Setup
- **🔧 Flexibler**: PHP 7.4 + 8.4 parallel ohne Konflikte  
- **💡 Entwicklerfreundlich**: Shell-Zugriff, Composer, Git direkt verfügbar
- **🔒 Sicherer**: Komplette Isolation zwischen Projekten
- **💾 Backup-Ready**: Automatische Datensicherung mit einem Befehl
- **🛠️ Selbstheilend**: Automatische Docker-Reparatur bei Problemen
- **🧹 Wartungsarm**: Intelligente Bereinigung verwaister Dateien
- **🗑️ Massenoperationen**: Alle Instanzen mit einem Befehl verwalten

## ⚡ Quick Start

```bash
# 1. Voraussetzungen installieren
# Docker Desktop: https://www.docker.com/products/docker-desktop/
brew install mkcert git

# 2. Projekt einrichten
git clone <repo-url> redaxo-multi-instances && cd redaxo-multi-instances
chmod +x redaxo
./redaxo ssl-setup

# 3. Erste REDAXO-Instanz (automatisch)
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
- **🏗️ Container-Isolation** - Jede Instanz komplett isoliert
- **⚡ Performance** - Optimierte Docker-Container
- **📁 Flexible Strukturen** - Modern Structure oder klassisches REDAXO
- **🔧 Repair-System** - Automatische Docker-Problemlösung
- **🧹 Smart-Cleanup** - Intelligente Bereinigung verwaister Dateien
- **🗑️ Bulk-Remove** - Alle Instanzen mit einem Befehl löschen

## 📚 Befehle

```bash
# Instanz erstellen
./redaxo create <name>                    # Manuelles Setup
./redaxo create <name> --auto             # Automatisches Setup
./redaxo create <name> --php-version 8.3  # Spezifische PHP-Version
./redaxo create <name> --repo redaxo/redaxo --auto  # Klassische REDAXO-Struktur

# Verwaltung
./redaxo start|stop|remove <name>         # Lebenszyklus
./redaxo remove all                       # Alle Instanzen löschen
./redaxo list                             # Übersicht
./redaxo urls <name>                      # URLs anzeigen
./redaxo shell <name>                     # Shell in Container

# Backup & Restore
./redaxo backup <name>                    # Backup erstellen
./redaxo restore <name> <backup>          # Backup wiederherstellen
./redaxo backups                          # Alle Backups anzeigen

# System-Wartung & Reparatur
./redaxo cleanup                          # Erweiterte Docker-Bereinigung
./redaxo repair <name>                    # Docker-Probleme beheben

# Versionen ändern
./redaxo update <name> --php-version 8.3  # PHP updaten
```

## 📁 REDAXO-Strukturen

**Standard (empfohlen):** Modern Structure
- **Repository:** `skerbis/REDAXO_MODERN_STRUCTURE` (Standard)
- **Vorteile:** Optimierte Ordnerstruktur, bessere Entwicklung
- **Verwendung:** `./redaxo create projekt --auto`

**Klassisch:** Original REDAXO
- **Repository:** `redaxo/redaxo`
- **Vorteile:** Gewohnte Struktur, kompatibel mit älteren Tutorials
- **Verwendung:** `./redaxo create projekt --repo redaxo/redaxo --auto`

```bash
# Modern Structure (Standard)
./redaxo create modern-projekt --auto

# Klassische Struktur
./redaxo create klassisch-projekt --repo redaxo/redaxo --auto
```

## 🔧 Beispiele

**Automatisches Setup (empfohlen)**
```bash
./redaxo create projekt --auto
# → Sofort einsatzbereit: http://localhost:8080/redaxo/
```

**Verschiedene Versionen**
```bash
# Legacy-Projekt (PHP 7.4 + MariaDB 10.4)
./redaxo create alt --php-version 7.4 --mariadb-version 10.4 --auto

# Modern (PHP 8.4 + MariaDB 11.0)
./redaxo create neu --php-version 8.4 --mariadb-version 11.0 --auto

# Klassische REDAXO-Struktur (statt Modern Structure)
./redaxo create klassisch --repo redaxo/redaxo --auto

# API-Server (ohne Datenbank)
./redaxo create api --type webserver --php-version 8.3

# 🎯 Alle laufen parallel - kein MAMP-Chaos!
./redaxo list
```

**MAMP vs. Multi-Instance Vergleich**
```bash
# ❌ MAMP: Umständlich, teuer, limitiert
# 1. MAMP Pro kaufen ($99)
# 2. PHP-Version global ändern
# 3. Apache/MySQL neu starten
# 4. Hoffen dass andere Projekte noch funktionieren
# 5. SSL manuell konfigurieren
# 6. Backup? Selber lösen...

# ✅ Multi-Instance: Ein Befehl, fertig
./redaxo create projekt-xyz --auto
# → 30 Sekunden, komplett isoliert, SSL ready
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

**Klassische REDAXO-Struktur**
```bash
./redaxo create projekt-klassisch --repo redaxo/redaxo --auto
# → Verwendet die Standard REDAXO-Struktur statt Modern Structure
# → Ideal für bestehende Projekte oder wenn Sie die gewohnte Struktur bevorzugen
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

**System-Wartung & Problemlösung**
```bash
# Erweiterte Docker-Bereinigung (Speicherplatz freigeben)
./redaxo cleanup
# → Entfernt verwaiste Container, Images und Build-Cache
# → Sucht und entfernt verwaiste SSL-Zertifikate
# → Findet verwaiste Backup-Ordner (zeigt Warnung)
# → REDAXO-Instanzen bleiben unberührt

# Docker-Probleme einer Instanz beheben
./redaxo repair mein-projekt
# → Stoppt Container und entfernt Probleme
# → Baut Container ohne Cache neu auf
# → Startet Instanz sauber neu
# → Löst 90% aller Docker-Probleme

# Alle Instanzen komplett löschen
./redaxo remove all
# → Sicherheitsabfrage: "DELETE ALL" eingeben
# → Löscht alle Instanzen, SSL-Zertifikate, Backups
# → Docker-Ressourcen werden bereinigt
```

**Notfall-Szenarien**
```bash
# Container startet nicht richtig
./redaxo repair problematische-instanz

# Docker läuft langsam / Speicherplatz knapp
./redaxo cleanup

# Kompletter Neustart aller Projekte
./redaxo remove all
./redaxo create projekt-1 --auto
./redaxo create projekt-2 --auto
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

### ⚠️ "Starte 'instanz'..." hängt ohne Fortschritt

**Problem:** Der `create` Befehl bleibt beim Starten hängen
```bash
./redaxo create mein-projekt --auto
# Zeigt: "Starte 'mein-projekt'..." ohne weiteren Fortschritt
```

**Lösung:**
```bash
# 1. Container-Status prüfen
docker ps -a | grep mein-projekt

# 2. Wenn Container im Status "Created": Manuell starten
./redaxo start mein-projekt

# 3. Status überprüfen
./redaxo list
```

**Ursachen:**
- Docker-Performance-Issues (Container brauchen länger zum Starten)
- Port-Konflikte mit anderen Anwendungen
- Zu wenig RAM/CPU für Docker
- Docker-Netzwerk-Probleme

### 🔧 Allgemeine Problembehebung

```bash
# Status prüfen
./redaxo list

# Logs ansehen
docker logs redaxo-<name>-apache

# Shell öffnen für Debugging
./redaxo shell <name>

# Docker-Probleme automatisch beheben
./redaxo repair <name>

# Neustart (nach repair meist nicht nötig)
./redaxo stop <name> && ./redaxo start <name>

# Docker-System bereinigen (bei Performance-Problemen)
./redaxo cleanup

# Komplett neu (wenn alles andere fehlschlägt)
./redaxo remove <name>
./redaxo create <name> --auto
```

### 🚑 Neue Notfall-Tools

**Docker-Probleme einer Instanz:**
```bash
./redaxo repair mein-projekt
# → Löst 90% aller Container-Probleme automatisch
# → Neuaufbau ohne Cache
# → Entfernt verwaiste Volumes/Netzwerke
```

**System-Performance-Probleme:**
```bash
./redaxo cleanup
# → Erweiterte Bereinigung mit Orphaned-Files-Suche
# → Entfernt verwaiste SSL-Zertifikate automatisch
# → Zeigt verwaiste Backup-Ordner an
```

**Alles zurücksetzen:**
```bash
./redaxo remove all
# → Sicherheitsabfrage verhindert Versehen
# → Löscht alle Instanzen + Docker-Ressourcen
```

### 🚑 Notfall-Diagnose

```bash
# Docker-Status prüfen
docker ps -a

# Container-Logs ansehen
docker logs redaxo-<name>-apache
docker logs redaxo-<name>-mariadb

# Port-Konflikte prüfen
lsof -i :8080  # HTTP-Port
lsof -i :8180  # phpMyAdmin-Port
lsof -i :8120  # Mailpit-Port

# Docker-Ressourcen prüfen
docker system df
docker system prune  # Vorsicht: Löscht verwaiste Container/Images
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

---

## 📋 Changelog

### 🆕 Version 2025.05.27 - Mailpit Migration
- **✨ Mailhog → Mailpit**: Modernisierung des E-Mail-Test-Tools
  - **Bessere Performance**: Schnellere und effizientere Implementierung
  - **ARM64 Support**: Optimiert für Apple Silicon (M1/M2/M3)
  - **Erweiterte Features**: Verbesserte Web-UI und Suchfunktionen
  - **Aktive Entwicklung**: Mailpit wird aktiv maintained (Mailhog ist deprecated)
  - **Bessere SMTP-Kompatibilität**: Erweiterte SMTP-Funktionen für komplexere Tests
  
- **🔧 Technische Verbesserungen**:
  - Container-Name: `mailhog` → `mailpit`
  - Docker Image: `mailhog/mailhog:latest` → `axllent/mailpit:latest`
  - Zusätzlicher SMTP-Port 1025 für direkte SMTP-Tests
  - Erweiterte Umgebungsvariablen für bessere SMTP-Kompatibilität

- **📦 Automatische Migration**: Bestehende Instanzen werden automatisch aktualisiert

---

## 🤝 Support & Community

☕ **[💰 Sponsor werden](https://github.com/sponsors/skerbis)** - ab $2/Monat  
🐛 **[🐞 Issues melden](https://github.com/skerbis/redaxo-multi-instances/issues)**  
🔧 **[🤝 Pull Requests](https://github.com/skerbis/redaxo-multi-instances/pulls)**

> 💡 **Warum sponsern?** Alle Tools sind MIT-lizenziert und kostenlos. Mit Ihrem Support ermöglichen Sie weitere Entwicklung und coole neue Features für die REDAXO-Community!


*Made with ❤️ in Moers, Germany*

by: Thomas Skerbis