#!/bin/bash

# REDAXO Multi-Instance Manager - Setup Script
# Automatische Installation und Konfiguration aller Abhängigkeiten

set -e  # Beende bei Fehlern

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
DOWNLOAD="📥"
INFO="ℹ️"

# Funktionen
print_header() {
    echo ""
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}  🚀 REDAXO Multi-Instance Manager - Setup${NC}"
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

# Prüfe ob macOS läuft
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "Dieses Script ist nur für macOS konzipiert!"
        exit 1
    fi
    print_success "macOS erkannt"
}

# Prüfe und installiere Homebrew
check_homebrew() {
    print_section "Homebrew prüfen und installieren"
    
    if command -v brew >/dev/null 2>&1; then
        print_success "Homebrew ist bereits installiert"
        print_step "Homebrew wird aktualisiert..."
        brew update >/dev/null 2>&1 || true
    else
        print_step "Homebrew wird installiert..."
        echo ""
        print_info "Homebrew ist der Paketmanager für macOS und wird für die Installation"
        print_info "von Node.js und anderen Abhängigkeiten benötigt."
        echo ""
        
        # Homebrew Installation
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Homebrew zu PATH hinzufügen
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        elif [[ -f "/usr/local/bin/brew" ]]; then
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        print_success "Homebrew wurde erfolgreich installiert"
    fi
}

# Prüfe Docker Desktop
check_docker() {
    print_section "Docker Desktop prüfen"
    
    if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        print_success "Docker Desktop ist installiert und läuft"
        docker_version=$(docker --version | cut -d' ' -f3 | cut -d',' -f1)
        print_info "Docker Version: $docker_version"
    else
        print_warning "Docker Desktop ist nicht verfügbar!"
        echo ""
        print_info "Docker Desktop wird für das Ausführen der REDAXO-Instanzen benötigt."
        print_info "Bitte wählen Sie eine der folgenden Optionen:"
        echo ""
        echo -e "${YELLOW}1)${NC} Docker Desktop automatisch installieren (empfohlen)"
        echo -e "${YELLOW}2)${NC} Docker Desktop manuell installieren"
        echo -e "${YELLOW}3)${NC} Setup abbrechen"
        echo ""
        
        read -p "Ihre Wahl (1-3): " choice
        
        case $choice in
            1)
                install_docker_desktop
                ;;
            2)
                manual_docker_install
                ;;
            3)
                print_info "Setup abgebrochen. Docker Desktop ist erforderlich."
                exit 0
                ;;
            *)
                print_error "Ungültige Auswahl. Setup wird abgebrochen."
                exit 1
                ;;
        esac
    fi
}

# Docker Desktop automatisch installieren
install_docker_desktop() {
    print_step "Docker Desktop wird automatisch installiert..."
    
    # Prüfe Architektur
    if [[ $(uname -m) == "arm64" ]]; then
        DOCKER_URL="https://desktop.docker.com/mac/main/arm64/Docker.dmg"
        print_info "Apple Silicon (M1/M2) erkannt - ARM64 Version wird heruntergeladen"
    else
        DOCKER_URL="https://desktop.docker.com/mac/main/amd64/Docker.dmg"
        print_info "Intel Mac erkannt - x86_64 Version wird heruntergeladen"
    fi
    
    # Download Docker Desktop
    print_step "Docker Desktop wird heruntergeladen..."
    curl -L "$DOCKER_URL" -o /tmp/Docker.dmg
    
    # DMG mounten
    print_step "Docker.dmg wird gemountet..."
    hdiutil attach /tmp/Docker.dmg -quiet
    
    # Docker.app installieren
    print_step "Docker Desktop wird installiert..."
    cp -R "/Volumes/Docker/Docker.app" "/Applications/"
    
    # DMG unmounten
    hdiutil detach "/Volumes/Docker" -quiet
    
    # Temporäre Datei löschen
    rm /tmp/Docker.dmg
    
    print_success "Docker Desktop wurde erfolgreich installiert!"
    
    # Docker Desktop starten
    print_step "Docker Desktop wird gestartet..."
    open -a Docker
    
    print_info "Warten auf Docker Desktop Start..."
    echo ""
    print_warning "WICHTIG: Docker Desktop startet jetzt zum ersten Mal."
    print_warning "Bitte folgen Sie den Anweisungen in Docker Desktop um die"
    print_warning "Installation abzuschließen und stimmen Sie den Lizenzbedingungen zu."
    echo ""
    
    # Warte auf Docker
    wait_for_docker
}

