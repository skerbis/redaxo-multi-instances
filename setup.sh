#!/bin/bash

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== REDAXO Docker Setup ===${NC}"
echo -e "${YELLOW}Dieser Assistent richtet die REDAXO Docker-Umgebung ein.${NC}"
echo ""

# Prüfen, ob Docker installiert ist
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker ist nicht installiert. Bitte installieren Sie Docker und versuchen Sie es erneut.${NC}"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Docker Compose ist nicht installiert. Bitte installieren Sie Docker Compose und versuchen Sie es erneut.${NC}"
    exit 1
fi

# Projektverzeichnis
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$PROJECT_DIR"

# Sicherstellen, dass der App-Ordner existiert
mkdir -p app

# Überprüfen, ob .env existiert, sonst erstellen
if [ ! -f .env ]; then
    echo -e "${YELLOW}Erstelle .env-Datei mit Standardwerten...${NC}"
    cat > .env << EOL
# MariaDB-Konfiguration
MYSQL_ROOT_PASSWORD=redaxo_root
MYSQL_DATABASE=redaxo
MYSQL_USER=redaxo
MYSQL_PASSWORD=redaxo

# Portmapping
APACHE_PORT=8080
PHPMYADMIN_PORT=8081
MAILHOG_PORT=8025
PORTAINER_PORT=9000

# Pfade
APP_DIR=./app
PROJECT_NAME=redaxo-docker
EOL
    echo -e "${GREEN}.env-Datei erstellt.${NC}"
fi

# Konfiguration anpassen?
read -p "Möchten Sie die Konfiguration anpassen? [j/N] " answer
if [[ $answer =~ ^[Jj]$ ]]; then
    # MariaDB Konfiguration
    read -p "MariaDB Root Passwort [redaxo_root]: " mysql_root_pw
    read -p "MariaDB Datenbank Name [redaxo]: " mysql_db
    read -p "MariaDB Benutzer [redaxo]: " mysql_user
    read -p "MariaDB Passwort [redaxo]: " mysql_pw

    # Ports
    read -p "Apache Port [8080]: " apache_port
    read -p "phpMyAdmin Port [8081]: " phpmyadmin_port
    read -p "MailHog Port [8025]: " mailhog_port
    read -p "Portainer Port [9000]: " portainer_port

    # .env Datei aktualisieren
    sed -i '' "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${mysql_root_pw:-redaxo_root}/g" .env
    sed -i '' "s/MYSQL_DATABASE=.*/MYSQL_DATABASE=${mysql_db:-redaxo}/g" .env
    sed -i '' "s/MYSQL_USER=.*/MYSQL_USER=${mysql_user:-redaxo}/g" .env
    sed -i '' "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${mysql_pw:-redaxo}/g" .env
    
    sed -i '' "s/APACHE_PORT=.*/APACHE_PORT=${apache_port:-8080}/g" .env
    sed -i '' "s/PHPMYADMIN_PORT=.*/PHPMYADMIN_PORT=${phpmyadmin_port:-8081}/g" .env
    sed -i '' "s/MAILHOG_PORT=.*/MAILHOG_PORT=${mailhog_port:-8025}/g" .env
    sed -i '' "s/PORTAINER_PORT=.*/PORTAINER_PORT=${portainer_port:-9000}/g" .env
    
    echo -e "${GREEN}Konfiguration aktualisiert.${NC}"
fi

# Docker-Container starten
echo -e "${YELLOW}Starte Docker-Container...${NC}"
docker-compose up -d

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Docker-Container wurden erfolgreich gestartet.${NC}"
    
    # URLs anzeigen
    source .env
    APACHE_PORT=${APACHE_PORT:-8080}
    PHPMYADMIN_PORT=${PHPMYADMIN_PORT:-8081}
    MAILHOG_PORT=${MAILHOG_PORT:-8025}
    PORTAINER_PORT=${PORTAINER_PORT:-9000}
    
    echo -e "${GREEN}Folgende Services sind verfügbar:${NC}"
    echo -e "${GREEN}REDAXO:${NC} http://localhost:$APACHE_PORT"
    echo -e "${GREEN}phpMyAdmin:${NC} http://localhost:$PHPMYADMIN_PORT"
    echo -e "${GREEN}MailHog:${NC} http://localhost:$MAILHOG_PORT"
    echo -e "${GREEN}Portainer:${NC} http://localhost:$PORTAINER_PORT"
    
    echo -e "\n${YELLOW}Zum Starten/Stoppen der Container verwenden Sie: ./redaxo-docker.sh${NC}"
else
    echo -e "${RED}Fehler beim Starten der Docker-Container.${NC}"
    exit 1
fi
