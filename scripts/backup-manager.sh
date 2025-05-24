#!/bin/bash

# REDAXO Instance Backup & Restore Manager
# Sicherung und Wiederherstellung von REDAXO-Instanzen

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTANCES_DIR="$PROJECT_DIR/instances"
BACKUP_DIR="$PROJECT_DIR/backups"

# Erstelle Backup-Verzeichnis falls nicht vorhanden
mkdir -p "$BACKUP_DIR"

# Funktionen
show_help() {
    echo -e "${GREEN}REDAXO Instance Backup & Restore Manager${NC}"
    echo "Sicherung und Wiederherstellung von REDAXO-Instanzen"
    echo ""
    echo "Verwendung:"
    echo "  ./backup-manager.sh [Befehl] [Optionen]"
    echo ""
    echo "Befehle:"
    echo "  backup <name>           - Instanz sichern"
    echo "  restore <name> <file>   - Instanz wiederherstellen"
    echo "  list-backups           - Alle Backups auflisten"
    echo "  cleanup [days]         - Alte Backups löschen (Standard: 30 Tage)"
    echo "  help                   - Diese Hilfe anzeigen"
    echo ""
    echo "Optionen bei backup:"
    echo "  --compress             - Backup komprimieren (Standard)"
    echo "  --no-compress          - Backup nicht komprimieren"
    echo "  --include-db           - Datenbank mit sichern (Standard)"
    echo "  --no-db                - Datenbank nicht sichern"
}

# Prüft ob eine Instanz existiert
instance_exists() {
    local name=$1
    if [ -d "$INSTANCES_DIR/$name" ]; then
        return 0
    else
        return 1
    fi
}

# Erstellt Backup einer Instanz
backup_instance() {
    local name=$1
    local compress=true
    local include_db=true
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        show_help
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    # Parse Optionen
    shift
    while [[ $# -gt 0 ]]; do
        case $1 in
            --no-compress)
                compress=false
                shift
                ;;
            --compress)
                compress=true
                shift
                ;;
            --no-db)
                include_db=false
                shift
                ;;
            --include-db)
                include_db=true
                shift
                ;;
            *)
                echo -e "${RED}Unbekannte Option: $1${NC}"
                exit 1
                ;;
        esac
    done
    
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local backup_name="${name}_${timestamp}"
    local temp_dir="$BACKUP_DIR/temp_$backup_name"
    local instance_dir="$INSTANCES_DIR/$name"
    
    echo -e "${YELLOW}Erstelle Backup für Instanz '$name'...${NC}"
    
    # Erstelle temporäres Backup-Verzeichnis
    mkdir -p "$temp_dir"
    
    # Kopiere App-Verzeichnis
    echo -e "${BLUE}Sichere Dateien...${NC}"
    cp -r "$instance_dir/app" "$temp_dir/"
    
    # Kopiere Konfigurationsdateien
    cp "$instance_dir/.env" "$temp_dir/"
    cp "$instance_dir/docker-compose.yml" "$temp_dir/"
    
    # Sichere Datenbank wenn gewünscht
    if [ "$include_db" = true ]; then
        echo -e "${BLUE}Sichere Datenbank...${NC}"
        
        # Lade Umgebungsvariablen
        source "$instance_dir/.env"
        
        # Prüfe ob Container läuft
        if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-mariadb"; then
            docker exec "redaxo-${name}-mariadb" mysqldump \
                -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
                > "$temp_dir/database.sql"
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}Datenbank erfolgreich gesichert${NC}"
            else
                echo -e "${RED}Fehler beim Sichern der Datenbank${NC}"
                rm -rf "$temp_dir"
                exit 1
            fi
        else
            echo -e "${YELLOW}Warnung: Datenbank-Container läuft nicht. Datenbank wird übersprungen.${NC}"
        fi
    fi
    
    # Erstelle Backup-Info
    cat > "$temp_dir/backup-info.txt" << EOF
REDAXO Instance Backup
======================
Instance Name: $name
Backup Date: $(date)
Backup Type: $([ "$include_db" = true ] && echo "Full (Files + Database)" || echo "Files only")
Compression: $([ "$compress" = true ] && echo "Yes" || echo "No")

