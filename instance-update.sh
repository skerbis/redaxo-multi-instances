#!/bin/bash

# REDAXO Instance Update Tool
# Aktualisierung von Docker-Komponenten für spezifische Instanzen

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
INSTANCES_DIR="$PROJECT_DIR/instances"

echo -e "${GREEN}=== REDAXO Instance Update-Tool ===${NC}"
echo -e "${YELLOW}Aktualisierung von Docker-Komponenten für spezifische Instanzen${NC}"
echo ""

# Funktionen
show_help() {
    echo -e "Verwendung: ./update.sh <instanzname> [Komponente]"
    echo ""
    echo -e "Parameter:"
    echo -e "  <instanzname>     - Name der zu aktualisierenden Instanz"
    echo ""
    echo -e "Komponenten:"
    echo -e "  php <version>     - PHP-Version aktualisieren (z.B. 8.3, 8.2)"
    echo -e "  apache            - Apache-Version aktualisieren"
    echo -e "  mariadb <version> - MariaDB-Version aktualisieren"
    echo -e "  all               - Alle Container neu bauen"
    echo -e "  help              - Diese Hilfe anzeigen"
    echo ""
    echo -e "Beispiele:"
    echo -e "  ./update.sh meine-instanz php 8.3"
    echo -e "  ./update.sh kunde-website mariadb 10.11"
    echo -e "  ./update.sh test-projekt all"
    echo ""
    echo -e "Verfügbare Instanzen:"
    if [ -d "$INSTANCES_DIR" ] && [ "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                echo -e "  - $name"
            fi
        done
    else
        echo -e "  ${YELLOW}Keine Instanzen gefunden${NC}"
    fi
}

# Prüft ob eine Instanz existiert
check_instance() {
    local instance_name=$1
    
    if [ -z "$instance_name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        echo ""
        show_help
        exit 1
    fi
    
    if [ ! -d "$INSTANCES_DIR/$instance_name" ]; then
        echo -e "${RED}Fehler: Instanz '$instance_name' nicht gefunden${NC}"
        echo ""
        echo -e "Verfügbare Instanzen:"
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                echo -e "  - $name"
            fi
        done
        exit 1
    fi
    
    echo -e "${BLUE}Aktualisiere Instanz: $instance_name${NC}"
    echo ""
}

# PHP-Version in spezifischer Instanz aktualisieren
update_instance_php() {
    local instance_name=$1
    local new_version=$2
    local instance_dir="$INSTANCES_DIR/$instance_name"
    local dockerfile="$instance_dir/docker/apache/Dockerfile"
    
    if [ -z "$new_version" ]; then
        echo -e "${YELLOW}Aktuelle PHP-Version:${NC}"
        if [ -f "$dockerfile" ]; then
            grep -n "FROM.*php:" "$dockerfile" || echo "Keine PHP-Version gefunden."
        else
            echo -e "${RED}Dockerfile nicht gefunden: $dockerfile${NC}"
            exit 1
        fi
        echo ""
        
        read -p "Neue PHP-Version (z.B. 8.3, 8.2, 8.1): " new_version
    fi
    
    if [[ -z "$new_version" ]]; then
        echo -e "${RED}Keine PHP-Version angegeben. Update abgebrochen.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Aktualisiere PHP-Version auf $new_version...${NC}"
    
    # Update Dockerfile
    if [ -f "$dockerfile" ]; then
        # Backup erstellen
        cp "$dockerfile" "$dockerfile.backup-$(date +%Y%m%d_%H%M%S)"
        
        # PHP-Version aktualisieren
        sed -i '' "s/FROM.*php:[0-9]\.[0-9]-apache/FROM php:$new_version-apache/g" "$dockerfile"
        
        # Für ARM64 Macs
        sed -i '' "s/FROM --platform=linux\/arm64\/v8.*php:[0-9]\.[0-9]-apache/FROM --platform=linux\/arm64\/v8 php:$new_version-apache/g" "$dockerfile"
        
        echo -e "${GREEN}✓ Dockerfile aktualisiert${NC}"
    else
        echo -e "${RED}Dockerfile nicht gefunden: $dockerfile${NC}"
        exit 1
    fi
    
    rebuild_instance_containers "$instance_name"
}

# MariaDB-Version in spezifischer Instanz aktualisieren
update_instance_mariadb() {
    local instance_name=$1
    local new_version=$2
    local instance_dir="$INSTANCES_DIR/$instance_name"
    local compose_file="$instance_dir/docker-compose.yml"
    
    if [ -z "$new_version" ]; then
        echo -e "${YELLOW}Aktuelle MariaDB-Version:${NC}"
        if [ -f "$compose_file" ]; then
            grep -n "image: mariadb:" "$compose_file" || echo "Keine MariaDB-Version gefunden."
        else
            echo -e "${RED}docker-compose.yml nicht gefunden: $compose_file${NC}"
            exit 1
        fi
        echo ""
        
        read -p "Neue MariaDB-Version (z.B. latest, 10.11, 10.6): " new_version
    fi
    
    if [[ -z "$new_version" ]]; then
        echo -e "${RED}Keine MariaDB-Version angegeben. Update abgebrochen.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Aktualisiere MariaDB-Version auf $new_version...${NC}"
    
    if [ -f "$compose_file" ]; then
        # Backup erstellen
        cp "$compose_file" "$compose_file.backup-$(date +%Y%m%d_%H%M%S)"
        
        # MariaDB-Version aktualisieren
        sed -i '' "s/image: mariadb:.*/image: mariadb:$new_version/g" "$compose_file"
        
        echo -e "${GREEN}✓ docker-compose.yml aktualisiert${NC}"
    else
        echo -e "${RED}docker-compose.yml nicht gefunden: $compose_file${NC}"
        exit 1
    fi
    
    rebuild_instance_containers "$instance_name"
}

# Apache-Version aktualisieren (gekoppelt an PHP)
update_instance_apache() {
    local instance_name=$1
    
    echo -e "${YELLOW}Apache-Version ist an PHP gekoppelt.${NC}"
    echo -e "${YELLOW}Container werden neu gebaut um neueste Apache-Version zu verwenden.${NC}"
    read -p "Fortfahren? [j/N] " continue
    
    if [[ ! $continue =~ ^[Jj]$ ]]; then
        echo -e "${RED}Update abgebrochen.${NC}"
        exit 1
    fi
    
    rebuild_instance_containers "$instance_name"
}

# Container einer Instanz neu bauen
rebuild_instance_containers() {
    local instance_name=$1
    local instance_dir="$INSTANCES_DIR/$instance_name"
    
    echo -e "${YELLOW}Stoppe Container der Instanz '$instance_name'...${NC}"
    cd "$instance_dir"
    docker-compose down
    
    echo -e "${YELLOW}Baue Container neu ohne Cache...${NC}"
    docker-compose build --no-cache
    
    echo -e "${YELLOW}Starte aktualisierte Container...${NC}"
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Container wurden erfolgreich aktualisiert!${NC}"
        echo ""
        
        # Zeige Services an
        if [ -f "$instance_dir/.env" ]; then
            source "$instance_dir/.env"
            
            echo -e "${GREEN}Verfügbare Services für '$instance_name':${NC}"
            echo -e "${GREEN}REDAXO:${NC} http://localhost:${HTTP_PORT}"
            echo -e "${GREEN}phpMyAdmin:${NC} http://localhost:${PHPMYADMIN_PORT}"
            echo -e "${GREEN}MailHog:${NC} http://localhost:${MAILHOG_PORT}"
        fi
    else
        echo -e "${RED}Fehler beim Aktualisieren der Container.${NC}"
        exit 1
    fi
    
    # Zurück zum Projektverzeichnis
    cd "$PROJECT_DIR"
}

# Alle Container einer Instanz aktualisieren
update_instance_all() {
    local instance_name=$1
    local instance_dir="$INSTANCES_DIR/$instance_name"
    
    echo -e "${YELLOW}Aktualisiere alle Container der Instanz '$instance_name'...${NC}"
    
    cd "$instance_dir"
    docker-compose pull
    cd "$PROJECT_DIR"
    
    rebuild_instance_containers "$instance_name"
}

# Hauptprogramm
if [ "$1" = "help" ] || [ "$1" = "--help" ] || [ "$1" = "-h" ] || [ -z "$1" ]; then
    show_help
    exit 0
fi

instance_name=$1
component=$2

check_instance "$instance_name"

case "$component" in
    php)
        update_instance_php "$instance_name" "$3"
        ;;
    apache)
        update_instance_apache "$instance_name"
        ;;
    mariadb)
        update_instance_mariadb "$instance_name" "$3"
        ;;
    all)
        update_instance_all "$instance_name"
        ;;
    *)
        echo -e "${RED}Unbekannte Komponente: $component${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
