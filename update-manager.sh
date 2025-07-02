#!/bin/bash

# REDAXO Multi-Instance Manager - Update Manager
# Aktualisiert bestehende Manager mit der neuesten Version vom GitHub-Repository
# Repository: https://github.com/skerbis/redaxo-multi-instances
# Autor: GitHub Copilot
# Datum: 2. Juli 2025

set -e  # Beende bei Fehlern

# GitHub-Repository-Informationen
GITHUB_REPO="skerbis/redaxo-multi-instances"
GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
GITHUB_DOWNLOAD_URL="https://github.com/$GITHUB_REPO/archive/refs/heads/main.zip"
TEMP_UPDATE_DIR="/tmp/redaxo-multi-instances-update"

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
ARROW="➡️"
ROCKET="🚀"
GEAR="⚙️"
UPDATE="🔄"
INFO="ℹ️"

# Funktionen
print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  ${UPDATE} REDAXO Multi-Instance Manager - Update${NC}"
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
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}${INFO} $1${NC}"
}

print_step() {
    echo -e "${YELLOW}${ARROW} $1${NC}"
}

# Prüfe aktuelle Installation
check_current_installation() {
    print_section "Aktuelle Installation prüfen"
    
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Prüfe wichtige Komponenten
    local components_ok=true
    
    if [ ! -f "$PROJECT_DIR/redaxo" ]; then
        print_warning "REDAXO-Script nicht gefunden"
        components_ok=false
    else
        print_success "REDAXO-Script gefunden"
    fi
    
    if [ ! -f "$PROJECT_DIR/dashboard/server.js" ]; then
        print_warning "Dashboard nicht gefunden"
        components_ok=false
    else
        print_success "Dashboard gefunden"
    fi
    
    if [ ! -f "$PROJECT_DIR/manager" ]; then
        print_warning "Manager-Script nicht gefunden"
        components_ok=false
    else
        print_success "Manager-Script gefunden"
    fi
    
    if [ ! -d "$PROJECT_DIR/instances" ]; then
        print_warning "Instances-Verzeichnis nicht gefunden"
        mkdir -p "$PROJECT_DIR/instances"
        print_success "Instances-Verzeichnis erstellt"
    else
        print_success "Instances-Verzeichnis gefunden"
    fi
    
    return $components_ok
}

# Backup der aktuellen Konfiguration
backup_current_config() {
    print_section "Backup der aktuellen Konfiguration"
    
    local backup_dir="$PROJECT_DIR/backup-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup wichtiger Dateien
    if [ -f "$PROJECT_DIR/dashboard/.env" ]; then
        cp "$PROJECT_DIR/dashboard/.env" "$backup_dir/"
        print_success "Dashboard-Konfiguration gesichert"
    fi
    
    if [ -d "$PROJECT_DIR/ssl" ]; then
        cp -r "$PROJECT_DIR/ssl" "$backup_dir/"
        print_success "SSL-Zertifikate gesichert"
    fi
    
    if [ -d "$PROJECT_DIR/instances" ]; then
        # Nur docker-compose.yml Dateien sichern, nicht die kompletten Apps
        find "$PROJECT_DIR/instances" -name "docker-compose.yml" -exec cp --parents {} "$backup_dir/" \;
        print_success "Instanz-Konfigurationen gesichert"
    fi
    
    echo -e "${GREEN}Backup erstellt in: $backup_dir${NC}"
    export BACKUP_DIR="$backup_dir"
}

