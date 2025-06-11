#!/bin/bash

# REDAXO Multi-Instance Manager - System-Status
# Zeigt eine kompakte Übersicht aller laufenden Services

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Icons
CHECK="✅"
INFO="ℹ️"
ROCKET="🚀"

echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  ${ROCKET} REDAXO Multi-Instance Manager - Status${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo ""

# Dashboard Status
if curl -s http://localhost:3000 >/dev/null 2>&1; then
    echo -e "${CHECK} ${GREEN}Dashboard läuft${NC} → ${CYAN}http://localhost:3000${NC}"
else
    echo -e "❌ ${YELLOW}Dashboard nicht erreichbar${NC}"
fi

# Docker Status
if docker info >/dev/null 2>&1; then
    running_containers=$(docker ps --filter "name=redaxo" --format "{{.Names}}" | wc -l | xargs)
    total_containers=$(docker ps -a --filter "name=redaxo" --format "{{.Names}}" | wc -l | xargs)
    echo -e "${CHECK} ${GREEN}Docker läuft${NC} → ${CYAN}${running_containers}/${total_containers} REDAXO Container aktiv${NC}"
else
    echo -e "❌ ${YELLOW}Docker nicht verfügbar${NC}"
fi

# REDAXO Instanzen
echo ""
echo -e "${CYAN}📱 Aktive REDAXO-Instanzen:${NC}"

cd "$(dirname "$0")"

if [ -d "instances" ]; then
    instance_count=0
    for instance_dir in instances/*/; do
        if [ -d "$instance_dir" ]; then
            instance_name=$(basename "$instance_dir")
            
            # Prüfe ob Container läuft
            if docker ps --filter "name=redaxo-$instance_name-apache" --format "{{.Names}}" | grep -q "redaxo-$instance_name-apache"; then
                # Port aus docker-compose.yml auslesen
                if [ -f "$instance_dir/docker-compose.yml" ]; then
                    port=$(grep -A5 "apache:" "$instance_dir/docker-compose.yml" | grep "ports:" -A1 | grep -o "[0-9]*:80" | cut -d':' -f1 || echo "????")
                    echo -e "   ${CHECK} ${GREEN}$instance_name${NC} → ${CYAN}http://localhost:$port${NC}"
                    ((instance_count++))
                else
                    echo -e "   ${CHECK} ${GREEN}$instance_name${NC} → ${YELLOW}Port unbekannt${NC}"
                    ((instance_count++))
                fi
            fi
        fi
    done
    
    if [ $instance_count -eq 0 ]; then
        echo -e "   ${INFO} ${YELLOW}Keine aktiven Instanzen${NC}"
        echo -e "   ${INFO} Erstellen Sie eine neue Instanz über das Dashboard"
    fi
else
    echo -e "   ${INFO} ${YELLOW}Keine Instanzen gefunden${NC}"
fi

echo ""
echo -e "${CYAN}🔧 Schnelle Aktionen:${NC}"
echo -e "   Dashboard öffnen: ${YELLOW}open http://localhost:3000${NC}"
echo -e "   Neue Instanz: ${YELLOW}./redaxo create <name> --auto${NC}"
echo -e "   Alle stoppen: ${YELLOW}./redaxo stop-all${NC}"
echo -e "   Vollständige Diagnose: ${YELLOW}./diagnose.sh${NC}"

echo ""
echo -e "${GREEN}System ist einsatzbereit! 🎉${NC}"
