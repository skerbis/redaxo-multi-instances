# MariaDB UTF8MB4 Konfiguration

## Übersicht

Dieses Multi-Instance-Setup ist so konfiguriert, dass MariaDB standardmäßig mit UTF8MB4 und der Kollation `utf8mb4_unicode_ci` arbeitet. Dies gewährleistet vollständige Unicode-Unterstützung inklusive Emojis und anderen 4-Byte-Zeichen.

## Implementierung

### 1. Zentrale Konfiguration

Die MariaDB-Konfiguration befindet sich in:
```
docker-templates/mariadb/my.cnf
```

Diese Datei wird automatisch in alle MariaDB-Container eingebunden und stellt sicher, dass:
- Der Server-Charset auf `utf8mb4` gesetzt ist
- Die Standard-Kollation `utf8mb4_unicode_ci` ist
- Neue Verbindungen automatisch UTF8MB4 verwenden
- Performance-Optimierungen aktiv sind

### 2. Docker Compose Integration

Alle `docker-compose.yml`-Dateien (Template und Instanzen) enthalten das Volume-Mapping:
```yaml
volumes:
  - ../../docker-templates/mariadb/my.cnf:/etc/mysql/my.cnf:ro
```

### 3. Für neue Instanzen

Neue Instanzen, die mit dem Template erstellt werden, erhalten automatisch die UTF8MB4-Konfiguration.

### 4. Für bestehende Instanzen

#### Automatische Migration

Verwenden Sie das bereitgestellte Migrations-Script:
```bash
./mariadb-utf8mb4-migrate.sh
```

Das Script:
- Zeigt alle verfügbaren Instanzen an
- Erstellt automatisch ein Backup
- Konvertiert die Datenbank und alle Tabellen zu UTF8MB4
- Überprüft das Ergebnis

#### Manuelle Migration

Falls Sie die Migration manuell durchführen möchten:

1. **Backup erstellen:**
   ```bash
   docker exec redaxo-INSTANZ-mariadb mysqldump -u root -p DB_NAME > backup.sql
   ```

2. **Datenbank konvertieren:**
   ```sql
   ALTER DATABASE `datenbankname` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;
   ```

3. **Alle Tabellen konvertieren:**
   ```sql
   -- Für jede Tabelle:
   ALTER TABLE `tabellenname` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
   ```

4. **Container neu starten:**
   ```bash
   ./manager INSTANZ restart
   ```

## Überprüfung

### Charset-Einstellungen prüfen

```sql
-- Server-Einstellungen
SHOW VARIABLES LIKE 'character_set_%';
SHOW VARIABLES LIKE 'collation_%';

-- Datenbank-Einstellungen
SELECT 
    DEFAULT_CHARACTER_SET_NAME, 
    DEFAULT_COLLATION_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = 'dein_datenbankname';

-- Tabellen-Einstellungen
SELECT 
    TABLE_NAME, 
    TABLE_COLLATION 
FROM information_schema.TABLES 
WHERE TABLE_SCHEMA = 'dein_datenbankname';
```

### Erwartete Werte

- `character_set_server`: `utf8mb4`
- `collation_server`: `utf8mb4_unicode_ci`
- `character_set_database`: `utf8mb4`
- `collation_database`: `utf8mb4_unicode_ci`

## Vorteile von utf8mb4_unicode_ci

- **Vollständige Unicode-Unterstützung**: Emojis, asiatische Zeichen, mathematische Symbole
- **Bessere Sortierung**: Korrekte alphabetische Sortierung für verschiedene Sprachen
- **REDAXO-Kompatibilität**: Optimale Unterstützung für REDAXO CMS
- **Zukunftssicherheit**: Standard für moderne Web-Anwendungen

## Troubleshooting

### Problem: "Illegal mix of collations"

Wenn nach der Migration Fehler auftreten, prüfen Sie:

1. Ob alle Tabellen konvertiert wurden
2. Ob REDAXO's Charset-Einstellungen korrekt sind
3. Ob die Verbindung UTF8MB4 verwendet

### REDAXO-Konfiguration

Stellen Sie sicher, dass in der REDAXO-Konfiguration (`config.yml`) der korrekte Charset eingestellt ist:

```yaml
database:
    charset: utf8mb4
```

## Wartung

- Die `my.cnf` wird bei Container-Neustarts automatisch geladen
- Neue Datenbanken und Tabellen verwenden automatisch UTF8MB4
- Regelmäßige Überprüfung der Charset-Einstellungen wird empfohlen

## Performance-Hinweise

Die `my.cnf` enthält auch Performance-Optimierungen:
- InnoDB Buffer Pool: 256M
- Query Cache: 16M
- Slow Query Log: Aktiviert (>2 Sekunden)
- Connection Limits: 100 (max), 80 (pro User)

Diese Werte können je nach Serverressourcen angepasst werden.