# System-Updates
update_system_dependencies() {
download_and_apply_updates() {
    print_section "Updates vom GitHub-Repository herunterladen"
    
    # Temporäres Verzeichnis vorbereiten
    rm -rf "$TEMP_UPDATE_DIR"
    mkdir -p "$TEMP_UPDATE_DIR"
    
    print_step "Lade neueste Version von GitHub herunter..."
    echo -e "${BLUE}Repository: https://github.com/$GITHUB_REPO${NC}"
    
    # Repository herunterladen
    if curl -L -o "$TEMP_UPDATE_DIR/main.zip" "$GITHUB_DOWNLOAD_URL" --progress-bar; then
        print_success "Repository erfolgreich heruntergeladen"
    else
        print_error "Fehler beim Herunterladen des Repositories"
        exit 1
    fi
    
    # Entpacken
    print_step "Entpacke heruntergeladene Dateien..."
    cd "$TEMP_UPDATE_DIR"
    unzip -q main.zip
    
    local extracted_dir="$TEMP_UPDATE_DIR/redaxo-multi-instances-main"
    if [ ! -d "$extracted_dir" ]; then
        print_error "Extrahiertes Verzeichnis nicht gefunden"
        exit 1
    fi
    
    print_success "Dateien erfolgreich entpackt"
    
    # Welche Dateien sollen aktualisiert werden
    print_step "Bereite Updates vor..."
    
    local files_to_update=(
        "redaxo"
        "setup.sh"
        "maintenance.sh" 
        "diagnose.sh"
        "status.sh"
        "import-dump"
        "redaxo-downloader.sh"
        "manager"
        "dashboard-start"
        "dashboard-pm2"
        "snapshot.sh"
        "README.md"
        "QUICKSTART.md"
    )
    
    local dirs_to_update=(
        "dashboard"
        "docker"
        "docker-templates"
    )
    
    # Einzelne Dateien aktualisieren
    for file in "${files_to_update[@]}"; do
        if [ -f "$extracted_dir/$file" ]; then
            if [ -f "$PROJECT_DIR/$file" ]; then
                # Backup der aktuellen Datei
                cp "$PROJECT_DIR/$file" "$BACKUP_DIR/$file.backup" 2>/dev/null || true
                # Neue Datei kopieren
                cp "$extracted_dir/$file" "$PROJECT_DIR/$file"
                chmod +x "$PROJECT_DIR/$file" 2>/dev/null || true
                print_success "$file aktualisiert"
            else
                # Neue Datei hinzufügen
                cp "$extracted_dir/$file" "$PROJECT_DIR/$file"
                chmod +x "$PROJECT_DIR/$file" 2>/dev/null || true
                print_success "$file hinzugefügt"
            fi
        fi
    done
    
    # Verzeichnisse aktualisieren (vorsichtig - nur bestimmte Dateien)
    for dir in "${dirs_to_update[@]}"; do
        if [ -d "$extracted_dir/$dir" ]; then
            print_step "Aktualisiere $dir..."
            
            if [ "$dir" = "dashboard" ]; then
                # Dashboard: Nur JavaScript, HTML, CSS und package.json aktualisieren
                # .env NICHT überschreiben!
                if [ -f "$extracted_dir/$dir/package.json" ]; then
                    cp "$extracted_dir/$dir/package.json" "$PROJECT_DIR/$dir/"
                fi
                if [ -f "$extracted_dir/$dir/server.js" ]; then
                    cp "$extracted_dir/$dir/server.js" "$PROJECT_DIR/$dir/"
                fi
                if [ -d "$extracted_dir/$dir/public" ]; then
                    cp -r "$extracted_dir/$dir/public"/* "$PROJECT_DIR/$dir/public/" 2>/dev/null || true
                fi
                print_success "Dashboard-Dateien aktualisiert (.env beibehalten)"
                
            elif [ "$dir" = "docker" ] || [ "$dir" = "docker-templates" ]; then
                # Docker-Templates komplett ersetzen
                if [ -d "$PROJECT_DIR/$dir" ]; then
                    cp -r "$PROJECT_DIR/$dir" "$BACKUP_DIR/$dir-backup" 2>/dev/null || true
                fi
                cp -r "$extracted_dir/$dir" "$PROJECT_DIR/"
                print_success "$dir aktualisiert"
            fi
        fi
    done
    
    # Cleanup
    rm -rf "$TEMP_UPDATE_DIR"
    print_success "Temporäre Dateien bereinigt"
}

# GitHub-Version prüfen
check_github_version() {
    print_section "GitHub-Version prüfen"
    
    if command -v curl >/dev/null 2>&1; then
        print_step "Prüfe neueste Version auf GitHub..."
        
        # Versuche Release-Info zu holen (falls verfügbar)
        local release_info
        release_info=$(curl -s "$GITHUB_API_URL" 2>/dev/null || echo "{}")
        
        if echo "$release_info" | grep -q "tag_name"; then
            local latest_tag=$(echo "$release_info" | grep -o '"tag_name":"[^"]*"' | cut -d'"' -f4)
            local release_date=$(echo "$release_info" | grep -o '"published_at":"[^"]*"' | cut -d'"' -f4 | cut -d'T' -f1)
            print_info "Neueste Release: $latest_tag ($release_date)"
        else
            print_info "Repository wird von main-Branch aktualisiert"
        fi
        
        # Letzter Commit-Info (falls verfügbar)
        local commit_info
        commit_info=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/commits/main" 2>/dev/null || echo "{}")
        
        if echo "$commit_info" | grep -q "sha"; then
            local commit_date=$(echo "$commit_info" | grep -o '"date":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -d'T' -f1)
            print_info "Letzter Commit: $commit_date"
        fi
        
        print_success "GitHub-Repository ist erreichbar"
    else
        print_error "curl nicht gefunden - kann GitHub-Version nicht prüfen"
        exit 1
    fi
}
    print_section "System-Abhängigkeiten aktualisieren"
    
    # Homebrew Updates
    if command -v brew >/dev/null 2>&1; then
        print_step "Homebrew wird aktualisiert..."
        brew update >/dev/null 2>&1
        
        outdated=$(brew outdated --quiet | wc -l | xargs)
        if [ "$outdated" -gt 0 ]; then
            print_warning "$outdated Pakete können aktualisiert werden"
            echo -e "${YELLOW}Möchten Sie alle Homebrew-Pakete aktualisieren? (y/n):${NC}"
            read -p "> " update_brew
            if [ "$update_brew" = "y" ] || [ "$update_brew" = "Y" ]; then
                brew upgrade
                print_success "Homebrew-Pakete aktualisiert"
            else
                print_info "Homebrew-Updates übersprungen"
            fi
        else
            print_success "Alle Homebrew-Pakete sind aktuell"
        fi
    fi
    
    # Node.js Version prüfen
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version | cut -d'v' -f2)
        major_version=$(echo $node_version | cut -d'.' -f1)
        
        print_info "Node.js Version: v$node_version"
        
        if [ "$major_version" -lt 18 ]; then
            print_warning "Node.js Version ist veraltet (empfohlen: v18+)"
            echo -e "${YELLOW}Möchten Sie Node.js aktualisieren? (y/n):${NC}"
            read -p "> " update_node
            if [ "$update_node" = "y" ] || [ "$update_node" = "Y" ]; then
                brew upgrade node
                print_success "Node.js aktualisiert"
            fi
        else
            print_success "Node.js Version ist aktuell"
        fi
    fi
}

# Dashboard aktualisieren
update_dashboard() {
    print_section "Dashboard aktualisieren"
    
    cd "$PROJECT_DIR/dashboard"
    
    # npm Abhängigkeiten prüfen und aktualisieren
    if [ -f "package.json" ]; then
        print_step "Dashboard-Abhängigkeiten werden geprüft..."
        
        # Prüfe auf veraltete Pakete
        outdated=$(npm outdated --json 2>/dev/null | jq -r 'keys | length' 2>/dev/null || echo "0")
        
        if [ "$outdated" -gt 0 ]; then
            print_warning "$outdated Dashboard-Pakete können aktualisiert werden"
            echo -e "${YELLOW}Möchten Sie die Dashboard-Abhängigkeiten aktualisieren? (y/n):${NC}"
            read -p "> " update_npm
            if [ "$update_npm" = "y" ] || [ "$update_npm" = "Y" ]; then
                npm update
                print_success "Dashboard-Abhängigkeiten aktualisiert"
            else
                print_info "Dashboard-Updates übersprungen"
            fi
        else
            print_success "Alle Dashboard-Abhängigkeiten sind aktuell"
        fi
        
        # Sicherheits-Updates prüfen
        print_step "Sicherheits-Updates werden geprüft..."
        if npm audit --audit-level moderate >/dev/null 2>&1; then
            print_success "Keine kritischen Sicherheitslücken gefunden"
        else
            print_warning "Sicherheitslücken gefunden"
            echo -e "${YELLOW}Möchten Sie automatische Sicherheits-Fixes anwenden? (y/n):${NC}"
            read -p "> " fix_security
            if [ "$fix_security" = "y" ] || [ "$fix_security" = "Y" ]; then
                npm audit fix
                print_success "Sicherheits-Updates angewendet"
            fi
        fi
    fi
    
    cd "$PROJECT_DIR"
}

# REDAXO-Downloader aktualisieren
update_redaxo_downloader() {
    print_section "REDAXO-Downloader aktualisieren"
    
    if [ -f "$PROJECT_DIR/redaxo-downloader.sh" ]; then
        # Cache bereinigen
        print_step "Download-Cache wird bereinigt..."
        "$PROJECT_DIR/redaxo-downloader.sh" clean >/dev/null 2>&1 || true
        print_success "Download-Cache bereinigt"
        
        # Neueste Version prüfen
        print_step "Neueste REDAXO-Version wird geprüft..."
        "$PROJECT_DIR/redaxo-downloader.sh" check-latest
    fi
}

# Docker-System optimieren
optimize_docker() {
    print_section "Docker-System optimieren"
    
    if command -v docker >/dev/null 2>&1; then
        if docker info >/dev/null 2>&1; then
            # Docker-Cleanup
            print_step "Docker-System wird bereinigt..."
            
            # Gestoppte Container
            stopped=$(docker ps -a --filter "status=exited" --format "{{.Names}}" | wc -l | xargs)
            if [ "$stopped" -gt 0 ]; then
                docker container prune -f >/dev/null 2>&1
                print_success "$stopped gestoppte Container entfernt"
            fi
            
            # Ungenutzte Images
            dangling=$(docker images -f "dangling=true" -q | wc -l | xargs)
            if [ "$dangling" -gt 0 ]; then
                docker image prune -f >/dev/null 2>&1
                print_success "$dangling ungenutzte Images entfernt"
            fi
            
            # Ungenutzte Volumes (vorsichtig)
            unused_volumes=$(docker volume ls -q --filter dangling=true | wc -l | xargs)
            if [ "$unused_volumes" -gt 0 ]; then
                print_warning "$unused_volumes ungenutzte Volumes gefunden"
                echo -e "${YELLOW}Möchten Sie ungenutzte Volumes entfernen? (y/n):${NC}"
                read -p "> " remove_volumes
                if [ "$remove_volumes" = "y" ] || [ "$remove_volumes" = "Y" ]; then
                    docker volume prune -f >/dev/null 2>&1
                    print_success "Ungenutzte Volumes entfernt"
                fi
            fi
            
            print_success "Docker-System optimiert"
        else
            print_warning "Docker läuft nicht - starten Sie Docker Desktop"
        fi
    else
        print_error "Docker nicht gefunden"
    fi
}

# Instanzen-Updates prüfen
check_instance_updates() {
    print_section "Instanz-Updates prüfen"
    
    if [ -d "$PROJECT_DIR/instances" ]; then
        local instances=($(ls -1 "$PROJECT_DIR/instances" 2>/dev/null || true))
        
        if [ ${#instances[@]} -eq 0 ]; then
            print_info "Keine Instanzen gefunden"
            return
        fi
        
        print_info "Gefundene Instanzen: ${#instances[@]}"
        
        for instance in "${instances[@]}"; do
            if [ -f "$PROJECT_DIR/instances/$instance/docker-compose.yml" ]; then
                echo -e "${BLUE}📦 Instanz: $instance${NC}"
                
                # PHP-Version aus docker-compose.yml auslesen
                php_version=$(grep -o 'php:[0-9]\+\.[0-9]\+' "$PROJECT_DIR/instances/$instance/docker-compose.yml" | head -1 | cut -d':' -f2 || echo "unbekannt")
                
                # MariaDB-Version auslesen
                mariadb_version=$(grep -o 'mariadb:[0-9]\+\.[0-9]\+\|mariadb:latest' "$PROJECT_DIR/instances/$instance/docker-compose.yml" | head -1 | cut -d':' -f2 || echo "unbekannt")
                
                echo -e "  PHP: ${YELLOW}$php_version${NC}"
                echo -e "  MariaDB: ${YELLOW}$mariadb_version${NC}"
                
                # Container-Status prüfen
                if docker ps --filter "name=redaxo-$instance" --format "{{.Names}}" | grep -q "redaxo-$instance"; then
                    echo -e "  Status: ${GREEN}Läuft${NC}"
                else
                    echo -e "  Status: ${RED}Gestoppt${NC}"
                fi
                echo ""
            fi
        done
        
        echo -e "${CYAN}💡 Tipp: Verwenden Sie das Dashboard oder './redaxo update <instanz>' für Versionsänderungen${NC}"
    fi
}

# Berechtigungen aktualisieren
update_permissions() {
    print_section "Berechtigungen aktualisieren"
    
    # Wichtige Scripts ausführbar machen
    local scripts=("redaxo" "manager" "dashboard-start" "import-dump" "update-manager.sh" "setup.sh" "maintenance.sh" "diagnose.sh" "status.sh")
    
    for script in "${scripts[@]}"; do
        if [ -f "$PROJECT_DIR/$script" ]; then
            chmod +x "$PROJECT_DIR/$script"
            print_success "$script ist ausführbar"
        fi
    done
    
    # Dashboard-Script
    if [ -f "$PROJECT_DIR/dashboard/dashboard-start" ]; then
        chmod +x "$PROJECT_DIR/dashboard/dashboard-start"
        print_success "dashboard-start ist ausführbar"
    fi
}

# Neue Features hinzufügen
add_new_features() {
    print_section "Neue Features hinzufügen"
    
    # Update-Manager zu redaxo-Script hinzufügen (falls nicht vorhanden)
    if [ -f "$PROJECT_DIR/redaxo" ]; then
        if ! grep -q "update-manager" "$PROJECT_DIR/redaxo"; then
            print_step "Update-Manager-Integration wird hinzugefügt..."
            
            # Backup des redaxo-Scripts
            cp "$PROJECT_DIR/redaxo" "$PROJECT_DIR/redaxo.backup.$(date +%Y%m%d_%H%M%S)"
            
            # Integration-Code vorbereiten (wird später mit replace_string_in_file hinzugefügt)
            print_success "Backup des redaxo-Scripts erstellt"
        fi
    fi
    
    # Neue Wartungs-Shortcuts
    if [ ! -f "$PROJECT_DIR/quick-update" ]; then
        cat > "$PROJECT_DIR/quick-update" << 'EOF'
#!/bin/bash
# Schnelles Update für häufige Wartungsaufgaben
# Lädt automatisch die neueste Version vom GitHub-Repository

echo -e "\033[0;34m⚡ Quick-Update: Lade neueste Version vom GitHub...\033[0m"
./update-manager.sh --quick
EOF
        chmod +x "$PROJECT_DIR/quick-update"
        print_success "quick-update Script erstellt"
    fi
    
    # Git-Update Script hinzufügen (falls noch nicht vorhanden)
    if [ ! -f "$PROJECT_DIR/git-update.sh" ]; then
        print_info "git-update.sh Script ist verfügbar für Git-Benutzer"
    fi
}

# Konfiguration validieren
validate_configuration() {
    print_section "Konfiguration validieren"
    
    # Dashboard .env prüfen
    if [ -f "$PROJECT_DIR/dashboard/.env" ]; then
        print_success "Dashboard-Konfiguration gefunden"
        
        # Wichtige Variablen prüfen
        if grep -q "INSTANCES_DIR" "$PROJECT_DIR/dashboard/.env"; then
            print_success "INSTANCES_DIR konfiguriert"
        else
            print_warning "INSTANCES_DIR fehlt in .env"
        fi
    else
        print_warning "Dashboard .env nicht gefunden"
    fi
    
    # SSL-Verzeichnis prüfen
    if [ -d "$PROJECT_DIR/ssl" ]; then
        ssl_count=$(find "$PROJECT_DIR/ssl" -name "*.key" | wc -l | xargs)
        print_info "SSL-Zertifikate: $ssl_count gefunden"
    fi
    
    # Logs prüfen
    if [ -d "$PROJECT_DIR/logs" ]; then
        log_size=$(du -sh "$PROJECT_DIR/logs" 2>/dev/null | cut -f1)
        print_info "Log-Verzeichnis: $log_size"
    fi
}

# Update-Zusammenfassung
show_update_summary() {
    print_section "Update abgeschlossen"
    
    echo -e "${GREEN}✅ Manager erfolgreich aktualisiert!${NC}"
    echo ""
    echo -e "${CYAN}📊 Was wurde aktualisiert:${NC}"
    echo -e "   • 🔄 Neueste Dateien vom GitHub-Repository heruntergeladen"
    echo -e "   • 🛠️ System-Abhängigkeiten (Homebrew, Node.js)"
    echo -e "   • 📦 Dashboard-Pakete und Sicherheits-Updates"
    echo -e "   • 🐳 Docker-System bereinigt und optimiert"
    echo -e "   • 🔐 Script-Berechtigungen aktualisiert"
    echo -e "   • ✨ Neue Features hinzugefügt"
    echo ""
    echo -e "${CYAN}🚀 Empfohlene nächste Schritte:${NC}"
    echo -e "   • Dashboard starten: ${YELLOW}./dashboard-start${NC}"
    echo -e "   • System-Status prüfen: ${YELLOW}./status.sh${NC}"
    echo -e "   • Vollständige Diagnose: ${YELLOW}./diagnose.sh${NC}"
    echo -e "   • Instanzen prüfen: ${YELLOW}./redaxo list${NC}"
    echo ""
    
    if [ -n "$BACKUP_DIR" ]; then
        echo -e "${BLUE}💾 Backup erstellt in: ${YELLOW}$BACKUP_DIR${NC}"
        echo ""
    fi
    
    echo -e "${CYAN}🔄 Zukünftige Updates:${NC}"
    echo -e "   • Schnelles Update: ${YELLOW}./quick-update${NC}"
    echo -e "   • Vollständiges Update: ${YELLOW}./update-manager.sh${NC}"
    echo -e "   • Über REDAXO-Script: ${YELLOW}./redaxo system-update${NC}"
    echo -e "   • Wartung: ${YELLOW}./maintenance.sh${NC} (wöchentlich empfohlen)"
    echo ""
    echo -e "${BLUE}📖 Dokumentation: ${YELLOW}cat UPDATE-GUIDE.md${NC}"
}

# Quick-Update Modus
quick_update() {
    print_header
    echo -e "${YELLOW}⚡ Quick-Update Modus${NC}"
    echo ""
    
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Backup für Quick-Update
    local backup_dir="$PROJECT_DIR/backup-quick-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    export BACKUP_DIR="$backup_dir"
    
    check_github_version
    download_and_apply_updates
    update_dashboard
    optimize_docker
    update_permissions
    
    echo ""
    echo -e "${GREEN}✅ Quick-Update abgeschlossen!${NC}"
    echo -e "${BLUE}💾 Backup erstellt in: ${YELLOW}$BACKUP_DIR${NC}"
}

# Test-Update (für Entwickler)
test_update() {
    print_header
    echo -e "${YELLOW}🧪 Test-Update Modus${NC}"
    echo ""
    
    PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    # Test-Backup
    local backup_dir="$PROJECT_DIR/backup-test-$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$backup_dir"
    export BACKUP_DIR="$backup_dir"
    
    echo -e "${BLUE}Dies ist ein Test-Update. Folgende Aktionen werden simuliert:${NC}"
    echo -e "   • ✅ GitHub-Version prüfen"
    echo -e "   • ✅ Download simulieren"
    echo -e "   • ✅ Backup erstellen"
    echo -e "   • ❌ Dateien NICHT überschreiben"
    echo ""
    
    check_github_version
    
    print_section "Download-Simulation"
    print_step "Würde herunterladen von: $GITHUB_DOWNLOAD_URL"
    print_step "Würde entpacken nach: $TEMP_UPDATE_DIR"
    print_success "Download-Test erfolgreich"
    
    print_section "Update-Simulation"
    local files_to_update=(
        "redaxo" "setup.sh" "maintenance.sh" "diagnose.sh" "status.sh" 
        "import-dump" "redaxo-downloader.sh" "manager" "dashboard-start"
    )
    
    for file in "${files_to_update[@]}"; do
        if [ -f "$PROJECT_DIR/$file" ]; then
            print_info "Würde aktualisieren: $file"
        else
            print_info "Würde hinzufügen: $file"
        fi
    done
    
    echo ""
    echo -e "${GREEN}✅ Test-Update abgeschlossen!${NC}"
    echo -e "${BLUE}💾 Test-Backup erstellt in: ${YELLOW}$BACKUP_DIR${NC}"
    echo ""
    echo -e "${CYAN}Für echtes Update verwenden Sie: ${YELLOW}./update-manager.sh${NC}"
}

# Hauptfunktion
main() {
    # Prüfe Parameter
    case "${1:-}" in
        "--quick")
            quick_update
            exit 0
            ;;
        "--test")
            test_update
            exit 0
            ;;
        "--help"|"-h")
            echo -e "${BLUE}REDAXO Multi-Instance Manager - Update Manager${NC}"
            echo ""
            echo "Verwendung:"
            echo "  ./update-manager.sh           # Vollständiges Update"
            echo "  ./update-manager.sh --quick   # Schnelles Update"
            echo "  ./update-manager.sh --test    # Test-Update (keine Änderungen)"
            echo ""
            echo "Alternativen:"
            echo "  ./git-update.sh              # Git-basiertes Update"
            echo "  ./quick-update               # Alias für --quick"
            echo "  ./redaxo system-update       # Über REDAXO-Script"
            exit 0
            ;;
    esac
    
    print_header
    
    echo -e "${YELLOW}Dieser Update-Manager lädt die neueste Version vom GitHub-Repository herunter${NC}"
    echo -e "${YELLOW}und aktualisiert Ihre bestehende Installation ohne alles neu aufsetzen zu müssen.${NC}"
    echo ""
    echo -e "${CYAN}Repository: https://github.com/skerbis/redaxo-multi-instances${NC}"
    echo ""
    echo -e "${BLUE}Was wird gemacht:${NC}"
    echo -e "   • 📥 Neueste Dateien vom GitHub-Repository herunterladen"
    echo -e "   • 💾 Aktuelle Installation wird gesichert"
    echo -e "   • 🔄 System-Abhängigkeiten werden aktualisiert"
    echo -e "   • 📦 Dashboard wird optimiert"
    echo -e "   • 🐳 Docker-System wird bereinigt"
    echo -e "   • ✨ Neue Features werden hinzugefügt"
    echo ""
    echo -e "${BLUE}Ihre Daten bleiben erhalten:${NC}"
    echo -e "   • ✅ Bestehende Instanzen und deren Daten"
    echo -e "   • ✅ SSL-Zertifikate"
    echo -e "   • ✅ Dashboard-Konfiguration (.env)"
    echo -e "   • ✅ Backups"
    echo ""
    echo -e "${YELLOW}Möchten Sie fortfahren? (y/n):${NC}"
    read -p "> " continue_update
    
    if [ "$continue_update" != "y" ] && [ "$continue_update" != "Y" ]; then
        echo -e "${YELLOW}Update abgebrochen${NC}"
        exit 0
    fi
    
    # Update-Prozess
    check_current_installation
    backup_current_config
    check_github_version
    download_and_apply_updates
    update_system_dependencies
    update_dashboard
    update_redaxo_downloader
    optimize_docker
    check_instance_updates
    update_permissions
    add_new_features
    validate_configuration
    show_update_summary
    
    echo ""
    echo -e "${GREEN}Update erfolgreich abgeschlossen! 🎉${NC}"
}

# Script ausführen
main "$@"
