#!/bin/bash

# ===============================================
# LEGACY SCRIPT - DEPRECATED
# ===============================================
# Dieses Skript ist veraltet und wird durch das
# neue Multi-Instance System ersetzt.
#
# Verwenden Sie stattdessen:
#   ./redaxo help
#   ./redaxo create <instanz-name>
#   ./redaxo start <instanz-name>
# ===============================================

echo "=========================================="
echo "  WARNUNG: Veraltetes Skript"
echo "=========================================="
echo ""
echo "Dieses Skript wurde durch das neue Multi-Instance System ersetzt."
echo ""
echo "Verwenden Sie stattdessen:"
echo "  ./redaxo help           - Hilfe anzeigen"
echo "  ./redaxo create test    - Neue Instanz erstellen"
echo "  ./redaxo start test     - Instanz starten"
echo "  ./redaxo list           - Alle Instanzen auflisten"
echo ""
echo "Möchten Sie trotzdem fortfahren? (y/N)"
read -r confirmation

if [[ ! $confirmation =~ ^[Yy]$ ]]; then
    echo "Abgebrochen. Verwenden Sie das neue System: ./redaxo help"
    exit 0
fi

echo ""
echo "Fahre mit legacy Skript fort..."
echo ""

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Projektverzeichnis
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$PROJECT_DIR"

# Funktionen
show_help() {
    echo -e "${GREEN}REDAXO Docker Entwicklungsumgebung${NC}"
    echo "Verwendung:"
    echo "  ./redaxo-docker.sh [Befehl]"
    echo ""
    echo "Befehle:"
    echo "  start       - Container starten"
    echo "  stop        - Container stoppen"
    echo "  restart     - Container neustarten"
    echo "  status      - Status der Container anzeigen"
    echo "  logs        - Container-Logs anzeigen (mit -f für fortlaufende Logs)"
    echo "  shell       - Shell im Apache-Container öffnen"
    echo "  mysql       - MySQL-Shell im MariaDB-Container öffnen"
    echo "  help        - Diese Hilfe anzeigen"
}

start_containers() {
    echo -e "${YELLOW}Starte Docker-Container...${NC}"
    docker-compose up -d
    
    # Prüfen, ob alle Container laufen
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Alle Container wurden erfolgreich gestartet.${NC}"
        show_urls
    else
        echo -e "${RED}Fehler beim Starten der Container.${NC}"
        exit 1
    fi
}

stop_containers() {
    echo -e "${YELLOW}Stoppe Docker-Container...${NC}"
    docker-compose down
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Alle Container wurden erfolgreich gestoppt.${NC}"
    else
        echo -e "${RED}Fehler beim Stoppen der Container.${NC}"
        exit 1
    fi
}

restart_containers() {
    echo -e "${YELLOW}Starte Docker-Container neu...${NC}"
    docker-compose restart
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}Alle Container wurden erfolgreich neu gestartet.${NC}"
        show_urls
    else
        echo -e "${RED}Fehler beim Neustarten der Container.${NC}"
        exit 1
    fi
}

show_status() {
    echo -e "${YELLOW}Status der Docker-Container:${NC}"
    docker-compose ps
}

show_logs() {
    if [ "$1" == "-f" ]; then
        echo -e "${YELLOW}Zeige fortlaufende Logs an. Drücke Strg+C zum Beenden.${NC}"
        docker-compose logs -f
    else
        echo -e "${YELLOW}Zeige Logs an:${NC}"
        docker-compose logs
    fi
}

open_shell() {
    echo -e "${YELLOW}Öffne Shell im Apache-Container...${NC}"
    docker-compose exec apache /bin/bash
}

open_mysql() {
    echo -e "${YELLOW}Öffne MySQL-Shell im MariaDB-Container...${NC}"
    docker-compose exec mariadb mysql -u root -p
}

show_urls() {
    # Lade die Umgebungsvariablen aus .env
    if [ -f .env ]; then
        source .env
    fi
    
    # Verwende Standardwerte, wenn nicht in .env gesetzt
    APACHE_PORT=${APACHE_PORT:-8080}
    PHPMYADMIN_PORT=${PHPMYADMIN_PORT:-8081}
    MAILHOG_PORT=${MAILHOG_PORT:-8025}
    PORTAINER_PORT=${PORTAINER_PORT:-9000}
    
    echo -e "${GREEN}Folgende Services sind verfügbar:${NC}"
    echo -e "${GREEN}REDAXO:${NC} http://localhost:$APACHE_PORT"
    echo -e "${GREEN}phpMyAdmin:${NC} http://localhost:$PHPMYADMIN_PORT"
    echo -e "${GREEN}MailHog:${NC} http://localhost:$MAILHOG_PORT"
    echo -e "${GREEN}Portainer:${NC} http://localhost:$PORTAINER_PORT"
}

# Hauptprogramm
case "$1" in
    start)
        start_containers
        ;;
    stop)
        stop_containers
        ;;
    restart)
        restart_containers
        ;;
    status)
        show_status
        ;;
    logs)
        show_logs $2
        ;;
    shell)
        open_shell
        ;;
    mysql)
        open_mysql
        ;;
    *)
        show_help
        ;;
esac
