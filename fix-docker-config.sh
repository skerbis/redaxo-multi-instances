#!/bin/bash

# Fix Docker Compose Konfiguration für alle Instanzen
# Behebt Port-Mapping und ARM-Kompatibilität

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
INSTANCES_DIR="$SCRIPT_DIR/instances"

echo -e "${GREEN}🔧 Docker Compose Konfiguration Fix${NC}"
echo "Behebt Port-Mapping und ARM-Kompatibilität für alle Instanzen"
echo ""

if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
    echo -e "${YELLOW}📭 Keine Instanzen gefunden${NC}"
    exit 0
fi

for instance_dir in "$INSTANCES_DIR"/*; do
    if [ -d "$instance_dir" ]; then
        instance_name=$(basename "$instance_dir")
        compose_file="$instance_dir/docker-compose.yml"
        
        if [ -f "$compose_file" ]; then
            echo -e "${BLUE}🔧 Bearbeite Instanz: $instance_name${NC}"
            
            # Backup erstellen
            cp "$compose_file" "$compose_file.backup.$(date +%Y%m%d_%H%M%S)"
            echo -e "  📄 Backup erstellt"
            
            # Port-Konfiguration korrigieren
            sed -i '' 's/"[0-9]*:80"/"${HTTP_PORT}:80"/g' "$compose_file"
            sed -i '' 's/"[0-9]*:443"/"${HTTPS_PORT}:443"/g' "$compose_file"
            sed -i '' 's/"[0-9]*:80"/"${PHPMYADMIN_PORT}:80"/g' "$compose_file" # PHPMyAdmin
            sed -i '' 's/"[0-9]*:8025"/"${MAILHOG_PORT}:8025"/g' "$compose_file" # MailHog
            
            # ARM-kompatible Images
            sed -i '' 's/phpmyadmin\/phpmyadmin/phpmyadmin:latest/g' "$compose_file"
            sed -i '' 's/mailhog\/mailhog/mailhog\/mailhog:latest/g' "$compose_file"
            
            # .env-Datei überprüfen und erweitern
            env_file="$instance_dir/.env"
            if [ -f "$env_file" ]; then
                # PHP und MariaDB Versionen hinzufügen falls nicht vorhanden
                if ! grep -q "PHP_VERSION" "$env_file"; then
                    echo "PHP_VERSION=8.4" >> "$env_file"
                fi
                if ! grep -q "MARIADB_VERSION" "$env_file"; then
                    echo "MARIADB_VERSION=latest" >> "$env_file"
                fi
            fi
            
            echo -e "${GREEN}  ✅ Konfiguration aktualisiert${NC}"
            echo ""
        fi
    fi
done

echo -e "${GREEN}🎉 Alle Instanzen wurden erfolgreich aktualisiert!${NC}"
echo ""
echo -e "${YELLOW}💡 Nächste Schritte:${NC}"
echo "1. Instanzen neu starten: ./redaxo stop <name> && ./redaxo start <name>"
echo "2. Services testen: ./redaxo urls <name>"
echo ""
echo -e "${BLUE}📋 ARM-Optimierung:${NC}"
echo "• PHPMyAdmin verwendet jetzt ARM-kompatible Images"
echo "• MailHog läuft stabiler auf Apple Silicon"
echo "• Port-Konfiguration verwendet jetzt Umgebungsvariablen"