Database Info:
- Name: $MYSQL_DATABASE
- User: $MYSQL_USER

Created by: REDAXO Multi-Instance Manager
EOF
    
    # Komprimiere Backup falls gewünscht
    if [ "$compress" = true ]; then
        echo -e "${BLUE}Komprimiere Backup...${NC}"
        cd "$BACKUP_DIR"
        tar -czf "${backup_name}.tar.gz" -C "$temp_dir" .
        
        if [ $? -eq 0 ]; then
            rm -rf "$temp_dir"
            echo -e "${GREEN}Backup erstellt: ${backup_name}.tar.gz${NC}"
            echo -e "${BLUE}Backup-Pfad: $BACKUP_DIR/${backup_name}.tar.gz${NC}"
        else
            echo -e "${RED}Fehler beim Komprimieren des Backups${NC}"
            rm -rf "$temp_dir"
            exit 1
        fi
    else
        mv "$temp_dir" "$BACKUP_DIR/$backup_name"
        echo -e "${GREEN}Backup erstellt: $backup_name${NC}"
        echo -e "${BLUE}Backup-Pfad: $BACKUP_DIR/$backup_name${NC}"
    fi
}

# Stellt Backup einer Instanz wieder her
restore_instance() {
    local name=$1
    local backup_file=$2
    
    if [ -z "$name" ] || [ -z "$backup_file" ]; then
        echo -e "${RED}Fehler: Instanzname und Backup-Datei erforderlich${NC}"
        show_help
        exit 1
    fi
    
    # Prüfe Backup-Datei
    local backup_path=""
    if [ -f "$backup_file" ]; then
        backup_path="$backup_file"
    elif [ -f "$BACKUP_DIR/$backup_file" ]; then
        backup_path="$BACKUP_DIR/$backup_file"
    elif [ -f "$BACKUP_DIR/${backup_file}.tar.gz" ]; then
        backup_path="$BACKUP_DIR/${backup_file}.tar.gz"
    else
        echo -e "${RED}Fehler: Backup-Datei nicht gefunden: $backup_file${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Stelle Instanz '$name' aus Backup wieder her...${NC}"
    echo -e "${BLUE}Backup: $backup_path${NC}"
    
    # Warnung wenn Instanz bereits existiert
    if instance_exists "$name"; then
        echo -e "${YELLOW}Warnung: Instanz '$name' existiert bereits und wird überschrieben!${NC}"
        echo -e "${YELLOW}Möchten Sie fortfahren? (y/N)${NC}"
        read -r confirmation
        
        if [[ ! $confirmation =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}Wiederherstellung abgebrochen${NC}"
            exit 0
        fi
        
        # Stoppe existierende Instanz
        if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-"; then
            echo -e "${BLUE}Stoppe existierende Instanz...${NC}"
            cd "$INSTANCES_DIR/$name"
            docker-compose down -v
        fi
        
        # Lösche existierende Instanz
        rm -rf "$INSTANCES_DIR/$name"
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    local temp_dir="$BACKUP_DIR/restore_temp_$$"
    
    # Erstelle Instanz-Verzeichnis
    mkdir -p "$instance_dir"
    mkdir -p "$temp_dir"
    
    # Extrahiere Backup
    echo -e "${BLUE}Extrahiere Backup...${NC}"
    if [[ "$backup_path" == *.tar.gz ]]; then
        tar -xzf "$backup_path" -C "$temp_dir"
    else
        cp -r "$backup_path"/* "$temp_dir/"
    fi
    
    # Stelle Dateien wieder her
    echo -e "${BLUE}Stelle Dateien wieder her...${NC}"
    cp -r "$temp_dir/app" "$instance_dir/"
    cp "$temp_dir/.env" "$instance_dir/"
    cp "$temp_dir/docker-compose.yml" "$instance_dir/"
    
    # Kopiere Docker-Konfiguration falls nicht im Backup
    if [ ! -d "$instance_dir/docker" ]; then
        cp -r "$PROJECT_DIR/docker" "$instance_dir/"
    fi
    
    # Starte Instanz
    echo -e "${BLUE}Starte Instanz...${NC}"
    cd "$instance_dir"
    docker-compose up -d mariadb
    
    # Warte bis Datenbank bereit ist
    echo -e "${BLUE}Warte auf Datenbank...${NC}"
    sleep 10
    
    # Stelle Datenbank wieder her falls vorhanden
    if [ -f "$temp_dir/database.sql" ]; then
        echo -e "${BLUE}Stelle Datenbank wieder her...${NC}"
        
        source "$instance_dir/.env"
        
        # Importiere Datenbank
        docker exec -i "redaxo-${name}-mariadb" mysql \
            -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
            < "$temp_dir/database.sql"
        
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}Datenbank erfolgreich wiederhergestellt${NC}"
        else
            echo -e "${RED}Fehler beim Wiederherstellen der Datenbank${NC}"
        fi
    fi
    
    # Starte alle Services
    docker-compose up -d
    
    # Cleanup
    rm -rf "$temp_dir"
    
    echo -e "${GREEN}Instanz '$name' erfolgreich wiederhergestellt${NC}"
    
    # Zeige URLs
    source "$instance_dir/.env"
    echo ""
    echo -e "${BLUE}URLs:${NC}"
    echo "  REDAXO:     http://localhost:$HTTP_PORT"
    if [ -n "$HTTPS_PORT" ]; then
        echo "  REDAXO SSL: https://localhost:$HTTPS_PORT"
    fi
    echo "  phpMyAdmin: http://localhost:$PHPMYADMIN_PORT"
    echo "  MailHog:    http://localhost:$MAILHOG_PORT"
}

# Listet alle Backups auf
list_backups() {
    echo -e "${GREEN}Verfügbare Backups:${NC}"
    echo ""
    
    if [ ! -d "$BACKUP_DIR" ] || [ -z "$(ls -A "$BACKUP_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}Keine Backups gefunden${NC}"
        return
    fi
    
    for backup in "$BACKUP_DIR"/*; do
        if [ -f "$backup" ] && [[ "$backup" == *.tar.gz ]]; then
            local name=$(basename "$backup" .tar.gz)
            local size=$(du -h "$backup" | cut -f1)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            
            echo -e "  ${BLUE}$name${NC}"
            echo -e "    Größe: $size"
            echo -e "    Datum: $date"
            echo ""
        elif [ -d "$backup" ] && [[ ! "$backup" =~ temp_ ]]; then
            local name=$(basename "$backup")
            local size=$(du -sh "$backup" | cut -f1)
            local date=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$backup" 2>/dev/null || stat -c "%y" "$backup" 2>/dev/null | cut -d' ' -f1,2 | cut -d'.' -f1)
            
            echo -e "  ${BLUE}$name${NC} (Ordner)"
            echo -e "    Größe: $size"
            echo -e "    Datum: $date"
            echo ""
        fi
    done
}

# Bereinigt alte Backups
cleanup_backups() {
    local days=${1:-30}
    
    echo -e "${YELLOW}Lösche Backups älter als $days Tage...${NC}"
    
    if [ ! -d "$BACKUP_DIR" ]; then
        echo -e "${YELLOW}Keine Backups gefunden${NC}"
        return
    fi
    
    local deleted_count=0
    
    # Finde und lösche alte Dateien
    find "$BACKUP_DIR" -name "*.tar.gz" -type f -mtime "+$days" | while read -r backup; do
        echo -e "${BLUE}Lösche: $(basename "$backup")${NC}"
        rm "$backup"
        ((deleted_count++))
    done
    
    # Finde und lösche alte Ordner
    find "$BACKUP_DIR" -maxdepth 1 -type d -mtime "+$days" | grep -v "^$BACKUP_DIR$" | while read -r backup; do
        if [[ ! "$backup" =~ temp_ ]]; then
            echo -e "${BLUE}Lösche: $(basename "$backup")${NC}"
            rm -rf "$backup"
            ((deleted_count++))
        fi
    done
    
    echo -e "${GREEN}Bereinigung abgeschlossen${NC}"
}

# Hauptlogik
case $1 in
    backup)
        shift
        backup_instance "$@"
        ;;
    restore)
        restore_instance "$2" "$3"
        ;;
    list-backups)
        list_backups
        ;;
    cleanup)
        cleanup_backups "$2"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo -e "${RED}Unbekannter Befehl: $1${NC}"
        show_help
        exit 1
        ;;
esac
