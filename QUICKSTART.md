# Schnellstart-Anleitung für REDAXO Multi-Instance Manager

## 🚀 Erste Schritte

### 1. System-Status prüfen
```bash
./redaxo help
./scripts/monitor.sh status
```

### 2. Erste Instanz erstellen
```bash
# Einfache Erstellung
./redaxo create meine-erste-instanz

# Mit benutzerdefinierten Einstellungen
./redaxo create development --domain dev.local --http-port 8080 --https-port 8443
```

### 3. Instanz starten
```bash
./redaxo start meine-erste-instanz
```

### 4. Demo-Instanz für Tests
```bash
./scripts/demo.sh
```

## 📝 Wichtige Befehle

### Instanz-Management
- `./redaxo create <name>` - Neue Instanz erstellen
- `./redaxo start <name>` - Instanz starten
- `./redaxo stop <name>` - Instanz stoppen
- `./redaxo list` - Alle Instanzen auflisten
- `./redaxo status` - System-Status anzeigen

### Backup & Restore
- `./redaxo backup <name>` - Backup erstellen
- `./redaxo restore <name> <file>` - Backup wiederherstellen
- `./redaxo backups` - Alle Backups auflisten

### Tools
- `./redaxo logs <name>` - Logs anzeigen
- `./redaxo shell <name>` - Shell in Container öffnen
- `./redaxo ssl <name>` - SSL-Zertifikat erneuern

## 🔧 Konfiguration

### Standard-Ports
- HTTP: ab 8080
- HTTPS: ab 8443
- phpMyAdmin: ab 8180
- MailHog: ab 8280

### Verzeichnisstruktur
```
instances/
├── instanz1/
│   ├── app/              # REDAXO-Dateien
│   ├── .env              # Instanz-Konfiguration
│   └── docker-compose.yml
ssl/
├── instanz1/
│   ├── cert.crt          # SSL-Zertifikat
│   └── private.key       # Private Key
backups/                  # Backup-Dateien
```

## 🔒 HTTPS-Setup

1. SSL wird automatisch aktiviert (deaktivierbar mit `--no-ssl`)
2. Selbstsignierte Zertifikate für Entwicklung
3. Browser-Warnung beim ersten Zugriff normal
4. Zertifikate gültig für 365 Tage

## 📊 Monitoring

```bash
# Einmaliger Status
./scripts/monitor.sh status

# Kontinuierliche Überwachung
./scripts/monitor.sh watch
```

## 🔄 Updates

```bash
# System-Update
./redaxo update system

# Docker-Images aktualisieren
./redaxo update docker <instanz>

# Alle Updates
./redaxo update all-instances
```

## 🐛 Troubleshooting

### Port bereits belegt
```bash
./redaxo create instanz --http-port 8090
```

### Container startet nicht
```bash
./redaxo logs instanz
./redaxo status instanz
```

### SSL-Probleme
```bash
./redaxo ssl instanz
```

## 📞 Support

- README.md für vollständige Dokumentation
- `./redaxo help` für Befehlsübersicht
- Logs in `logs/` Verzeichnis
