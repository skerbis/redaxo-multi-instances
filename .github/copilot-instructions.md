# PLESK Integration - Anleitung für REDAXO Multi-Instances

## Übersicht
Diese Anleitung beschreibt die Integration eines Plesk-Servers zur automatischen Erstellung von Kunden, Domains und Migration von REDAXO-Instanzen vom lokalen Docker-Setup auf den Live-Server.

## Ziele
- Automatische Kunden- und Domain-Erstellung auf Plesk-Server
- Migration von lokalen REDAXO-Instanzen auf Plesk
- Nahtlose Integration in das bestehende Multi-Instances-System
- Deployment-Pipeline für Live-Server

## Technische Voraussetzungen

### Plesk-Server
- Plesk Panel mit API-Zugang
- PHP 8.1+ verfügbar
- MySQL/MariaDB-Datenbank
- SSH/SFTP-Zugang
- SSL-Zertifikat-Management

### Lokales System
- Bestehende Docker-Umgebung
- API-Credentials für Plesk
- Netzwerk-Zugang zum Plesk-Server

## Plesk API Authentifizierung

### API-Key Setup
```bash
# Plesk API-Key generieren (im Plesk Panel)
# Tools & Settings > API Keys > Create API Key
```

### Erforderliche API-Permissions
- Server administration
- Create and manage customer accounts
- Create and manage domains
- Manage hosting settings
- Database management

## Geplante Implementierung

### 1. Konfigurationsdatei
```
config/plesk-config.yml
├── server:
│   ├── host: "your-plesk-server.com"
│   ├── api_key: "your-api-key"
│   └── api_version: "1.6.9.0"
├── defaults:
│   ├── hosting_plan: "default-plan"
│   ├── php_version: "8.1"
│   └── ssl_enabled: true
└── migration:
    ├── backup_path: "./backups/plesk-migrations"
    └── temp_path: "./tmp/plesk-staging"
```

### 2. Scripts Struktur
```
scripts/plesk/
├── plesk-api-client.php          # Plesk API Wrapper
├── plesk-customer-manager.php    # Kunden-Management
├── plesk-domain-manager.php      # Domain-Management
├── plesk-migration-manager.php   # Migrations-Pipeline
├── plesk-deploy.sh               # Haupt-Deployment-Script
└── helpers/
    ├── database-migrator.php     # DB-Export/Import
    ├── file-sync.php             # Datei-Synchronisation
    └── config-updater.php        # REDAXO-Config-Anpassung
```

### 3. Migration Pipeline

#### Phase 1: Vorbereitung
1. Lokale REDAXO-Instanz validieren
2. Datenbank-Backup erstellen
3. Datei-Backup erstellen
4. Konfiguration für Live-Server anpassen

#### Phase 2: Plesk Setup
1. Kunden-Account erstellen (falls nicht vorhanden)
2. Domain hinzufügen
3. Hosting-Plan zuweisen
4. Datenbank erstellen
5. SSL-Zertifikat einrichten

#### Phase 3: Migration
1. Dateien auf Plesk-Server uploaden
2. Datenbank importieren
3. REDAXO-Konfiguration anpassen
4. Pfade und URLs aktualisieren
5. Cache leeren

#### Phase 4: Validierung
1. Website-Erreichbarkeit prüfen
2. Datenbank-Verbindung testen
3. REDAXO-Backend testen
4. SSL-Zertifikat validieren

## Kommandozeilen-Interface

### Geplante Befehle
```bash
# Neuen Kunden erstellen
./scripts/plesk/plesk-deploy.sh create-customer --name "customer-name" --email "email@domain.com"

# Domain hinzufügen
./scripts/plesk/plesk-deploy.sh create-domain --customer "customer-name" --domain "example.com"

# Instanz migrieren
./scripts/plesk/plesk-deploy.sh migrate-instance --instance "main_dev" --domain "example.com"

# Vollständige Migration (Kunde + Domain + Migration)
./scripts/plesk/plesk-deploy.sh full-deploy --instance "main_dev" --customer "new-customer" --domain "example.com"

# Status prüfen
./scripts/plesk/plesk-deploy.sh status --domain "example.com"
```

