#!/bin/bash

# SSL-Setup Tool für REDAXO Multi-Instance Manager
# Hilft beim Installieren und Verwalten von SSL-Zertifikaten

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
SSL_DIR="$PROJECT_DIR/ssl"

show_help() {
    echo -e "${GREEN}REDAXO SSL-Setup Tool${NC}"
    echo "Hilfsprogramm für SSL-Zertifikate"
    echo ""
    echo "Verwendung:"
    echo "  ./ssl-setup.sh [Befehl]"
    echo ""
    echo "Befehle:"
    echo "  install-ca              - mkcert CA-Zertifikat installieren (empfohlen)"
    echo "  remove-ca               - CA-Zertifikat aus macOS Keychain entfernen"
    echo "  check-ca                - Überprüfen ob CA-Zertifikat installiert ist"
    echo "  test-ssl <instanz>      - SSL-Verbindung einer Instanz testen"
    echo "  generate-mkcert <instanz> - mkcert-Zertifikat für Instanz generieren"
    echo "  safari-info             - Informationen für Safari-Nutzung"
    echo "  help                    - Diese Hilfe anzeigen"
    echo ""
    echo -e "${YELLOW}Hinweis: Für beste Browser-Kompatibilität wird mkcert empfohlen${NC}"
}

# CA-Zertifikat installieren
install_ca() {
    echo -e "${YELLOW}Installiere mkcert CA-Zertifikat...${NC}"
    
    # Prüfe ob mkcert installiert ist
    if ! command -v mkcert &> /dev/null; then
        echo -e "${RED}Fehler: mkcert ist nicht installiert${NC}"
        echo -e "${YELLOW}Installieren Sie mkcert mit: brew install mkcert${NC}"
        exit 1
    fi
    
    # Installiere mkcert CA
    mkcert -install
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ mkcert CA-Zertifikat erfolgreich installiert${NC}"
        echo -e "${BLUE}Safari und alle Browser sollten jetzt SSL-Zertifikate ohne Warnung akzeptieren.${NC}"
        echo -e "${YELLOW}Bitte starten Sie Safari neu, damit die Änderungen wirksam werden.${NC}"
        
        # Aktualisiere bestehende Zertifikate auf mkcert
        echo -e "${YELLOW}Aktualisiere bestehende SSL-Zertifikate...${NC}"
        for instance_dir in "$PROJECT_DIR/instances"/*; do
            if [ -d "$instance_dir" ]; then
                instance_name=$(basename "$instance_dir")
                if [ -d "$SSL_DIR/$instance_name" ]; then
                    echo -e "${BLUE}Regeneriere SSL-Zertifikat für $instance_name...${NC}"
                    generate_mkcert_certificate "$instance_name"
                fi
            fi
        done
        
    else
        echo -e "${RED}✗ Fehler beim Installieren des mkcert CA-Zertifikats${NC}"
    fi
}

# CA-Zertifikat entfernen
remove_ca() {
    echo -e "${YELLOW}Entferne mkcert CA-Zertifikat...${NC}"
    
    # Prüfe ob mkcert installiert ist
    if command -v mkcert &> /dev/null; then
        mkcert -uninstall
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ mkcert CA-Zertifikat erfolgreich entfernt${NC}"
        else
            echo -e "${RED}✗ Fehler beim Entfernen des mkcert CA-Zertifikats${NC}"
        fi
    else
        echo -e "${YELLOW}mkcert ist nicht installiert${NC}"
    fi
    
    # Entferne auch alte REDAXO CA-Zertifikate falls vorhanden
    security delete-certificate -c "REDAXO Local Certificate Authority" ~/Library/Keychains/login.keychain 2>/dev/null && echo -e "${GREEN}✓ Altes REDAXO CA-Zertifikat entfernt${NC}" || true
}

# CA-Status prüfen
check_ca() {
    echo -e "${BLUE}Überprüfe CA-Zertifikat Status...${NC}"
    
    # Prüfe ob CA-Datei existiert
    if [ ! -f "$SSL_DIR/ca/ca.crt" ]; then
        echo -e "${RED}✗ CA-Zertifikat-Datei nicht gefunden${NC}"
        return 1
    fi
    
    echo -e "${GREEN}✓ CA-Zertifikat-Datei gefunden${NC}"
    
    # Prüfe ob in Keychain installiert
    if security find-certificate -c "REDAXO Local Certificate Authority" ~/Library/Keychains/login.keychain >/dev/null 2>&1; then
        echo -e "${GREEN}✓ CA-Zertifikat in macOS Keychain installiert${NC}"
        
        # Zeige Zertifikat-Details
        echo -e "\n${BLUE}Zertifikat-Details:${NC}"
        openssl x509 -in "$SSL_DIR/ca/ca.crt" -text -noout | grep -A 2 "Subject:"
        openssl x509 -in "$SSL_DIR/ca/ca.crt" -text -noout | grep -A 2 "Not After"
    else
        echo -e "${YELLOW}⚠ CA-Zertifikat nicht in macOS Keychain installiert${NC}"
        echo -e "${BLUE}Führen Sie './ssl-setup.sh install-ca' aus, um es zu installieren.${NC}"
    fi
}

# SSL-Verbindung testen
test_ssl() {
    local instance=$1
    
    if [ -z "$instance" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        echo "Verwendung: ./ssl-setup.sh test-ssl <instanzname>"
        exit 1
    fi
    
    if [ ! -f "$PROJECT_DIR/instances/$instance/.env" ]; then
        echo -e "${RED}Fehler: Instanz '$instance' nicht gefunden${NC}"
        exit 1
    fi
    
    source "$PROJECT_DIR/instances/$instance/.env"
    
    if [ -z "$HTTPS_PORT" ]; then
        echo -e "${RED}Fehler: Instanz '$instance' hat kein SSL aktiviert${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Teste SSL-Verbindung für Instanz '$instance' auf Port $HTTPS_PORT...${NC}"
    
    # Test mit curl
    if curl -s -I "https://localhost:$HTTPS_PORT" >/dev/null 2>&1; then
        echo -e "${GREEN}✓ SSL-Verbindung funktioniert${NC}"
        
        # Zeige Zertifikat-Details
        echo -e "\n${BLUE}Zertifikat-Details:${NC}"
        echo | openssl s_client -connect "localhost:$HTTPS_PORT" -servername localhost 2>/dev/null | openssl x509 -noout -subject -dates
    else
        echo -e "${RED}✗ SSL-Verbindung fehlgeschlagen${NC}"
        echo -e "${YELLOW}Überprüfen Sie, ob die Instanz läuft und SSL korrekt konfiguriert ist.${NC}"
    fi
}

# Safari-Informationen
safari_info() {
    echo -e "${GREEN}Safari SSL-Setup Informationen${NC}"
    echo -e "${GREEN}════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Schritte für SSL in Safari:${NC}"
    echo ""
    echo -e "1. ${YELLOW}CA-Zertifikat installieren:${NC}"
    echo "   ./ssl-setup.sh install-ca"
    echo ""
    echo -e "2. ${YELLOW}Safari neustarten${NC}"
    echo ""
    echo -e "3. ${YELLOW}HTTPS-URL besuchen:${NC}"
    echo "   https://localhost:8443 (für redaxo-modern)"
    echo "   https://localhost:8444 (für test-ssl)"
    echo ""
    echo -e "${BLUE}Fehlerbehebung:${NC}"
    echo ""
    echo -e "• ${YELLOW}Falls immer noch Warnung erscheint:${NC}"
    echo "  - Safari komplett beenden und neu starten"
    echo "  - Keychain Access öffnen und CA-Zertifikat auf 'Immer vertrauen' setzen"
    echo ""
    echo -e "• ${YELLOW}CA-Status prüfen:${NC}"
    echo "  ./ssl-setup.sh check-ca"
    echo ""
    echo -e "• ${YELLOW}SSL-Verbindung testen:${NC}"
    echo "  ./ssl-setup.sh test-ssl redaxo-modern"
}

# Generiert SSL-Zertifikat mit mkcert
generate_mkcert_certificate() {
    local instance_name=$1
    local cert_dir="$SSL_DIR/$instance_name"
    
    if [ -z "$instance_name" ]; then
        echo -e "${RED}Fehler: Instanzname erforderlich${NC}"
        return 1
    fi
    
    echo -e "${YELLOW}Generiere mkcert SSL-Zertifikat für $instance_name...${NC}"
    
    # Prüfe ob mkcert installiert ist
    if ! command -v mkcert &> /dev/null; then
        echo -e "${RED}Fehler: mkcert ist nicht installiert${NC}"
        echo -e "${YELLOW}Installieren Sie mkcert mit: brew install mkcert${NC}"
        return 1
    fi
    
    # Stelle sicher, dass Verzeichnis existiert
    mkdir -p "$cert_dir"
    
    # Generiere Zertifikat mit mkcert
    cd "$cert_dir"
    mkcert -key-file private.key -cert-file cert.crt localhost 127.0.0.1 "$instance_name.local" "*.local"
    
    if [ $? -eq 0 ]; then
        # Erstelle kombinierte Dateien für Docker
        cat cert.crt private.key > combined.pem
        cp cert.crt fullchain.crt
        
        echo -e "${GREEN}✓ mkcert SSL-Zertifikat für $instance_name erstellt${NC}"
        echo -e "${BLUE}Zertifikat ist automatisch von allen Browsern vertrauenswürdig${NC}"
    else
        echo -e "${RED}✗ Fehler beim Erstellen des mkcert-Zertifikats${NC}"
        return 1
    fi
}

# Hauptlogik
case $1 in
    install-ca)
        install_ca
        ;;
        remove-ca)
        remove_ca
        ;;
    check-ca)
        check_ca
        ;;
    test-ssl)
        test_ssl "$2"
        ;;
    generate-mkcert)
        generate_mkcert_certificate "$2"
        ;;
    safari-info)
        safari_info
        ;;
    help|--help|-h|*)
        show_help
        ;;
esac
