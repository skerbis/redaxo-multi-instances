#!/bin/bash

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}=== REDAXO Multi-Instance Update-Tool ===${NC}"
echo -e "${YELLOW}Dieses Tool leitet Sie zum korrekten Update-Tool weiter.${NC}"
echo ""

# Projektverzeichnis
PROJECT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "$PROJECT_DIR"

echo -e "${BLUE}ℹ️  Multi-Instance-System erkannt!${NC}"
echo -e "${YELLOW}Für Updates verwenden Sie bitte die folgenden Tools:${NC}"
echo ""
echo -e "${GREEN}Für Instance-spezifische Updates:${NC}"
echo -e "  ./instance-update.sh <instance-name>        # Update einer spezifischen Instanz"
echo -e "  ./instance-update.sh <instance-name> php    # Nur PHP-Version aktualisieren"
echo -e "  ./instance-update.sh <instance-name> mariadb # Nur MariaDB-Version aktualisieren"
echo -e "  ./instance-update.sh <instance-name> all     # Vollständiges Update"
echo ""
echo -e "${GREEN}Für globale Verwaltung:${NC}"
echo -e "  ./instance-manager.sh list                   # Zeigt alle Instanzen"
echo -e "  ./instance-manager.sh help                   # Zeigt alle Befehle"
echo -e "  ./instance-manager.sh config-all             # Übersicht aller Konfigurationen"
echo ""
echo -e "${BLUE}Verfügbare Instanzen:${NC}"

# Zeige verfügbare Instanzen
if [ -d "instances" ]; then
    for instance in instances/*/; do
        if [ -d "$instance" ]; then
            instance_name=$(basename "$instance")
            echo -e "  📦 $instance_name"
        fi
    done
else
    echo -e "  ${YELLOW}Keine Instanzen gefunden.${NC}"
fi

echo ""
echo -e "${GREEN}Beispiel:${NC}"
echo -e "  ./instance-update.sh meine-instanz"