# Manuelle Docker Installation
manual_docker_install() {
    echo ""
    print_info "Für die manuelle Installation gehen Sie bitte wie folgt vor:"
    echo ""
    echo -e "${YELLOW}1.${NC} Besuchen Sie: ${BLUE}https://www.docker.com/products/docker-desktop/${NC}"
    echo -e "${YELLOW}2.${NC} Laden Sie Docker Desktop für Mac herunter"
    echo -e "${YELLOW}3.${NC} Installieren Sie Docker Desktop"
    echo -e "${YELLOW}4.${NC} Starten Sie Docker Desktop"
    echo -e "${YELLOW}5.${NC} Starten Sie dieses Setup-Script erneut"
    echo ""
    print_info "Das Setup wird beendet. Starten Sie es nach der Docker-Installation erneut."
    exit 0
}

# Warte auf Docker Start
wait_for_docker() {
    local max_attempts=60
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if docker info >/dev/null 2>&1; then
            print_success "Docker Desktop ist bereit!"
            return 0
        fi
        
        echo -n "."
        sleep 2
        ((attempt++))
    done
    
    echo ""
    print_error "Docker Desktop konnte nicht gestartet werden!"
    print_info "Bitte starten Sie Docker Desktop manuell und führen Sie das Setup erneut aus."
    exit 1
}

# Node.js installieren
install_nodejs() {
    print_section "Node.js installieren"
    
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version)
        print_success "Node.js ist bereits installiert: $node_version"
        
        # Prüfe ob Version ausreichend ist (mindestens v16)
        major_version=$(echo $node_version | cut -d'.' -f1 | cut -d'v' -f2)
        if [ "$major_version" -ge 16 ]; then
            print_success "Node.js Version ist ausreichend"
        else
            print_warning "Node.js Version ist zu alt (benötigt v16+), wird aktualisiert..."
            brew install node
        fi
    else
        print_step "Node.js wird installiert..."
        brew install node
        print_success "Node.js wurde erfolgreich installiert"
    fi
    
    # npm und Node.js Version anzeigen
    node_version=$(node --version)
    npm_version=$(npm --version)
    print_info "Node.js: $node_version"
    print_info "npm: $npm_version"
}

# Prüfe Git
check_git() {
    print_section "Git prüfen"
    
    if command -v git >/dev/null 2>&1; then
        git_version=$(git --version)
        print_success "Git ist verfügbar: $git_version"
    else
        print_warning "Git ist nicht installiert!"
        print_step "Git wird über Xcode Command Line Tools installiert..."
        xcode-select --install 2>/dev/null || true
        print_info "Xcode Command Line Tools Installation gestartet"
        print_info "Bitte folgen Sie den Anweisungen und starten Sie das Setup danach erneut"
        exit 0
    fi
}

# Prüfe Visual Studio Code
check_vscode() {
    print_section "Visual Studio Code prüfen"
    
    if [ -d "/Applications/Visual Studio Code.app" ]; then
        print_success "Visual Studio Code ist installiert"
        
        # Prüfe ob 'code' Befehl verfügbar ist
        if command -v code >/dev/null 2>&1; then
            print_success "VS Code 'code' Befehl ist bereits verfügbar"
        else
            print_step "VS Code 'code' Befehl wird zum PATH hinzugefügt..."
            
            # Füge VS Code zum PATH hinzu
            VSCODE_PATH="/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
            
            # Für zsh (Standard auf macOS Catalina+)
            if [ -f ~/.zshrc ]; then
                if ! grep -q "Visual Studio Code" ~/.zshrc 2>/dev/null; then
                    echo "" >> ~/.zshrc
                    echo "# Visual Studio Code" >> ~/.zshrc
                    echo "export PATH=\"\$PATH:$VSCODE_PATH\"" >> ~/.zshrc
                    print_success "VS Code zum zsh PATH hinzugefügt"
                fi
            fi
            
            # Für bash (Fallback)
            if [ -f ~/.bash_profile ]; then
                if ! grep -q "Visual Studio Code" ~/.bash_profile 2>/dev/null; then
                    echo "" >> ~/.bash_profile
                    echo "# Visual Studio Code" >> ~/.bash_profile
                    echo "export PATH=\"\$PATH:$VSCODE_PATH\"" >> ~/.bash_profile
                    print_success "VS Code zum bash PATH hinzugefügt"
                fi
            fi
            
            print_info "Der 'code' Befehl wird nach einem Terminal-Neustart verfügbar sein"
        fi
    else
        print_warning "Visual Studio Code ist nicht installiert!"
        echo ""
        print_info "VS Code wird für die Dashboard-Integration empfohlen."
        print_info "Bitte wählen Sie eine der folgenden Optionen:"
        echo ""
        echo -e "${YELLOW}1)${NC} VS Code automatisch installieren (empfohlen)"
        echo -e "${YELLOW}2)${NC} VS Code manuell installieren"
        echo -e "${YELLOW}3)${NC} Ohne VS Code fortfahren"
        echo ""
        
        read -p "Ihre Wahl (1-3): " choice
        
        case $choice in
            1)
                install_vscode
                ;;
            2)
                print_info "Bitte installieren Sie VS Code von: https://code.visualstudio.com/"
                print_info "Starten Sie das Setup danach erneut für die vollständige Integration."
                ;;
            3)
                print_info "Setup wird ohne VS Code fortgesetzt"
                ;;
            *)
                print_error "Ungültige Auswahl. Setup wird ohne VS Code fortgesetzt."
                ;;
        esac
    fi
}

