#!/bin/bash

# REDAXO Multi-Instance Manager - Diagnose-Tool
# Hilft bei der Problemdiagnose und zeigt Systemstatus an

set -e

# Farben für Output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Icons
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
GEAR="⚙️"

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  🔍 REDAXO Multi-Instance Manager - Diagnose${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo ""
}

print_section() {
    echo ""
    echo -e "${CYAN}${GEAR} $1${NC}"
    echo -e "${CYAN}────────────────────────────────────────────────────────────────${NC}"
}

print_success() {
    echo -e "${GREEN}${CHECK} $1${NC}"
}

print_error() {
    echo -e "${RED}${CROSS} $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

# Betriebssystem prüfen
check_system() {
    print_section "System-Information"
    
    echo -e "Betriebssystem: ${BLUE}$(uname -s)${NC}"
    echo -e "Architektur: ${BLUE}$(uname -m)${NC}"
    echo -e "macOS Version: ${BLUE}$(sw_vers -productVersion)${NC}"
    echo -e "Kernel: ${BLUE}$(uname -r)${NC}"
    
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_success "macOS erkannt"
    else
        print_error "Nicht-macOS System erkannt - dieses Tool ist für macOS optimiert"
    fi
}

# Homebrew Status
check_homebrew() {
    print_section "Homebrew Status"
    
    if command -v brew >/dev/null 2>&1; then
        brew_version=$(brew --version | head -n1)
        print_success "Homebrew installiert: $brew_version"
        
        # Homebrew Pfad
        brew_path=$(which brew)
        echo -e "Pfad: ${BLUE}$brew_path${NC}"
        
        # Outdated packages
        outdated=$(brew outdated --quiet | wc -l | xargs)
        if [ "$outdated" -gt 0 ]; then
            print_warning "$outdated Pakete können aktualisiert werden"
            echo -e "Aktualisieren mit: ${YELLOW}brew upgrade${NC}"
        else
            print_success "Alle Homebrew-Pakete sind aktuell"
        fi
    else
        print_error "Homebrew nicht gefunden oder nicht im PATH"
        echo -e "Installation: ${YELLOW}/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\"${NC}"
    fi
}

# Docker Status
check_docker() {
    print_section "Docker Status"
    
    if command -v docker >/dev/null 2>&1; then
        docker_version=$(docker --version 2>/dev/null || echo "Fehler beim Abrufen der Version")
        print_success "Docker installiert: $docker_version"
        
        if docker info >/dev/null 2>&1; then
            print_success "Docker läuft und ist erreichbar"
            
            # Docker-Informationen
            containers_running=$(docker ps --format "table {{.Names}}" | tail -n +2 | wc -l | xargs)
            containers_total=$(docker ps -a --format "table {{.Names}}" | tail -n +2 | wc -l | xargs)
            images_count=$(docker images --format "table {{.Repository}}" | tail -n +2 | wc -l | xargs)
            
            echo -e "Laufende Container: ${BLUE}$containers_running${NC}"
            echo -e "Gesamt Container: ${BLUE}$containers_total${NC}"
            echo -e "Images: ${BLUE}$images_count${NC}"
            
            # REDAXO Network prüfen
            if docker network ls | grep -q "redaxo-network"; then
                print_success "Docker-Netzwerk 'redaxo-network' existiert"
            else
                print_warning "Docker-Netzwerk 'redaxo-network' fehlt"
                echo -e "Erstellen mit: ${YELLOW}docker network create redaxo-network${NC}"
            fi
            
            # REDAXO Container prüfen
            redaxo_containers=$(docker ps -a --filter "name=redaxo" --format "table {{.Names}}" | tail -n +2)
            if [ -n "$redaxo_containers" ]; then
                echo ""
                echo -e "${CYAN}REDAXO Container:${NC}"
                echo "$redaxo_containers" | while read container; do
                    if [ -n "$container" ]; then
                        status=$(docker ps --filter "name=$container" --format "{{.Status}}")
                        if [ -n "$status" ]; then
                            print_success "$container (läuft): $status"
                        else
                            status=$(docker ps -a --filter "name=$container" --format "{{.Status}}")
                            print_warning "$container (gestoppt): $status"
                        fi
                    fi
                done
            else
                print_info "Keine REDAXO Container gefunden"
            fi
            
        else
            print_error "Docker ist installiert, aber nicht erreichbar"
            print_info "Starten Sie Docker Desktop oder prüfen Sie den Docker-Daemon"
        fi
    else
        print_error "Docker nicht gefunden"
        echo -e "Installation: ${BLUE}https://www.docker.com/products/docker-desktop/${NC}"
    fi
}

# Node.js und npm Status
check_nodejs() {
    print_section "Node.js Status"
    
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version)
        npm_version=$(npm --version)
        print_success "Node.js installiert: $node_version"
        print_success "npm installiert: $npm_version"
        
        # Version prüfen
        major_version=$(echo $node_version | cut -d'.' -f1 | cut -d'v' -f2)
        if [ "$major_version" -ge 16 ]; then
            print_success "Node.js Version ist ausreichend (benötigt v16+)"
        else
            print_warning "Node.js Version ist zu alt (benötigt v16+)"
            echo -e "Aktualisieren mit: ${YELLOW}brew upgrade node${NC}"
        fi
        
        # npm Pfad
        npm_path=$(which npm)
        node_path=$(which node)
        echo -e "Node.js Pfad: ${BLUE}$node_path${NC}"
        echo -e "npm Pfad: ${BLUE}$npm_path${NC}"
        
    else
        print_error "Node.js nicht gefunden"
        echo -e "Installation: ${YELLOW}brew install node${NC}"
    fi
}

