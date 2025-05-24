#!/bin/bash

# REDAXO Instance Monitor
# Überwacht den Status aller Instanzen

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
INSTANCES_DIR="$PROJECT_DIR/instances"

show_system_status() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}  REDAXO System Status${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    
    # Docker Status
    echo -e "${BLUE}Docker Status:${NC}"
    if docker info >/dev/null 2>&1; then
        echo -e "  ${GREEN}✓ Docker läuft${NC}"
    else
        echo -e "  ${RED}✗ Docker läuft nicht${NC}"
    fi
    echo ""
    
    # Instanzen Status
    echo -e "${BLUE}Instanzen Status:${NC}"
    
    if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        echo -e "  ${YELLOW}Keine Instanzen gefunden${NC}"
        return
    fi
    
    local total_instances=0
    local running_instances=0
    
    for instance in "$INSTANCES_DIR"/*; do
        if [ -d "$instance" ]; then
            local name=$(basename "$instance")
            ((total_instances++))
            
            if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
                echo -e "  ${GREEN}✓ $name${NC}"
                ((running_instances++))
            else
                echo -e "  ${RED}✗ $name${NC}"
            fi
        fi
    done
    
    echo ""
    echo -e "${BLUE}Zusammenfassung:${NC}"
    echo -e "  Gesamt: $total_instances"
    echo -e "  Laufend: ${GREEN}$running_instances${NC}"
    echo -e "  Gestoppt: ${RED}$((total_instances - running_instances))${NC}"
}

# Überwache kontinuierlich
monitor_continuous() {
    while true; do
        clear
        show_system_status
        echo ""
        echo -e "${YELLOW}Drücken Sie Ctrl+C zum Beenden...${NC}"
        sleep 5
    done
}

case $1 in
    status)
        show_system_status
        ;;
    watch)
        monitor_continuous
        ;;
    *)
        echo "Verwendung: $0 {status|watch}"
        exit 1
        ;;
esac
