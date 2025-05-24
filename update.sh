#!/bin/bash

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== REDAXO Docker Update-Tool ===${NC}"
echo -e "${YELLOW}Dieses Tool hilft beim Aktualisieren der Docker-Container und Abhängigkeiten.${NC}"
echo ""

# Projektverzeichnis
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$PROJECT_DIR"

# Funktionen
show_help() {
    echo -e "Verwendung: ./update.sh [Option]"
    echo ""
    echo -e "Optionen:"
    echo -e "  php       - PHP-Version aktualisieren"
    echo -e "  apache    - Apache-Version aktualisieren"
    echo -e "  mariadb   - MariaDB-Version aktualisieren"
    echo -e "  all       - Alle Container neu bauen"
    echo -e "  help      - Diese Hilfe anzeigen"
}

update_php_version() {
    echo -e "${YELLOW}Aktuelle PHP-Version in den Dockerfiles:${NC}"
    grep -n "FROM.*php:" docker/apache/Dockerfile || echo "Keine PHP-Version gefunden."
    echo ""
    
    read -p "Neue PHP-Version (z.B. 8.3, 8.2, 8.1): " new_php_version
    
    if [[ -z "$new_php_version" ]]; then
        echo -e "${RED}Keine PHP-Version angegeben. Update abgebrochen.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Aktualisiere PHP-Version auf $new_php_version...${NC}"
    sed -i '' "s/FROM --platform=linux\/arm64\/v8 php:[0-9]\.[0-9]-apache/FROM --platform=linux\/arm64\/v8 php:$new_php_version-apache/g" docker/apache/Dockerfile
    
    echo -e "${GREEN}Dockerfile wurde aktualisiert. Starte den Rebuild-Prozess...${NC}"
    rebuild_containers
}

update_apache_version() {
    echo -e "${YELLOW}Die Apache-Version ist an die PHP-Version gekoppelt.${NC}"
    echo -e "${YELLOW}Möchten Sie die neueste Version von Apache mit der aktuellen PHP-Version verwenden?${NC}"
    read -p "Fortfahren? [j/N] " continue
    
    if [[ ! $continue =~ ^[Jj]$ ]]; then
        echo -e "${RED}Update abgebrochen.${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Starte den Rebuild-Prozess für Apache...${NC}"
    rebuild_containers
}

update_mariadb_version() {
    echo -e "${YELLOW}Aktuelle MariaDB-Version in docker-compose.yml:${NC}"
    grep -n "image: mariadb:" docker-compose.yml || echo "Keine MariaDB-Version gefunden."
    echo ""
    
    read -p "Neue MariaDB-Version (z.B. latest, 10.11, 10.6): " new_mariadb_version
    
    if [[ -z "$new_mariadb_version" ]]; then
        echo -e "${RED}Keine MariaDB-Version angegeben. Update abgebrochen.${NC}"
        exit 1
    fi
    
    echo -e "${YELLOW}Aktualisiere MariaDB-Version auf $new_mariadb_version...${NC}"
    sed -i '' "s/image: mariadb:.*/image: mariadb:$new_mariadb_version/g" docker-compose.yml
    
    echo -e "${GREEN}docker-compose.yml wurde aktualisiert. Starte den Rebuild-Prozess...${NC}"
    rebuild_containers
}

rebuild_containers() {
    echo -e "${YELLOW}Stoppe laufende Container...${NC}"
    docker-compose down
    
    echo -e "${YELLOW}Baue Container neu ohne Cache...${NC}"
    docker-compose build --no-cache
    
    echo -e "${YELLOW}Starte aktualisierte Container...${NC}"
    docker-compose up -d
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Container wurden erfolgreich aktualisiert und neu gestartet!${NC}"
        echo -e "${GREEN}Folgende Services sind verfügbar:${NC}"
        
        # Lade die Umgebungsvariablen aus .env
        if [ -f .env ]; then
            source .env
        fi
        
        # Verwende Standardwerte, wenn nicht in .env gesetzt
        APACHE_PORT=${APACHE_PORT:-8080}
        PHPMYADMIN_PORT=${PHPMYADMIN_PORT:-8081}
        MAILHOG_PORT=${MAILHOG_PORT:-8025}
        PORTAINER_PORT=${PORTAINER_PORT:-9000}
        
        echo -e "${GREEN}REDAXO:${NC} http://localhost:$APACHE_PORT"
        echo -e "${GREEN}phpMyAdmin:${NC} http://localhost:$PHPMYADMIN_PORT"
        echo -e "${GREEN}MailHog:${NC} http://localhost:$MAILHOG_PORT"
        echo -e "${GREEN}Portainer:${NC} http://localhost:$PORTAINER_PORT"
    else
        echo -e "${RED}Fehler beim Aktualisieren der Container.${NC}"
        exit 1
    fi
}

update_all() {
    echo -e "${YELLOW}Aktualisiere alle Container mit den neuesten Versionen...${NC}"
    docker-compose pull
    rebuild_containers
}

# Hauptprogramm
case "$1" in
    php)
        update_php_version
        ;;
    apache)
        update_apache_version
        ;;
    mariadb)
        update_mariadb_version
        ;;
    all)
        update_all
        ;;
    *)
        show_help
        ;;
esac