# VS Code automatisch installieren
install_vscode() {
    print_step "Visual Studio Code wird installiert..."
    
    if command -v brew >/dev/null 2>&1; then
        print_info "Installation über Homebrew..."
        brew install --cask visual-studio-code
        
        if [ $? -eq 0 ]; then
            print_success "VS Code wurde erfolgreich installiert"
            # Rekursive Prüfung für PATH-Setup
            check_vscode
        else
            print_error "Fehler bei der VS Code Installation über Homebrew"
            print_info "Bitte installieren Sie VS Code manuell von: https://code.visualstudio.com/"
        fi
    else
        print_warning "Homebrew nicht verfügbar"
        print_info "Bitte installieren Sie VS Code manuell von: https://code.visualstudio.com/"
    fi
}

# jq für JSON-Verarbeitung installieren
install_jq() {
    print_section "JSON-Tools installieren"
    
    if command -v jq >/dev/null 2>&1; then
        print_success "jq ist bereits installiert"
    else
        print_step "jq wird installiert..."
        brew install jq
        print_success "jq wurde erfolgreich installiert"
    fi
}

# Dashboard Abhängigkeiten installieren
setup_dashboard() {
    print_section "Dashboard konfigurieren"
    
    cd "$(dirname "$0")/dashboard"
    
    # Prüfe ob package.json existiert
    if [ ! -f "package.json" ]; then
        print_error "package.json nicht gefunden in dashboard/"
        return 1
    fi
    
    print_step "Dashboard-Abhängigkeiten werden installiert..."
    
    # NPM Cache leeren für saubere Installation
    npm cache clean --force >/dev/null 2>&1 || true
    
    # Abhängigkeiten installieren mit Progress-Anzeige
    npm install --production=false
    
    # Screenshots-Verzeichnis erstellen
    if [ ! -d "public/screenshots" ]; then
        print_step "Screenshots-Verzeichnis wird erstellt..."
        mkdir -p public/screenshots
        print_success "Screenshots-Verzeichnis erstellt"
    fi
    
    # .env-Datei erstellen falls nicht vorhanden
    if [ ! -f ".env" ]; then
        print_step ".env-Datei wird erstellt..."
        cat > .env << 'EOF'
# Dashboard Konfiguration
PORT=3000
NODE_ENV=development

# Screenshots
SCREENSHOT_DIR=public/screenshots
SCREENSHOT_QUALITY=90
SCREENSHOT_TIMEOUT=10000

# Puppeteer Konfiguration
PUPPETEER_HEADLESS=true
PUPPETEER_TIMEOUT=30000
EOF
        print_success ".env-Datei erstellt"
    fi
    
    print_success "Dashboard-Abhängigkeiten wurden installiert"
}