## Sicherheitsaspekte

### API-Key Management
- API-Keys in separater Config-Datei (nicht versioniert)
- Umgebungsvariablen für sensitive Daten
- Regelmäßige API-Key-Rotation

### Backup-Strategie
- Automatische Backups vor Migration
- Rollback-Möglichkeit implementieren
- Backup-Retention-Policy definieren

### Zugriffskontrolle
- SSH-Key-basierte Authentifizierung
- IP-Whitelist für API-Zugriffe
- Logging aller API-Operationen

## Konfiguration der Docker-Instanzen

### Anpassungen für Live-Migration
```yaml
# Erweiterte docker-compose.yml für Migration-Support
services:
  web:
    # ...existing config...
    volumes:
      - ./migration:/migration  # Migrations-Verzeichnis
    environment:
      - MIGRATION_MODE=false
      - PLESK_TARGET_DOMAIN=${PLESK_TARGET_DOMAIN}
```

## Monitoring und Logging

### Log-Dateien
```
logs/plesk/
├── api-calls.log          # Alle API-Aufrufe
├── migrations.log         # Migrations-Protokoll
├── errors.log            # Fehler-Log
└── deployments.log       # Deployment-Historie
```

### Monitoring-Checks
- Plesk-Server Erreichbarkeit
- API-Rate-Limits
- SSL-Zertifikat-Gültigkeit
- Deployment-Status

## Fehlerbehandlung

### Häufige Probleme
1. **API-Rate-Limiting**: Retry-Mechanismus implementieren
2. **Netzwerk-Timeouts**: Verbindungs-Pooling verwenden
3. **Datenbank-Migration**: Chunked-Import für große DBs
4. **Datei-Upload**: Resume-fähige Uploads
5. **SSL-Probleme**: Automatische Let's Encrypt Integration

### Rollback-Strategie
1. Automatisches Backup vor jeder Migration
2. Rollback-Scripts für kritische Änderungen
3. Notfall-Kontakte und Procedures

## Testing

### Test-Umgebung
- Plesk-Test-Server für Entwicklung
- Automatisierte Tests für API-Calls
- Integration-Tests für Migration-Pipeline

### Test-Cases
1. Kunden-Erstellung
2. Domain-Setup
3. Vollständige Migration
4. Rollback-Szenarios
5. Fehlerbehandlung

## Roadmap

### Phase 1 (Grundlagen)
- [ ] Plesk API-Client implementieren
- [ ] Grundlegende Kunden-/Domain-Verwaltung
- [ ] Einfache Migration-Pipeline

### Phase 2 (Automation)
- [ ] CLI-Interface entwickeln
- [ ] Automatische Backups
- [ ] SSL-Integration

### Phase 3 (Enterprise)
- [ ] Web-Interface für Migration
- [ ] Monitoring-Dashboard
- [ ] Advanced Deployment-Strategien

## Ressourcen

### Plesk API Dokumentation
- REST API: https://docs.plesk.com/en-US/obsidian/api-rpc/
- XML API: https://docs.plesk.com/en-US/obsidian/api-rpc/about-xml-api/

### REDAXO Dokumentation
- Migration: https://redaxo.org/doku/main/migration
- Konfiguration: https://redaxo.org/doku/main/konfiguration

## Support und Wartung

### Regelmäßige Aufgaben
- API-Key-Updates
- Backup-Cleanup
- Log-Rotation
- Performance-Optimierung

### Troubleshooting
- Debug-Modi für detaillierte Logs
- Health-Check-Commands
- Monitoring-Alerts

---

**Nächste Schritte:**
1. Plesk API-Credentials einrichten
2. Test-Umgebung vorbereiten
3. Grundlegende API-Client-Implementierung
4. Erste Migration-Tests

**Geschätzte Entwicklungszeit:** 2-3 Wochen für MVP
**Wartungsaufwand:** ~2-4 Stunden/Monat
