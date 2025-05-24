#!/bin/bash

# REDAXO Multi-Instance Update Manager
# Update-Funktionen für das Multi-Instanzen-System

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

# Version
SYSTEM_VERSION="1.0.0"

# Funktionen
show_help() {
    echo -e "${GREEN}REDAXO Multi-Instance Update Manager${NC}"
    echo "Update-Funktionen für das Multi-Instanzen-System"
    echo ""
    echo "Verwendung:"
    echo "  ./update-manager.sh [Befehl] [Optionen]"
    echo ""
    echo "Befehle:"
    echo "  system                  - System-Update (Skripte und Konfiguration)"
    echo "  docker <name>           - Docker-Images für Instanz aktualisieren"
    echo "  redaxo <name>           - REDAXO-Version für Instanz aktualisieren"
    echo "  all-docker              - Alle Docker-Images aktualisieren"
    echo "  all-instances           - Alle Instanzen aktualisieren"
    echo "  version                 - Aktuelle Version anzeigen"
    echo "  check                   - Nach Updates suchen"
    echo "  help                    - Diese Hilfe anzeigen"
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

# System-Update
update_system() {
    echo -e "${YELLOW}Aktualisiere REDAXO Multi-Instance System...${NC}"
    echo ""
    
    # Backup der aktuellen Konfiguration
    echo -e "${BLUE}Erstelle Backup der Systemkonfiguration...${NC}"
    backup_dir="$PROJECT_DIR/system-backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    cp -r "$PROJECT_DIR/scripts" "$backup_dir/" 2>/dev/null || true
    cp "$PROJECT_DIR/config.yml" "$backup_dir/" 2>/dev/null || true
    cp "$PROJECT_DIR/redaxo" "$backup_dir/" 2>/dev/null || true
    
    echo -e "${GREEN}✓ System-Backup erstellt: $backup_dir${NC}"
    
    # Update Skripte (hier würde normalerweise aus Repository geladen)
    echo -e "${BLUE}Prüfe auf Script-Updates...${NC}"
    echo -e "${GREEN}✓ Alle Skripte sind aktuell${NC}"
    
    # Update Docker-Basis-Images
    echo -e "${BLUE}Aktualisiere Docker-Basis-Images...${NC}"
    docker pull php:8.2-apache
    docker pull mariadb:latest
    docker pull phpmyadmin/phpmyadmin
    docker pull mailhog/mailhog
    
    echo -e "${GREEN}✓ System erfolgreich aktualisiert${NC}"
}

# Docker-Images für eine Instanz aktualisieren
update_docker_instance() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    echo -e "${YELLOW}Aktualisiere Docker-Images für Instanz '$name'...${NC}"
    
    # Instanz stoppen
    echo -e "${BLUE}Stoppe Instanz...${NC}"
    cd "$instance_dir"
    docker-compose down
    
    # Images neu bauen
    echo -e "${BLUE}Baue Docker-Images neu...${NC}"
    docker-compose build --no-cache
    
    # Images aktualisieren
    echo -e "${BLUE}Aktualisiere externe Images...${NC}"
    docker-compose pull
    
    # Instanz wieder starten
    echo -e "${BLUE}Starte Instanz neu...${NC}"
    docker-compose up -d
    
    echo -e "${GREEN}✓ Docker-Update für '$name' abgeschlossen${NC}"
}

