#!/bin/bash

# REDAXO Multi-Instance Demo
# Erstellt eine Beispiel-Instanz zum Testen

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  REDAXO Multi-Instance Demo${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

echo -e "${YELLOW}Dieses Skript erstellt eine Demo-Instanz zum Testen des Systems.${NC}"
echo ""

# Prüfe ob bereits eine Demo-Instanz existiert
if [ -d "$PROJECT_DIR/instances/demo" ]; then
    echo -e "${YELLOW}Demo-Instanz 'demo' existiert bereits.${NC}"
    echo -e "${YELLOW}Möchten Sie sie ersetzen? (y/N)${NC}"
    read -r confirmation
    
    if [[ $confirmation =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}Lösche bestehende Demo-Instanz...${NC}"
        "$PROJECT_DIR/redaxo" remove demo <<< "y"
    else
        echo -e "${YELLOW}Demo abgebrochen${NC}"
        exit 0
    fi
fi

echo -e "${BLUE}Erstelle Demo-Instanz 'demo'...${NC}"
"$PROJECT_DIR/redaxo" create demo --domain demo.local

echo ""
echo -e "${BLUE}Starte Demo-Instanz...${NC}"
"$PROJECT_DIR/redaxo" start demo

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Demo-Instanz erfolgreich erstellt!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Lese Ports aus .env-Datei
if [ -f "$PROJECT_DIR/instances/demo/.env" ]; then
    source "$PROJECT_DIR/instances/demo/.env"
    
    echo -e "${BLUE}Zugriff auf die Demo-Instanz:${NC}"
    echo ""
    echo -e "  ${GREEN}REDAXO (HTTP):${NC}  http://localhost:$HTTP_PORT"
    echo -e "  ${GREEN}REDAXO (HTTPS):${NC} https://localhost:$HTTPS_PORT"
    echo -e "  ${GREEN}phpMyAdmin:${NC}     http://localhost:$PHPMYADMIN_PORT"
    echo -e "  ${GREEN}MailHog:${NC}        http://localhost:$MAILHOG_PORT"
    echo ""
    
    echo -e "${BLUE}Datenbank-Zugangsdaten:${NC}"
    echo -e "  Host: localhost"
    echo -e "  Port: 3306 (intern)"
    echo -e "  Datenbank: $MYSQL_DATABASE"
    echo -e "  Benutzer: $MYSQL_USER"
    echo -e "  Passwort: $MYSQL_PASSWORD"
    echo ""
    
    echo -e "${YELLOW}Hinweise:${NC}"
    echo -e "• Für HTTPS akzeptieren Sie das selbstsignierte Zertifikat im Browser"
    echo -e "• Installieren Sie REDAXO über: http://localhost:$HTTP_PORT/redaxo/"
    echo -e "• Verwenden Sie die oben genannten Datenbank-Zugangsdaten"
    echo ""
    
    echo -e "${BLUE}Weitere Befehle:${NC}"
    echo -e "  ./redaxo status demo     - Status anzeigen"
    echo -e "  ./redaxo logs demo       - Logs anzeigen"
    echo -e "  ./redaxo shell demo      - Shell öffnen"
    echo -e "  ./redaxo backup demo     - Backup erstellen"
    echo -e "  ./redaxo stop demo       - Demo stoppen"
    echo -e "  ./redaxo remove demo     - Demo löschen"
fi

echo ""
echo -e "${GREEN}Viel Spaß beim Testen! 🚀${NC}"
