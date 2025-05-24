#!/bin/bash

# REDAXO Multi-Instance Setup by skerbis
# Initiale Einrichtung des Multi-Instanzen-Systems

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  REDAXO Multi-Instance Setup${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""

# Prüfe Systemvoraussetzungen
echo -e "${YELLOW}Prüfe Systemvoraussetzungen...${NC}"

# Docker prüfen
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Fehler: Docker ist nicht installiert${NC}"
    echo "Bitte installieren Sie Docker von: https://www.docker.com/get-started"
    exit 1
fi

# Docker Compose prüfen
if ! command -v docker-compose &> /dev/null; then
    echo -e "${RED}Fehler: Docker Compose ist nicht installiert${NC}"
    echo "Bitte installieren Sie Docker Compose"
    exit 1
fi

# OpenSSL prüfen
if ! command -v openssl &> /dev/null; then
    echo -e "${RED}Fehler: OpenSSL ist nicht installiert${NC}"
    echo "Bitte installieren Sie OpenSSL für SSL-Zertifikat-Generierung"
    exit 1
fi

echo -e "${GREEN}✓ Alle Systemvoraussetzungen erfüllt${NC}"
echo ""

# Erstelle notwendige Verzeichnisse
echo -e "${YELLOW}Erstelle Verzeichnisstruktur...${NC}"

mkdir -p "$PROJECT_DIR/instances"
mkdir -p "$PROJECT_DIR/ssl"
mkdir -p "$PROJECT_DIR/backups"
mkdir -p "$PROJECT_DIR/logs"

echo -e "${GREEN}✓ Verzeichnisstruktur erstellt${NC}"
echo ""

# Verschiebe app-Ordner als Template
# App-Ordner wird nicht mehr benötigt (GitHub-Download verfügbar)
if [ -d "$PROJECT_DIR/app" ]; then
    echo -e "${YELLOW}Entferne veralteten app-Ordner...${NC}"
    rm -rf "$PROJECT_DIR/app"
    echo -e "${GREEN}✓ App-Ordner entfernt (GitHub-Download wird verwendet)${NC}"
fi
echo ""

# Erstelle Standard .gitignore
echo -e "${YELLOW}Erstelle .gitignore...${NC}"
cat > "$PROJECT_DIR/.gitignore" << 'EOF'
# Instance-spezifische Dateien
instances/*/
ssl/*/
backups/

# Logs
logs/
*.log

# macOS
.DS_Store

# Environment files
.env.local

# Temporäre Dateien
temp/
tmp/
EOF

echo -e "${GREEN}✓ .gitignore erstellt${NC}"
echo ""

# Erstelle Haupt-Konfigurationsdatei
echo -e "${YELLOW}Erstelle Hauptkonfiguration...${NC}"
cat > "$PROJECT_DIR/config.yml" << 'EOF'
# REDAXO Multi-Instance Configuration
version: "1.0"

# Standard-Ports für neue Instanzen
default_ports:
  http_start: 8080
  https_start: 8443
  phpmyadmin_start: 8180
  mailhog_start: 8280

# SSL-Konfiguration
ssl:
  enabled: true
  country: "DE"
  state: "Germany"
  city: "City"
  organization: "Organization"
  validity_days: 365

# Backup-Konfiguration
backup:
  retention_days: 30
  compress: true
  include_database: true

# Docker-Images
docker_images:
  php: "php:8.2-apache"
  mariadb: "mariadb:latest"
  phpmyadmin: "phpmyadmin/phpmyadmin"
  mailhog: "mailhog/mailhog"

# REDAXO-Konfiguration
redaxo:
  version: "latest"
  timezone: "Europe/Berlin"
  memory_limit: "256M"
  upload_max_filesize: "32M"
EOF

echo -e "${GREEN}✓ Hauptkonfiguration erstellt${NC}"
echo ""

# Erstelle Wrapper-Skript für einfache Nutzung
echo -e "${YELLOW}Erstelle Wrapper-Skript...${NC}"
cat > "$PROJECT_DIR/redaxo" << 'EOF'
#!/bin/bash

# REDAXO Multi-Instance Wrapper
# Einfacher Zugang zu allen Funktionen

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

show_help() {
    echo -e "${GREEN}REDAXO Multi-Instance Manager${NC}"
    echo "Einfache Verwaltung von REDAXO-Instanzen"
    echo ""
    echo "Verwendung:"
    echo "  ./redaxo [Befehl] [Optionen]"
    echo ""
    echo "Instance-Management:"
    echo "  create <name>           - Neue Instanz erstellen"
    echo "  start <name>            - Instanz starten"
    echo "  stop <name>             - Instanz stoppen"
    echo "  restart <name>          - Instanz neustarten"
    echo "  remove <name>           - Instanz löschen"
    echo "  list                    - Alle Instanzen auflisten"
    echo "  status [name]           - Status anzeigen"
    echo ""
    echo "Backup & Restore:"
    echo "  backup <name>           - Instanz sichern"
    echo "  restore <name> <file>   - Instanz wiederherstellen"
    echo "  backups                 - Alle Backups auflisten"
    echo ""
    echo "Tools:"
    echo "  logs <name>             - Logs anzeigen"
    echo "  shell <name>            - Shell öffnen"
    echo "  ssl <name>              - SSL-Zertifikat erneuern"
    echo "  cleanup [days]          - Alte Backups löschen"
    echo ""
    echo "System:"
    echo "  setup                   - System einrichten (bereits ausgeführt)"
    echo "  update                  - System aktualisieren"
    echo "  help                    - Diese Hilfe anzeigen"
}

case $1 in
    # Instance Management
    create|start|stop|restart|remove|list|status|logs|shell|ssl)
        "$SCRIPT_DIR/scripts/instance-manager.sh" "$@"
        ;;
    
    # Backup Management
    backup|restore|backups)
        if [ "$1" = "backups" ]; then
            "$SCRIPT_DIR/scripts/backup-manager.sh" list-backups
        else
            "$SCRIPT_DIR/scripts/backup-manager.sh" "$@"
        fi
        ;;
    
    # Tools
    cleanup)
        "$SCRIPT_DIR/scripts/backup-manager.sh" cleanup "$2"
        ;;
    
    # System
    setup)
        echo -e "${GREEN}Setup bereits abgeschlossen!${NC}"
        echo -e "${BLUE}Verwenden Sie './redaxo create <name>' um eine neue Instanz zu erstellen${NC}"
        ;;
    
    update)
        echo -e "${YELLOW}Update-Funktion wird implementiert...${NC}"
        ;;
    
    help|--help|-h|"")
        show_help
        ;;
    
    *)
        echo -e "${RED}Unbekannter Befehl: $1${NC}"
        echo ""
        show_help
        exit 1
        ;;