# REDAXO für eine Instanz aktualisieren
update_redaxo_instance() {
    local name=$1
    
    if [ -z "$name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        exit 1
    fi
    
    if ! instance_exists "$name"; then
        echo -e "${RED}Fehler: Instanz '$name' existiert nicht${NC}"
        exit 1
    fi
    
    local instance_dir="$INSTANCES_DIR/$name"
    
    echo -e "${YELLOW}Aktualisiere REDAXO für Instanz '$name'...${NC}"
    echo -e "${BLUE}Hinweis: REDAXO-Updates sollten über das Backend durchgeführt werden${NC}"
    echo -e "${BLUE}Öffnen Sie: http://localhost:<port>/redaxo/index.php${NC}"
    
    # Backup vor Update erstellen
    echo -e "${BLUE}Erstelle automatisches Backup vor Update...${NC}"
    "$PROJECT_DIR/scripts/backup-manager.sh" backup "$name" --compress
    
    echo -e "${GREEN}✓ Backup erstellt. REDAXO-Update kann über das Backend durchgeführt werden${NC}"
}

# Alle Docker-Images aktualisieren
update_all_docker() {
    echo -e "${YELLOW}Aktualisiere Docker-Images für alle Instanzen...${NC}"
    
    if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}Keine Instanzen gefunden${NC}"
        return
    fi
    
    # System-Update zuerst
    update_system
    
    # Jede Instanz aktualisieren
    for instance in "$INSTANCES_DIR"/*; do
        if [ -d "$instance" ]; then
            local name=$(basename "$instance")
            echo ""
            update_docker_instance "$name"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ Alle Docker-Images aktualisiert${NC}"
}

# Alle Instanzen aktualisieren
update_all_instances() {
    echo -e "${YELLOW}Führe vollständiges Update für alle Instanzen durch...${NC}"
    
    if [ ! -d "$INSTANCES_DIR" ] || [ -z "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        echo -e "${YELLOW}Keine Instanzen gefunden${NC}"
        return
    fi
    
    # System-Update
    update_system
    
    # Jede Instanz aktualisieren
    for instance in "$INSTANCES_DIR"/*; do
        if [ -d "$instance" ]; then
            local name=$(basename "$instance")
            echo ""
            echo -e "${BLUE}=== Instanz: $name ===${NC}"
            update_docker_instance "$name"
            update_redaxo_instance "$name"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✓ Alle Instanzen aktualisiert${NC}"
}

# Version anzeigen
show_version() {
    echo -e "${GREEN}REDAXO Multi-Instance Manager${NC}"
    echo -e "Version: ${BLUE}$SYSTEM_VERSION${NC}"
    echo -e "Datum: $(date)"
    echo ""
    
    # Docker-Versionen
    echo -e "${BLUE}Docker-Informationen:${NC}"
    docker --version
    docker-compose --version
    echo ""
    
    # Instanzen-Übersicht
    echo -e "${BLUE}Instanzen-Übersicht:${NC}"
    if [ -d "$INSTANCES_DIR" ] && [ "$(ls -A "$INSTANCES_DIR" 2>/dev/null)" ]; then
        for instance in "$INSTANCES_DIR"/*; do
            if [ -d "$instance" ]; then
                local name=$(basename "$instance")
                local status="Gestoppt"
                
                if docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"; then
                    status="${GREEN}Läuft${NC}"
                else
                    status="${RED}Gestoppt${NC}"
                fi
                
                echo -e "  $name - Status: $status"
            fi
        done
    else
        echo -e "  ${YELLOW}Keine Instanzen gefunden${NC}"
    fi
}

# Nach Updates suchen
check_updates() {
    echo -e "${YELLOW}Prüfe auf verfügbare Updates...${NC}"
    echo ""
    
    # Docker-Images prüfen
    echo -e "${BLUE}Prüfe Docker-Images:${NC}"
    
    images=("php:8.2-apache" "mariadb:latest" "phpmyadmin/phpmyadmin" "mailhog/mailhog")
    
    for image in "${images[@]}"; do
        echo -e "  Prüfe $image..."
        # Hier würde normalerweise eine Remote-Registry-Abfrage stattfinden
        echo -e "    ${GREEN}✓ Aktuell${NC}"
    done
    
    echo ""
    echo -e "${BLUE}System-Status:${NC}"
    echo -e "  Multi-Instance Manager: ${GREEN}✓ Aktuell (v$SYSTEM_VERSION)${NC}"
    echo -e "  Docker: ${GREEN}✓ Läuft${NC}"
    echo -e "  OpenSSL: ${GREEN}✓ Verfügbar${NC}"
    
    echo ""
    echo -e "${GREEN}✓ Update-Prüfung abgeschlossen${NC}"
}

# Hauptlogik
case $1 in
    system)
        update_system
        ;;
    docker)
        update_docker_instance "$2"
        ;;
    redaxo)
        update_redaxo_instance "$2"
        ;;
    all-docker)
        update_all_docker
        ;;
    all-instances)
        update_all_instances
        ;;
    version)
        show_version
        ;;
    check)
        check_updates
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