# Git Status
check_git() {
    print_section "Git Status"
    
    if command -v git >/dev/null 2>&1; then
        git_version=$(git --version)
        print_success "Git installiert: $git_version"
        
        git_path=$(which git)
        echo -e "Pfad: ${BLUE}$git_path${NC}"
    else
        print_error "Git nicht gefunden"
        echo -e "Installation: ${YELLOW}brew install git${NC}"
    fi
}

# Dashboard Status
check_dashboard() {
    print_section "Dashboard Status"
    
    cd "$(dirname "$0")"
    
    # Dashboard-Verzeichnis prüfen
    if [ -d "dashboard" ]; then
        print_success "Dashboard-Verzeichnis gefunden"
        
        cd dashboard
        
        # package.json prüfen
        if [ -f "package.json" ]; then
            print_success "package.json gefunden"
            
            # Dependencies prüfen
            if [ -d "node_modules" ]; then
                print_success "node_modules gefunden"
                
                # Wichtige Pakete prüfen
                if [ -d "node_modules/express" ]; then
                    print_success "Express.js installiert"
                else
                    print_error "Express.js fehlt"
                fi
                
                if [ -d "node_modules/socket.io" ]; then
                    print_success "Socket.IO installiert"
                else
                    print_error "Socket.IO fehlt"
                fi
                
                if [ -d "node_modules/puppeteer" ]; then
                    print_success "Puppeteer installiert"
                else
                    print_error "Puppeteer fehlt"
                fi
                
            else
                print_error "node_modules fehlt"
                echo -e "Installieren mit: ${YELLOW}cd dashboard && npm install${NC}"
            fi
            
        else
            print_error "package.json fehlt im Dashboard-Verzeichnis"
        fi
        
        # Server-Datei prüfen
        if [ -f "server.js" ]; then
            print_success "server.js gefunden"
        else
            print_error "server.js fehlt"
        fi
        
        # Frontend-Dateien prüfen
        if [ -f "public/index.html" ]; then
            print_success "Frontend-Dateien gefunden"
        else
            print_error "Frontend-Dateien fehlen"
        fi
        
        # Screenshots-Verzeichnis prüfen
        if [ -d "public/screenshots" ]; then
            screenshot_count=$(ls -1 public/screenshots/*.png 2>/dev/null | wc -l | xargs)
            print_success "Screenshots-Verzeichnis gefunden ($screenshot_count Screenshots)"
        else
            print_warning "Screenshots-Verzeichnis fehlt"
            echo -e "Erstellen mit: ${YELLOW}mkdir -p dashboard/public/screenshots${NC}"
        fi
        
        cd ..
        
    else
        print_error "Dashboard-Verzeichnis nicht gefunden"
    fi
    
    # Dashboard-Prozess prüfen
    if pgrep -f "node.*server.js" >/dev/null; then
        dashboard_pid=$(pgrep -f "node.*server.js")
        print_success "Dashboard läuft (PID: $dashboard_pid)"
        
        # Port-Check
        if lsof -i :3000 >/dev/null 2>&1; then
            print_success "Port 3000 ist belegt (Dashboard läuft wahrscheinlich)"
            
            # HTTP-Check
            if curl -s http://localhost:3000 >/dev/null 2>&1; then
                print_success "Dashboard antwortet auf http://localhost:3000"
            else
                print_warning "Port 3000 belegt, aber Dashboard antwortet nicht"
            fi
        else
            print_warning "Dashboard-Prozess läuft, aber Port 3000 ist nicht belegt"
        fi
    else
        print_info "Dashboard läuft nicht"
        
        if lsof -i :3000 >/dev/null 2>&1; then
            port_process=$(lsof -i :3000 | tail -n +2)
            print_warning "Port 3000 ist von einem anderen Prozess belegt:"
            echo "$port_process"
        fi
    fi
}

# REDAXO Instanzen prüfen
check_instances() {
    print_section "REDAXO Instanzen"
    
    cd "$(dirname "$0")"
    
    if [ -d "instances" ]; then
        instance_count=$(find instances -maxdepth 1 -type d | tail -n +2 | wc -l | xargs)
        print_success "Instanzen-Verzeichnis gefunden ($instance_count Instanzen)"
        
        if [ $instance_count -gt 0 ]; then
            echo ""
            echo -e "${CYAN}Gefundene Instanzen:${NC}"
            
            for instance_dir in instances/*/; do
                if [ -d "$instance_dir" ]; then
                    instance_name=$(basename "$instance_dir")
                    echo -e "  📁 ${BLUE}$instance_name${NC}"
                    
                    # Docker-Compose prüfen
                    if [ -f "$instance_dir/docker-compose.yml" ]; then
                        echo -e "     ✓ docker-compose.yml"
                    else
                        echo -e "     ${RED}✗ docker-compose.yml fehlt${NC}"
                    fi
                    
                    # REDAXO-Verzeichnis prüfen
                    if [ -d "$instance_dir/app" ]; then
                        echo -e "     ✓ app-Verzeichnis"
                    else
                        echo -e "     ${RED}✗ app-Verzeichnis fehlt${NC}"
                    fi
                    
                    # Container-Status prüfen
                    if docker ps --filter "name=redaxo-$instance_name" --format "{{.Names}}" | grep -q "redaxo-$instance_name"; then
                        echo -e "     ${GREEN}✓ Container läuft${NC}"
                    elif docker ps -a --filter "name=redaxo-$instance_name" --format "{{.Names}}" | grep -q "redaxo-$instance_name"; then
                        echo -e "     ${YELLOW}⚠ Container gestoppt${NC}"
                    else
                        echo -e "     ${RED}✗ Container nicht gefunden${NC}"
                    fi
                fi
            done
        fi
    else
        print_info "Instanzen-Verzeichnis nicht gefunden"
        echo -e "Erstellen mit: ${YELLOW}mkdir instances${NC}"
    fi
}

# Ports prüfen
check_ports() {
    print_section "Port-Status"
    
    # Wichtige Ports prüfen
    ports=(3000 3001 3002 3003 3004 3005 3306 3307 3308 3309 3310)
    
    echo -e "${CYAN}Port-Belegung:${NC}"
    for port in "${ports[@]}"; do
        if lsof -i :$port >/dev/null 2>&1; then
            process=$(lsof -i :$port | tail -n +2 | awk '{print $1, $2}' | head -n1)
            echo -e "  Port $port: ${RED}belegt${NC} ($process)"
        else
            echo -e "  Port $port: ${GREEN}frei${NC}"
        fi
    done
}

# Netzwerk prüfen
check_network() {
    print_section "Netzwerk-Status"
    
    # Internet-Verbindung
    if ping -c 1 google.com >/dev/null 2>&1; then
        print_success "Internet-Verbindung verfügbar"
    else
        print_error "Keine Internet-Verbindung"
    fi
    
    # Docker Hub erreichbar
    if curl -s https://hub.docker.com >/dev/null 2>&1; then
        print_success "Docker Hub erreichbar"
    else
        print_warning "Docker Hub nicht erreichbar"
    fi
    
    # localhost erreichbar
    if curl -s http://localhost:3000 >/dev/null 2>&1; then
        print_success "localhost:3000 erreichbar"
    else
        print_info "localhost:3000 nicht erreichbar (Dashboard läuft nicht)"
    fi
}

# Log-Dateien prüfen
check_logs() {
    print_section "Log-Dateien"
    
    cd "$(dirname "$0")"
    
    # Dashboard-Log
    if [ -f "dashboard.log" ]; then
        log_size=$(du -h dashboard.log | cut -f1)
        log_lines=$(wc -l < dashboard.log)
        print_success "Dashboard-Log gefunden ($log_size, $log_lines Zeilen)"
        
        # Letzte Fehler zeigen
        if grep -i "error\|fehler" dashboard.log >/dev/null 2>&1; then
            echo -e "   ${YELLOW}Letzte Fehler:${NC}"
            tail -n 5 dashboard.log | grep -i "error\|fehler" | head -n 3 || true
        fi
    else
        print_info "Keine Dashboard-Log-Datei gefunden"
    fi
    
    # Docker Logs für REDAXO Container
    if command -v docker >/dev/null 2>&1; then
        redaxo_containers=$(docker ps -a --filter "name=redaxo" --format "{{.Names}}" | head -n 3)
        if [ -n "$redaxo_containers" ]; then
            echo ""
            echo -e "${CYAN}Docker Container Logs (letzte 5 Zeilen):${NC}"
            echo "$redaxo_containers" | while read container; do
                if [ -n "$container" ]; then
                    echo -e "  ${BLUE}$container:${NC}"
                    docker logs --tail 5 "$container" 2>&1 | sed 's/^/    /' || true
                fi
            done
        fi
    fi
}

# Zusammenfassung und Empfehlungen
show_summary() {
    print_section "Zusammenfassung und Empfehlungen"
    
    echo -e "${CYAN}Status-Übersicht:${NC}"
    
    # Kritische Komponenten
    local critical_ok=true
    
    if ! command -v docker >/dev/null 2>&1 || ! docker info >/dev/null 2>&1; then
        print_error "Docker nicht verfügbar - kritisch für REDAXO-Instanzen"
        critical_ok=false
    fi
    
    if ! command -v node >/dev/null 2>&1; then
        print_error "Node.js nicht verfügbar - kritisch für Dashboard"
        critical_ok=false
    fi
    
    if [ ! -d "dashboard" ] || [ ! -f "dashboard/server.js" ]; then
        print_error "Dashboard nicht vollständig - Setup erforderlich"
        critical_ok=false
    fi
    
    if $critical_ok; then
        print_success "Alle kritischen Komponenten sind verfügbar"
    else
        echo ""
        print_warning "Empfohlene Aktion: Setup-Script ausführen"
        echo -e "   ${YELLOW}./setup.sh${NC}"
    fi
    
    echo ""
    echo -e "${CYAN}Nützliche Befehle:${NC}"
    echo -e "   Dashboard starten: ${YELLOW}./dashboard-start${NC}"
    echo -e "   REDAXO-Instanz erstellen: ${YELLOW}./redaxo create <name>${NC}"
    echo -e "   Alle Container anzeigen: ${YELLOW}docker ps -a${NC}"
    echo -e "   Setup neu ausführen: ${YELLOW}./setup.sh${NC}"
    echo -e "   Diese Diagnose: ${YELLOW}./diagnose.sh${NC}"
}

# Hauptprogramm
main() {
    print_header
    
    check_system
    check_homebrew
    check_docker
    check_nodejs
    check_git
    check_dashboard
    check_instances
    check_ports
    check_network
    check_logs
    show_summary
    
    echo ""
    echo -e "${GREEN}Diagnose abgeschlossen! 🔍${NC}"
}

# Script ausführen
main "$@"
