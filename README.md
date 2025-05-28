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

---

## 🎨 Penpot Design Tool Integration

**Penpot** ist ein **Open-Source Design & Prototyping Tool**, das als Alternative zu Figma, Sketch oder Adobe XD dient. Es ist vollständig in das REDAXO Multi-Instance System integriert und läuft lokal auf Ihrem Mac.

### 🚀 Warum Penpot?

- **🆓 100% Open Source** - Keine Lizenzkosten, keine Cloud-Abhängigkeit
- **🔒 Datenschutz** - Ihre Designs bleiben lokal auf Ihrem System
- **🌐 Web-basiert** - Läuft im Browser, kein App-Download nötig
- **👥 Kollaboration** - Team-Features für gemeinsames Arbeiten
- **📱 Responsive Design** - Perfekt für moderne Web-Entwicklung
- **🎯 Integration** - Nahtlos mit REDAXO-Projekten kombinierbar
- **⚡ Performance** - Läuft lokal ohne Cloud-Latenz
- **💾 Backup-System** - Vollständige Datensicherung wie bei REDAXO

### 🎯 Penpot Features

- **Vector Design** - Professionelle Designwerkzeuge
- **Prototyping** - Interaktive Prototypen erstellen
- **Design Systems** - Komponenten und Style Guides
- **Collaboration** - Echtzeit-Zusammenarbeit im Team
- **Developer Handoff** - CSS-Code-Export für Entwickler
- **Version Control** - Versionierung von Designs
- **Multi-Format Export** - SVG, PNG, JPG Export
- **Typography** - Erweiterte Text- und Font-Features

### ⚡ Quick Start Penpot

```bash
# 1. SSL-Setup (falls noch nicht gemacht)
./penpot ssl-setup

# 2. Penpot-Instanz erstellen
./penpot create design-team

# 3. Penpot starten
./penpot start design-team

# ✅ Fertig: https://localhost:9450 (HTTPS)
#          http://localhost:9090 (HTTP)
```

**🔑 Erster Login (ohne E-Mail-Bestätigung):**
- Registrieren Sie sich direkt über die Penpot-Oberfläche
- **Keine E-Mail-Bestätigung erforderlich** - Sofort einsatzbereit
- E-Mail-Verifikation ist für lokale Entwicklung deaktiviert

### 📚 Penpot Befehle

```bash
# Instanz-Management
./penpot create <name>                    # Neue Penpot-Instanz erstellen
./penpot create <name> --port 9100        # Mit spezifischem Port
./penpot start|stop|remove <name>         # Lebenszyklus
./penpot remove all                       # Alle Penpot-Instanzen löschen
./penpot list                             # Alle Instanzen anzeigen
./penpot urls <name>                      # URLs anzeigen

# Entwicklung & Debugging
./penpot shell <name>                     # Shell in Container öffnen
./penpot logs <name>                      # Container-Logs anzeigen

# Backup & Restore
./penpot backup <name>                    # Vollständiges Backup
./penpot restore <name> <backup>          # Backup wiederherstellen
./penpot backups                          # Alle Backups anzeigen

# System-Wartung
./penpot repair <name>                    # Docker-Probleme beheben
./penpot cleanup                          # Docker-System bereinigen
./penpot ssl-setup                        # SSL-Zertifikate einrichten
```

### 🔧 Penpot Beispiele

**Standard-Setup (empfohlen)**
```bash
./penpot create haupt-design
./penpot start haupt-design
# → https://localhost:9450 (HTTPS mit SSL)
# → http://localhost:9090 (HTTP)
```

**Mehrere Design-Teams**
```bash
# Design-Team A
./penpot create team-a --port 9100
# → https://localhost:9500 (HTTPS)
# → http://localhost:9100 (HTTP)

# Design-Team B  
./penpot create team-b --port 9200
# → https://localhost:9600 (HTTPS)
# → http://localhost:9200 (HTTP)

# Kunde-spezifische Designs
./penpot create kunde-xyz --port 9300
# → https://localhost:9700 (HTTPS)
# → http://localhost:9300 (HTTP)

# Alle parallel nutzen
./penpot list
```

**Backup-Workflow für Designs**
```bash
# Vor wichtigen Design-Änderungen
./penpot backup design-projekt

# Design-Arbeiten durchführen...
# Browser: https://localhost:9450

# Alle Backups anzeigen
./penpot backups

# Bei Fehlern: Backup wiederherstellen
./penpot restore design-projekt design-projekt_20250526_143022
```

### 🎨 Design-Workflow mit REDAXO

**Kompletter Design-zu-Code Workflow:**

```bash
# 1. REDAXO-Instanz für Entwicklung
./redaxo create kunde-website --auto

# 2. Penpot-Instanz für Design
./penpot create kunde-design

# 3. Beide starten
./redaxo start kunde-website
./penpot start kunde-design

# 4. Arbeiten
# Design: https://localhost:9450 (Penpot)
# Code:   http://localhost:8080 (REDAXO)

# 5. Backups vor wichtigen Meilensteinen
./redaxo backup kunde-website
./penpot backup kunde-design
```

**Team-Kollaboration:**
```bash
# Designer
./penpot create projekt-design
./penpot start projekt-design
# → Designs in Penpot erstellen: https://localhost:9450

# Entwickler (parallel)
./redaxo create projekt-code --auto  
./redaxo start projekt-code
# → REDAXO entwickeln: http://localhost:8080

# Code aus Penpot exportieren
# → CSS/SVG direkt in REDAXO übernehmen
```

### 🚨 Penpot Troubleshooting

**E-Mail-Bestätigung Problem (gelöst):**
```bash
# Problem: Penpot forderte E-Mail-Bestätigung bei Registrierung
# ✅ LÖSUNG: Automatisch deaktiviert in allen Instanzen

# E-Mail-Bestätigung ist standardmäßig deaktiviert
# Registrierung funktioniert ohne E-Mail-Verifikation
# Sofortige Nutzung nach Account-Erstellung
```

**Container startet nicht:**
```bash
# Status prüfen
./penpot list

# Logs ansehen
./penpot logs <name>

# Docker-Probleme beheben
./penpot repair <name>

# Neustart
./penpot stop <name> && ./penpot start <name>
```

**Port-Konflikte:**
```bash
# Andere Ports verwenden
./penpot create design-alt --port 9500

# Verwendete Ports prüfen
lsof -i :9090  # HTTP
lsof -i :9450  # HTTPS
```

**Performance-Probleme:**
```bash
# Docker-System bereinigen
./penpot cleanup

# Container-Ressourcen prüfen
docker stats
```

### 💡 Design-Integration Tipps

**CSS aus Penpot zu REDAXO:**
1. Design in Penpot erstellen
2. CSS-Code exportieren 
3. Direkt in REDAXO-Theme einbauen
4. Assets (SVG/PNG) in REDAXO-Assets kopieren

**Asset-Management:**
```bash
# Penpot-Container für Asset-Export
./penpot shell design-projekt
# → SVG/PNG-Dateien direkt zugänglich

# REDAXO-Container für Asset-Import
./redaxo shell web-projekt  
# → Assets in /var/www/html/assets/ kopieren
```

**Backup-Strategie:**
```bash
# Vor jedem Design-Meilenstein
./penpot backup design-projekt

# Vor jedem Code-Deployment
./redaxo backup web-projekt

# → Komplette Projekt-Historie
```

---