esac
EOF

chmod +x "$PROJECT_DIR/redaxo"
echo -e "${GREEN}✓ Wrapper-Skript erstellt${NC}"
echo ""

# Erstelle Logging-Konfiguration
echo -e "${YELLOW}Erstelle Logging-Konfiguration...${NC}"
cat > "$PROJECT_DIR/scripts/logger.sh" << 'EOF'
#!/bin/bash

# Logging-Funktionen für REDAXO Multi-Instance Manager

LOG_DIR="$(dirname "$(dirname "${BASH_SOURCE[0]}")")/logs"
mkdir -p "$LOG_DIR"

# Log-Level
LOG_LEVEL_DEBUG=0
LOG_LEVEL_INFO=1
LOG_LEVEL_WARN=2
LOG_LEVEL_ERROR=3

# Aktuelle Log-Level (kann über Environment Variable gesetzt werden)
CURRENT_LOG_LEVEL=${REDAXO_LOG_LEVEL:-$LOG_LEVEL_INFO}

# Logging-Funktionen
log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local log_file="$LOG_DIR/redaxo-$(date '+%Y-%m-%d').log"
    
    if [ $level -ge $CURRENT_LOG_LEVEL ]; then
        echo "[$timestamp] [$level] $message" >> "$log_file"
    fi
}

log_debug() {
    log_message "DEBUG" "$1"
}

log_info() {
    log_message "INFO" "$1"
}

log_warn() {
    log_message "WARN" "$1"
}

log_error() {
    log_message "ERROR" "$1"
}

# Rotate logs (behalte nur die letzten 30 Tage)
rotate_logs() {
    find "$LOG_DIR" -name "redaxo-*.log" -type f -mtime +30 -delete
}
EOF

chmod +x "$PROJECT_DIR/scripts/logger.sh"
echo -e "${GREEN}✓ Logging-Konfiguration erstellt${NC}"
echo ""

# Erstelle Monitoring-Skript
echo -e "${YELLOW}Erstelle Monitoring-Skript...${NC}"
cat > "$PROJECT_DIR/scripts/monitor.sh" << 'EOF'
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
EOF

chmod +x "$PROJECT_DIR/scripts/monitor.sh"
echo -e "${GREEN}✓ Monitoring-Skript erstellt${NC}"
echo ""

# Setup abgeschlossen
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}  Setup erfolgreich abgeschlossen!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${BLUE}Nächste Schritte:${NC}"
echo ""
echo -e "1. Erste Instanz erstellen:"
echo -e "   ${YELLOW}./redaxo create meine-erste-instanz${NC}"
echo ""
echo -e "2. Instanz starten:"
echo -e "   ${YELLOW}./redaxo start meine-erste-instanz${NC}"
echo ""
echo -e "3. Alle verfügbaren Befehle anzeigen:"
echo -e "   ${YELLOW}./redaxo help${NC}"
echo ""
echo -e "4. System-Status überwachen:"
echo -e "   ${YELLOW}./scripts/monitor.sh status${NC}"
echo ""
echo -e "${GREEN}Viel Erfolg mit REDAXO Multi-Instance Manager!${NC}"
