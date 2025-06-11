#!/bin/bash

# REDAXO Multi-Instance Manager - Wartung & Cleanup
# Bereinigt das System und führt Wartungsaufgaben durch

# Farben
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Icons
CHECK="✅"
CROSS="❌"
WARNING="⚠️"
INFO="ℹ️"
GEAR="⚙️"

print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  ${GEAR} REDAXO Multi-Instance Manager - Wartung${NC}"
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

print_warning() {
    echo -e "${YELLOW}${WARNING} $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

# Docker Cleanup
docker_cleanup() {
    print_section "Docker-System bereinigen"
    
    # Gestoppte Container entfernen
    stopped_containers=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | wc -l | xargs)
    if [ "$stopped_containers" -gt 0 ]; then
        print_warning "$stopped_containers gestoppte Container gefunden"
        docker container prune -f >/dev/null 2>&1
        print_success "Gestoppte Container entfernt"
    else
        print_success "Keine gestoppten Container gefunden"
    fi
    
    # Ungenutzte Images entfernen
    dangling_images=$(docker images -f "dangling=true" -q | wc -l | xargs)
    if [ "$dangling_images" -gt 0 ]; then
        print_warning "$dangling_images ungenutzte Images gefunden"
        docker image prune -f >/dev/null 2>&1
        print_success "Ungenutzte Images entfernt"
    else
        print_success "Keine ungenutzten Images gefunden"
    fi
    
    # System-weites Cleanup (optional)
    echo ""
    echo -e "${YELLOW}Möchten Sie ein komplettes Docker-System-Cleanup durchführen?${NC}"
    echo -e "${YELLOW}⚠️  Dies entfernt ALLE ungenutzten Volumes und Netzwerke${NC}"
    echo ""
    echo -e "${YELLOW}1)${NC} Ja, alles bereinigen"
    echo -e "${YELLOW}2)${NC} Nein, überspringen"
    echo ""
    
    read -p "Ihre Wahl (1-2): " choice
    
    case $choice in
        1)
            docker system prune -f --volumes >/dev/null 2>&1
            print_success "Komplettes Docker-System bereinigt"
            ;;
        2)
            print_info "System-Cleanup übersprungen"
            ;;
    esac
}

# Dashboard Wartung
dashboard_maintenance() {
    print_section "Dashboard-Wartung"
    
    cd "$(dirname "$0")/dashboard"
    
    # Alte Screenshots bereinigen
    if [ -d "public/screenshots" ]; then
        old_screenshots=$(find public/screenshots -name "*.png" -mtime +7 | wc -l | xargs)
        if [ "$old_screenshots" -gt 0 ]; then
            print_warning "$old_screenshots Screenshots älter als 7 Tage gefunden"
            find public/screenshots -name "*.png" -mtime +7 -delete
            print_success "Alte Screenshots entfernt"
        else
            print_success "Keine alten Screenshots gefunden"
        fi
        
        current_screenshots=$(ls -1 public/screenshots/*.png 2>/dev/null | wc -l | xargs)
        print_info "Aktuelle Screenshots: $current_screenshots"
    fi
    
    # Dashboard-Dependencies prüfen
    if [ -f "package.json" ]; then
        outdated=$(npm outdated --json 2>/dev/null | jq -r 'keys | length' 2>/dev/null || echo "0")
        if [ "$outdated" -gt 0 ]; then
            print_warning "$outdated Dashboard-Pakete können aktualisiert werden"
            echo -e "Aktualisieren mit: ${YELLOW}cd dashboard && npm update${NC}"
        else
            print_success "Alle Dashboard-Pakete sind aktuell"
        fi
    fi
    
    cd ..
}

# Log-Dateien bereinigen
log_cleanup() {
    print_section "Log-Dateien bereinigen"
    
    cd "$(dirname "$0")"
    
    # Dashboard-Logs
    if [ -f "dashboard.log" ]; then
        log_size=$(du -h dashboard.log | cut -f1)
        log_lines=$(wc -l < dashboard.log)
        
        if [ "$log_lines" -gt 1000 ]; then
            print_warning "Dashboard-Log ist groß ($log_lines Zeilen, $log_size)"
            tail -n 500 dashboard.log > dashboard.log.tmp
            mv dashboard.log.tmp dashboard.log
            print_success "Dashboard-Log gekürzt (letzte 500 Zeilen behalten)"
        else
            print_success "Dashboard-Log ist aktuell ($log_lines Zeilen, $log_size)"
        fi
    else
        print_info "Keine Dashboard-Log-Datei gefunden"
    fi
    
    # Docker-Logs bereinigen
    if command -v docker >/dev/null 2>&1; then
        print_info "Docker-Logs werden automatisch rotiert"
        # Optional: Docker log rotation konfigurieren
        # docker system events --filter container=redaxo --since 1h
    fi
}

# Instanzen-Wartung
instances_maintenance() {
    print_section "REDAXO-Instanzen-Wartung"
    
    cd "$(dirname "$0")"
    
    if [ -d "instances" ]; then
        total_instances=$(find instances -maxdepth 1 -type d | tail -n +2 | wc -l | xargs)
        print_info "Gefundene Instanzen: $total_instances"
        
        # Prüfe auf verwaiste Instanzen-Ordner (ohne laufende Container)
        orphaned=0
        for instance_dir in instances/*/; do
            if [ -d "$instance_dir" ]; then
                instance_name=$(basename "$instance_dir")
                
                # Prüfe ob Container existiert
                if ! docker ps -a --filter "name=redaxo-$instance_name" --format "{{.Names}}" | grep -q "redaxo-$instance_name"; then
                    print_warning "Verwaister Instanz-Ordner gefunden: $instance_name"
                    ((orphaned++))
                fi
            fi
        done
        
        if [ $orphaned -gt 0 ]; then
            echo ""
            echo -e "${YELLOW}$orphaned verwaiste Instanz-Ordner gefunden.${NC}"
            echo -e "${YELLOW}Diese können manuell gelöscht werden wenn sie nicht benötigt werden.${NC}"
        else
            print_success "Alle Instanz-Ordner haben entsprechende Container"
        fi
    fi
}

# System-Updates prüfen
check_updates() {
    print_section "System-Updates prüfen"
    
    # Homebrew Updates
    if command -v brew >/dev/null 2>&1; then
        outdated_brew=$(brew outdated --quiet | wc -l | xargs)
        if [ "$outdated_brew" -gt 0 ]; then
            print_warning "$outdated_brew Homebrew-Pakete können aktualisiert werden"
            echo -e "Aktualisieren mit: ${YELLOW}brew upgrade${NC}"
        else
            print_success "Alle Homebrew-Pakete sind aktuell"
        fi
    fi
    
    # Node.js Version
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version | cut -d'v' -f2)
        print_info "Node.js Version: $node_version"
        
        # Prüfe auf LTS-Version (vereinfacht)
        major_version=$(echo $node_version | cut -d'.' -f1)
        if [ "$major_version" -ge 18 ]; then
            print_success "Node.js Version ist aktuell"
        else
            print_warning "Node.js könnte veraltet sein (empfohlen: v18+)"
        fi
    fi
    
    # Docker Version
    if command -v docker >/dev/null 2>&1; then
        docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_info "Docker Version: $docker_version"
        print_success "Docker-Updates werden automatisch über Docker Desktop verwaltet"
    fi
}