# Berechtigungen für Scripts setzen
set_permissions() {
    print_section "Berechtigungen setzen"
    
    cd "$(dirname "$0")"
    
    # Prüfe ob wichtige Scripts existieren
    local scripts=("redaxo" "manager" "dashboard-start" "import-dump")
    local missing_scripts=()
    
    for script in "${scripts[@]}"; do
        if [ ! -f "$script" ]; then
            missing_scripts+=("$script")
        fi
    done
    
    if [ ${#missing_scripts[@]} -gt 0 ]; then
        print_warning "Folgende Scripts fehlen und werden erstellt:"
        for script in "${missing_scripts[@]}"; do
            print_info "  - $script"
        done
        create_missing_scripts
    fi
    
    # Alle Shell-Scripts ausführbar machen
    find . -name "*.sh" -type f -exec chmod +x {} \;
    
    # Wichtige Scripts ausführbar machen
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            chmod +x "$script"
            print_success "Berechtigung gesetzt: $script"
        fi
    done
    
    print_success "Alle Berechtigungen wurden gesetzt"
}

# Fehlende Scripts erstellen
create_missing_scripts() {
    cd "$(dirname "$0")"
    
    # Dashboard-Start Script
    if [ ! -f "dashboard-start" ]; then
        print_step "Dashboard-Start Script wird erstellt..."
        cat > dashboard-start << 'EOF'
#!/bin/bash

# REDAXO Dashboard Starter
cd "$(dirname "$0")/dashboard"

echo "🚀 REDAXO Dashboard wird gestartet..."
echo "📱 Dashboard verfügbar unter: http://localhost:3000"
echo "🛑 Zum Stoppen: Ctrl+C"
echo ""

# Prüfe ob Node.js verfügbar ist
if ! command -v node >/dev/null 2>&1; then
    echo "❌ Node.js nicht gefunden! Bitte Setup ausführen."
    exit 1
fi

# Prüfe ob Dependencies installiert sind
if [ ! -d "node_modules" ]; then
    echo "📦 Abhängigkeiten werden installiert..."
    npm install
fi

# Dashboard starten
npm start
EOF
        chmod +x dashboard-start
        print_success "dashboard-start erstellt"
    fi
    
    # Import-Dump Script (Basic Version)
    if [ ! -f "import-dump" ]; then
        print_step "Import-Dump Script wird erstellt..."
        cat > import-dump << 'EOF'
#!/bin/bash

# REDAXO Dump Import Tool
echo "🗃️  REDAXO Dump Import Tool"
echo "Diese Funktion ist noch in Entwicklung."
echo ""
echo "Für manuellen Import:"
echo "1. Instanz starten: ./redaxo start <instanz-name>"
echo "2. REDAXO Backend öffnen"
echo "3. Backup/Import verwenden"
EOF
        chmod +x import-dump
        print_success "import-dump erstellt"
    fi
}

# Docker-Netzwerk erstellen
setup_docker_network() {
    print_section "Docker-Netzwerk konfigurieren"
    
    if docker network ls | grep -q "redaxo-network"; then
        print_success "Docker-Netzwerk 'redaxo-network' existiert bereits"
    else
        print_step "Docker-Netzwerk 'redaxo-network' wird erstellt..."
        docker network create redaxo-network
        print_success "Docker-Netzwerk wurde erstellt"
    fi
}

# Test-Instanz erstellen (optional)
create_test_instance() {
    print_section "Test-Instanz erstellen (optional)"
    
    echo ""
    print_info "Möchten Sie eine Test-Instanz erstellen um das System zu testen?"
    echo ""
    echo -e "${YELLOW}1)${NC} Ja, Test-Instanz erstellen"
    echo -e "${YELLOW}2)${NC} Nein, später selbst erstellen"
    echo ""
    
    read -p "Ihre Wahl (1-2): " choice
    
    case $choice in
        1)
            print_step "Test-Instanz 'demo' wird erstellt..."
            cd "$(dirname "$0")"
            ./redaxo create demo --php-version 8.4 --mariadb-version latest --auto-install
            print_success "Test-Instanz 'demo' wurde erstellt"
            ;;
        2)
            print_info "Test-Instanz übersprungen"
            ;;
        *)
            print_info "Ungültige Auswahl - Test-Instanz übersprungen"
            ;;
    esac
}

