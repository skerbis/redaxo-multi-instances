#!/usr/bin/env bash

# MariaDB UTF8MB4 Migration Script
# Konvertiert bestehende Datenbanken zu utf8mb4_unicode_ci

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/lib/output.sh"

print_header "MariaDB UTF8MB4 Migration"

# Verfügbare Instanzen finden
INSTANCES_DIR="${SCRIPT_DIR}/instances"
if [[ ! -d "$INSTANCES_DIR" ]]; then
    print_error "Instances-Verzeichnis nicht gefunden: $INSTANCES_DIR"
    exit 1
fi

AVAILABLE_INSTANCES=($(find "$INSTANCES_DIR" -maxdepth 1 -type d -not -name ".*" -not -path "$INSTANCES_DIR" | xargs -I {} basename {}))

if [[ ${#AVAILABLE_INSTANCES[@]} -eq 0 ]]; then
    print_error "Keine Instanzen gefunden!"
    exit 1
fi

echo "Verfügbare Instanzen:"
for i in "${!AVAILABLE_INSTANCES[@]}"; do
    echo "  $((i+1)). ${AVAILABLE_INSTANCES[i]}"
done

echo
read -p "Welche Instanz möchten Sie migrieren? (Nummer oder Name): " INSTANCE_INPUT

# Instance Selection
if [[ "$INSTANCE_INPUT" =~ ^[0-9]+$ ]]; then
    INDEX=$((INSTANCE_INPUT - 1))
    if [[ $INDEX -ge 0 && $INDEX -lt ${#AVAILABLE_INSTANCES[@]} ]]; then
        INSTANCE_NAME="${AVAILABLE_INSTANCES[$INDEX]}"
    else
        print_error "Ungültige Auswahl!"
        exit 1
    fi
else
    INSTANCE_NAME="$INSTANCE_INPUT"
fi

INSTANCE_DIR="${INSTANCES_DIR}/${INSTANCE_NAME}"

if [[ ! -d "$INSTANCE_DIR" ]]; then
    print_error "Instanz '$INSTANCE_NAME' nicht gefunden!"
    exit 1
fi

print_info "Migriere Instanz: $INSTANCE_NAME"

# Check if instance is running
if ! docker ps | grep -q "redaxo-${INSTANCE_NAME}-mariadb\|webserver-${INSTANCE_NAME}-mariadb"; then
    print_error "MariaDB-Container für Instanz '$INSTANCE_NAME' läuft nicht!"
    print_info "Starten Sie die Instanz zuerst mit: ./manager $INSTANCE_NAME start"
    exit 1
fi

# Determine container name pattern
CONTAINER_NAME=""
if docker ps | grep -q "redaxo-${INSTANCE_NAME}-mariadb"; then
    CONTAINER_NAME="redaxo-${INSTANCE_NAME}-mariadb"
elif docker ps | grep -q "webserver-${INSTANCE_NAME}-mariadb"; then
    CONTAINER_NAME="webserver-${INSTANCE_NAME}-mariadb"
else
    print_error "MariaDB-Container für Instanz '$INSTANCE_NAME' nicht gefunden!"
    exit 1
fi

print_info "Container gefunden: $CONTAINER_NAME"

# Load environment variables
ENV_FILE="${INSTANCE_DIR}/.env"
if [[ -f "$ENV_FILE" ]]; then
    source "$ENV_FILE"
else
    print_error ".env-Datei nicht gefunden: $ENV_FILE"
    exit 1
fi

# Migration SQL
MIGRATION_SQL="
-- Datenbank-Charset ändern
ALTER DATABASE \`${MYSQL_DATABASE}\` CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci;

-- Alle Tabellen konvertieren
SET @DATABASE_NAME = '${MYSQL_DATABASE}';

SELECT CONCAT('ALTER TABLE \`', table_name, '\` CONVERT TO CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;') AS statement
FROM information_schema.tables 
WHERE table_schema = @DATABASE_NAME 
AND table_type = 'BASE TABLE';

-- Zeige aktuelle Charset-Einstellungen
SHOW VARIABLES LIKE 'character_set_%';
SHOW VARIABLES LIKE 'collation_%';
"

print_info "Führe Charset-Migration durch..."

# Backup erstellen
print_info "Erstelle Backup vor Migration..."
BACKUP_FILE="/tmp/backup_${INSTANCE_NAME}_$(date +%Y%m%d_%H%M%S).sql"
docker exec "$CONTAINER_NAME" mysqldump -u root -p"${MYSQL_ROOT_PASSWORD}" "$MYSQL_DATABASE" > "$BACKUP_FILE"
print_success "Backup erstellt: $BACKUP_FILE"

# Migration ausführen
print_info "Führe Migration aus..."

# Temporäre SQL-Datei erstellen
TEMP_SQL="/tmp/migration_${INSTANCE_NAME}.sql"
echo "$MIGRATION_SQL" > "$TEMP_SQL"

# SQL in Container kopieren und ausführen
docker cp "$TEMP_SQL" "$CONTAINER_NAME:/tmp/migration.sql"
docker exec "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD}" < /tmp/migration.sql

# Aufräumen
rm -f "$TEMP_SQL"
docker exec "$CONTAINER_NAME" rm -f /tmp/migration.sql

print_success "Migration abgeschlossen!"

# Verification
print_info "Überprüfe Ergebnis..."
docker exec "$CONTAINER_NAME" mysql -u root -p"${MYSQL_ROOT_PASSWORD}" -e "
SELECT 
    DEFAULT_CHARACTER_SET_NAME, 
    DEFAULT_COLLATION_NAME 
FROM information_schema.SCHEMATA 
WHERE SCHEMA_NAME = '${MYSQL_DATABASE}';
"

print_success "✅ MariaDB UTF8MB4 Migration für Instanz '$INSTANCE_NAME' abgeschlossen!"
print_info "💡 Container neu starten, um sicherzustellen, dass alle Einstellungen aktiv sind:"
print_info "   ./manager $INSTANCE_NAME restart"