# Backup-Empfehlungen
backup_recommendations() {
    print_section "Backup-Empfehlungen"
    
    cd "$(dirname "$0")"
    
    # Prüfe vorhandene Backups
    if [ -d "backups" ]; then
        backup_count=$(find backups -name "*.zip" | wc -l | xargs)
        print_info "Vorhandene Backups: $backup_count"
        
        if [ $backup_count -eq 0 ]; then
            print_warning "Keine Backups gefunden!"
            echo -e "Erstellen Sie Backups mit: ${YELLOW}./redaxo backup <instanz-name>${NC}"
        fi
    else
        print_warning "Backup-Verzeichnis nicht gefunden"
        mkdir -p backups
        print_success "Backup-Verzeichnis erstellt"
    fi
    
    echo ""
    echo -e "${CYAN}💾 Backup-Empfehlungen:${NC}"
    echo -e "   • Regelmäßige REDAXO-Backups: ${YELLOW}./redaxo backup <instanz>${NC}"
    echo -e "   • Dashboard-Konfiguration sichern"
    echo -e "   • Docker-Volumes bei wichtigen Projekten exportieren"
    echo -e "   • SSL-Zertifikate (ssl/-Verzeichnis) sichern"
}

# Zusammenfassung
show_summary() {
    print_section "Wartung abgeschlossen"
    
    echo -e "${GREEN}✅ System-Wartung erfolgreich durchgeführt!${NC}"
    echo ""
    echo -e "${CYAN}📊 Nächste empfohlene Aktionen:${NC}"
    echo -e "   • Status prüfen: ${YELLOW}./status.sh${NC}"
    echo -e "   • Vollständige Diagnose: ${YELLOW}./diagnose.sh${NC}"
    echo -e "   • Dashboard öffnen: ${YELLOW}open http://localhost:3000${NC}"
    echo ""
    echo -e "${CYAN}🔄 Regelmäßige Wartung:${NC}"
    echo -e "   • Dieses Script: ${YELLOW}./maintenance.sh${NC} (empfohlen: wöchentlich)"
    echo -e "   • System-Updates: ${YELLOW}brew upgrade${NC} (empfohlen: monatlich)"
    echo -e "   • REDAXO-Backups: ${YELLOW}./redaxo backup <instanz>${NC} (empfohlen: vor größeren Änderungen)"
}

# Hauptprogramm
main() {
    print_header
    
    docker_cleanup
    dashboard_maintenance
    log_cleanup
    instances_maintenance
    check_updates
    backup_recommendations
    show_summary
    
    echo ""
    echo -e "${GREEN}Wartung abgeschlossen! 🧹${NC}"
}

# Script ausführen
main "$@"