# Dashboard starten
start_dashboard() {
    print_section "Dashboard starten"
    
    cd "$(dirname "$0")"
    
    # Prüfe ob Dashboard-Start Script existiert
    if [ ! -f "dashboard-start" ]; then
        print_error "dashboard-start Script nicht gefunden!"
        return 1
    fi
    
    # Prüfe ob Port 3000 bereits belegt ist
    if lsof -i :3000 >/dev/null 2>&1; then
        print_warning "Port 3000 ist bereits belegt!"
        print_info "Möglicherweise läuft bereits ein Dashboard oder ein anderer Service."
        
        echo ""
        echo -e "${YELLOW}1)${NC} Dashboard trotzdem starten (kann fehlschlagen)"
        echo -e "${YELLOW}2)${NC} Port-Konflikt ignorieren und fortfahren"
        echo ""
        
        read -p "Ihre Wahl (1-2): " choice
        
        case $choice in
            1)
                print_step "Dashboard wird gestartet (Port möglicherweise belegt)..."
                ;;
            2)
                print_info "Dashboard-Start übersprungen - starten Sie es später manuell"
                return 0
                ;;
        esac
    fi
    
    print_step "Dashboard wird im Hintergrund gestartet..."
    
    # Dashboard in Background starten
    nohup ./dashboard-start > dashboard.log 2>&1 &
    dashboard_pid=$!
    
    print_info "Dashboard PID: $dashboard_pid"
    print_step "Warte 5 Sekunden auf Dashboard-Start..."
    
    # Warte auf Dashboard
    local max_attempts=10
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s http://localhost:3000 >/dev/null 2>&1; then
            print_success "Dashboard läuft erfolgreich auf http://localhost:3000"
            print_info "Dashboard-Log: dashboard.log"
            return 0
        fi
        
        echo -n "."
        sleep 1
        ((attempt++))
    done
    
    echo ""
    print_warning "Dashboard konnte nicht automatisch gestartet werden"
    print_info "Prüfen Sie die Logs: cat dashboard.log"
    print_info "Manueller Start: ./dashboard-start"
    
    # Prüfe ob Prozess noch läuft
    if ps -p $dashboard_pid >/dev/null 2>&1; then
        print_info "Dashboard-Prozess läuft noch (PID: $dashboard_pid)"
    else
        print_error "Dashboard-Prozess ist beendet"
    fi
}

# Abschluss-Informationen
show_completion_info() {
    echo ""
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}  ${ROCKET} Setup erfolgreich abgeschlossen!${NC}"
    echo -e "${GREEN}════════════════════════════════════════════════════════════════${NC}"
    echo ""
    
    print_info "Das REDAXO Multi-Instance System ist jetzt einsatzbereit!"
    echo ""
    
    echo -e "${CYAN}📱 Dashboard:${NC}"
    echo -e "   ${ARROW} Öffnen Sie: ${BLUE}http://localhost:3000${NC}"
    echo -e "   ${ARROW} Starten: ${YELLOW}./dashboard-start${NC}"
    echo -e "   ${ARROW} Stoppen: ${YELLOW}Ctrl+C${NC} im Terminal"
    echo ""
    
    echo -e "${CYAN}🔧 REDAXO-Instanzen verwalten:${NC}"
    echo -e "   ${ARROW} Neue Instanz: ${YELLOW}./redaxo create <name>${NC}"
    echo -e "   ${ARROW} Instanz starten: ${YELLOW}./redaxo start <name>${NC}"
    echo -e "   ${ARROW} Instanz stoppen: ${YELLOW}./redaxo stop <name>${NC}"
    echo -e "   ${ARROW} Alle Befehle: ${YELLOW}./redaxo --help${NC}"
    echo ""
    
    echo -e "${CYAN}📚 Weitere Tools:${NC}"
    echo -e "   ${ARROW} Manager-UI: ${YELLOW}./manager${NC}"
    echo -e "   ${ARROW} Dump importieren: ${YELLOW}./import-dump${NC}"
    echo -e "   ${ARROW} Dokumentation: ${YELLOW}README.md${NC}"
    echo ""
    
    echo -e "${CYAN}🐳 Docker Desktop:${NC}"
    echo -e "   ${ARROW} Status prüfen: ${YELLOW}docker ps${NC}"
    echo -e "   ${ARROW} Läuft im Hintergrund (Docker Desktop App)"
    echo ""
    
    if [ -d "instances/demo" ]; then
        echo -e "${CYAN}🎯 Test-Instanz 'demo':${NC}"
        echo -e "   ${ARROW} Dashboard verwenden oder direkt starten: ${YELLOW}./redaxo start demo${NC}"
        echo ""
    fi
    
    print_warning "WICHTIG:"
    print_info "• Docker Desktop muss laufen damit REDAXO-Instanzen funktionieren"
    print_info "• Das Dashboard startet automatisch - öffnen Sie http://localhost:3000"
    print_info "• Bei Problemen: Prüfen Sie Docker Desktop und starten Sie das Dashboard neu"
    echo ""
    
    echo -e "${GREEN}Viel Spaß mit dem REDAXO Multi-Instance Manager! 🎉${NC}"
}

# Hauptprogramm
main() {
    print_header
    
    # System-Checks
    check_macos
    
    # Abhängigkeiten installieren
    check_homebrew
    check_git
    check_vscode
    check_docker
    check_git
    check_vscode
    install_nodejs
    install_jq
    
    # Projekt konfigurieren
    set_permissions
    setup_docker_network
    setup_dashboard
    
    # Optional: Test-Instanz
    create_test_instance
    
    # Dashboard starten
    start_dashboard
    
    # Abschluss
    show_completion_info
}

# Script ausführen
main "$@"
