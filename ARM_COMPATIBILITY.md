# ARM-Kompatibilität und Verbesserungen

## 🚀 Übersicht der Verbesserungen

Das System wurde für bessere ARM-Kompatibilität (Apple Silicon M1/M2/M3) und allgemeine Stabilität optimiert.

## ✅ Behobene Probleme

### 1. Port-Konfiguration
**Problem:** Hardcodierte Ports in docker-compose.yml Templates
**Lösung:** Verwendung von Umgebungsvariablen aus .env-Datei

**Vorher:**
```yaml
ports:
  - "8180:80"  # Hardcodiert
```

**Nachher:**
```yaml
ports:
  - "${PHPMYADMIN_PORT}:80"  # Dynamisch aus .env
```

### 2. ARM-Kompatibilität

**PHPMyAdmin:**
- **Vorher:** `phpmyadmin/phpmyadmin` (teilweise ARM-Probleme)
- **Nachher:** `phpmyadmin:latest` (offizielle ARM-Unterstützung)

**MailHog:**
- **Standard:** `mailhog/mailhog:latest` (läuft mit Rosetta 2)
- **Alternative:** `axllent/mailpit:latest` (native ARM64-Unterstützung)

## 🔧 Anwendung der Fixes

### Für bestehende Instanzen:
```bash
./fix-docker-config.sh
```

### Für neue Instanzen:
Die Verbesserungen sind automatisch im `./redaxo create` Befehl enthalten.

## 🆚 Vergleich: MailHog vs MailPit

| Feature | MailHog | MailPit |
|---------|---------|---------|
| ARM64 Support | ❌ (Rosetta 2) | ✅ Native |
| Web UI | ✅ | ✅ Moderner |
| SMTP Server | ✅ | ✅ |
| Performance | 🟡 | 🟢 Besser |
| Wartung | ❌ Veraltet | ✅ Aktiv |

## 📋 Migration zu MailPit (optional)

Wenn Sie die moderne MailPit-Alternative verwenden möchten:

1. **Template anpassen:**
```yaml
# Anstatt:
mailhog:
  image: mailhog/mailhog:latest

# Verwenden:
mailpit:
  image: axllent/mailpit:latest
  ports:
    - "${MAILHOG_PORT}:8025"  # Web UI
    - "1025:1025"            # SMTP
```

2. **PHP-Konfiguration:**
```php
// SMTP-Einstellungen für REDAXO
$config['phpmailer']['host'] = 'mailpit';  // statt 'mailhog'
$config['phpmailer']['port'] = 1025;
```

## 🎯 Empfohlene Konfiguration

Für optimale ARM-Kompatibilität und Performance:

```yaml
version: '3.8'
services:
  phpmyadmin:
    image: phpmyadmin:latest
    # ...
  
  mailpit:  # Moderne Alternative zu MailHog
    image: axllent/mailpit:latest
    # ...
```

## 🔍 Troubleshooting

### MailHog startet nicht:
```bash
# Container-Logs prüfen
docker logs redaxo-[instance]-mailhog

# Neu starten
./redaxo stop [instance]
./redaxo start [instance]
```

### PHPMyAdmin-Verbindungsfehler:
```bash
# Datenbank-Container prüfen
docker logs redaxo-[instance]-mariadb

# .env-Datei prüfen
cat instances/[instance]/.env
```

### Port-Konflikte:
```bash
# Verwendete Ports anzeigen
./redaxo list

# Freie Ports finden
lsof -i :8180  # Port-Nutzung prüfen
```
