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
| **Kosten** | 💰 $99/Jahr | 🆓 Kostenlos |
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

## 📚 Befehle

```bash
# Instanz erstellen
./redaxo create <name>                    # Manuelles Setup
./redaxo create <name> --auto             # Automatisches Setup
./redaxo create <name> --php-version 8.3  # Spezifische PHP-Version
./redaxo create <name> --repo redaxo/redaxo --auto  # Klassische REDAXO-Struktur

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

---

## 👨‍💻 Credits & Support

**Entwickelt von [Thomas Skerbis](https://github.com/skerbis)**
- 🏢 Geschäftsführer der **[KLXM Crossmedia GmbH](https://klxm.de)**
- 🚀 REDAXP-Entwickler  **[REDAXO CMS](https://redaxo.org)** seit 2007
- 📚 Haupt-Contributor der **[REDAXO Dokumentation](https://github.com/redaxo/docs)**
- 🎯 Ersteller von 50+ **[REDAXO AddOns](https://github.com/FriendsOfREDAXO)**

### 💖 Unterstützen

**Wenn dieses Tool Ihnen Zeit spart und Ihr Entwicklerleben vereinfacht:**

🌟 **[⭐ Star auf GitHub](https://github.com/skerbis/redaxo-multi-instances)**  
☕ **[💰 Sponsor werden](https://github.com/sponsors/skerbis)** - ab $2/Monat  
🐛 **[🐞 Issues melden](https://github.com/skerbis/redaxo-multi-instances/issues)**  
🔧 **[🤝 Pull Requests](https://github.com/skerbis/redaxo-multi-instances/pulls)**

> 💡 **Warum sponsern?** Alle Tools sind MIT-lizenziert und kostenlos. Mit Ihrem Support ermöglichen Sie weitere Entwicklung und coole neue Features für die REDAXO-Community!


*Made with ❤️ in Moers, Germany*
