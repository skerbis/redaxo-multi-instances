#!/bin/bash

# REDAXO Download Manager
# Lädt die neueste REDAXO Modern Structure aus GitHub

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# GitHub-Repository-Informationen
# Standard-Repository (kann überschrieben werden)
DEFAULT_GITHUB_REPO="skerbis/REDAXO_MODERN_STRUCTURE"
GITHUB_REPO="${REDAXO_REPO:-$DEFAULT_GITHUB_REPO}"
GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
GITHUB_RELEASES_URL="https://github.com/$GITHUB_REPO/releases"

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
TEMP_DIR="$PROJECT_DIR/temp"
DOWNLOAD_DIR="$PROJECT_DIR/downloads"

# Funktionen
show_help() {
    echo -e "${GREEN}REDAXO Download Manager${NC}"
    echo "Lädt die neueste REDAXO Modern Structure aus GitHub"
    echo ""
    echo "Verwendung:"
    echo "  ./redaxo-downloader.sh [Befehl] [Optionen]"
    echo ""
    echo "Befehle:"
    echo "  download [version]      - Lädt neueste oder spezifische Version"
    echo "  list-releases           - Zeigt verfügbare Releases"
    echo "  check-latest            - Prüft auf neueste Version"
    echo "  clean                   - Bereinigt Download-Cache"
    echo "  help                    - Diese Hilfe anzeigen"
    echo ""
    echo "Optionen:"
    echo "  --force                 - Download erzwingen (Cache ignorieren)"
    echo "  --extract-to <path>     - Extrahieren nach spezifischem Pfad"
    echo "  --repo <owner/repo>     - Alternatives GitHub-Repository verwenden"
    echo ""
    echo "Repository-Beispiele:"
    echo "  --repo redaxo/redaxo           - Original REDAXO"
    echo "  --repo redaxo/demo_base        - REDAXO Demo"
    echo "  --repo ihr-user/ihr-repo       - Ihr eigenes Repository"
    echo ""
    echo "Aktuell verwendetes Repository: $GITHUB_REPO"
}

# Funktion zum Setzen des Repositories
set_repository() {
    local repo="$1"
    if [[ "$repo" =~ ^[a-zA-Z0-9_-]+/[a-zA-Z0-9_.-]+$ ]]; then
        GITHUB_REPO="$repo"
        GITHUB_API_URL="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
        GITHUB_RELEASES_URL="https://github.com/$GITHUB_REPO/releases"
        echo -e "${BLUE}Repository geändert zu: $GITHUB_REPO${NC}"
    else
        echo -e "${RED}Fehler: Ungültiges Repository-Format. Verwenden Sie: owner/repository${NC}"
        exit 1
    fi
}

# Prüft GitHub-API-Verfügbarkeit
check_github_api() {
    if ! command -v curl &> /dev/null; then
        echo -e "${RED}Fehler: curl ist nicht installiert${NC}"
        exit 1
    fi
    
    if ! curl -s --head "$GITHUB_API_URL" | grep -E "(200|HTTP/2 200)" >/dev/null; then
        echo -e "${RED}Fehler: GitHub-API nicht erreichbar${NC}"
        echo -e "${YELLOW}Überprüfen Sie Ihre Internetverbindung${NC}"
        exit 1
    fi
}

# Holt Informationen über das neueste Release
get_latest_release_info() {
    local api_response
    api_response=$(curl -s "$GITHUB_API_URL")
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Fehler beim Abrufen der Release-Informationen${NC}"
        exit 1
    fi
    
    # Extrahiere Informationen mit jq oder einfachem grep/sed
    if command -v jq &> /dev/null; then
        local tag_name=$(echo "$api_response" | jq -r '.tag_name')
        local name=$(echo "$api_response" | jq -r '.name')
        local published_at=$(echo "$api_response" | jq -r '.published_at')
        
        # Suche nach ZIP-Asset mit dem korrekten Pattern für das Repository
        local pattern
        case "$GITHUB_REPO" in
            "skerbis/REDAXO_MODERN_STRUCTURE")
                pattern="redaxo-setup.*\\.zip$"
                ;;
            "redaxo/redaxo")
                pattern="redaxo_.*\\.zip$"
                ;;
            "redaxo/demo_base")
                pattern="redaxo_.*\\.zip$"
                ;;
            *)
                pattern=".*\\.zip$"
                ;;
        esac
        echo -e "${BLUE}Repository: $GITHUB_REPO${NC}"
        echo -e "${BLUE}Pattern wird gesucht: $pattern${NC}"
        local download_url=$(echo "$api_response" | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" | head -1)
        
        echo "$tag_name"
        echo "$name"
        echo "$published_at"
        echo "$download_url"
    else
        # Fallback ohne jq
        local tag_name=$(echo "$api_response" | grep -o '"tag_name":"[^"]*"' | cut -d'"' -f4)
        local name=$(echo "$api_response" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
        local published_at=$(echo "$api_response" | grep -o '"published_at":"[^"]*"' | cut -d'"' -f4)
        
        # Suche nach ZIP-Download-URL mit dem Pattern für das Repository
        local pattern_grep
        case "$GITHUB_REPO" in
            "skerbis/REDAXO_MODERN_STRUCTURE")
                pattern_grep="redaxo-setup.*\\.zip"
                ;;
            "redaxo/redaxo")
                pattern_grep="redaxo_.*\\.zip"
                ;;
            "redaxo/demo_base")
                pattern_grep="redaxo_.*\\.zip"
                ;;
            *)
                pattern_grep=".*\\.zip"
                ;;
        esac
        local download_url=$(echo "$api_response" | grep -o "\"browser_download_url\":\"[^\"]*$pattern_grep\"" | head -1 | cut -d'"' -f4)
        
        echo "$tag_name"
        echo "$name"
        echo "$published_at"
        echo "$download_url"
    fi
}

# Ermittelt das Asset-Pattern für das aktuelle Repository
get_asset_pattern() {
    case "$GITHUB_REPO" in
        "skerbis/REDAXO_MODERN_STRUCTURE")
            echo "redaxo-setup.*\\.zip$"
            ;;
        "redaxo/redaxo")
            echo "redaxo_.*\\.zip$"
            ;;
        "redaxo/demo_base")
            echo "redaxo_.*\\.zip$"
            ;;
        *)
            # Standard-Pattern für unbekannte Repositories
            echo ".*\\.zip$"
            ;;
    esac
}

# Ermittelt das Asset-Pattern für grep (ohne Regex-Escaping)
get_asset_pattern_grep() {
    case "$GITHUB_REPO" in
        "skerbis/REDAXO_MODERN_STRUCTURE")
            echo "redaxo-setup.*\.zip"
            ;;
        "redaxo/redaxo")
            echo "redaxo_.*\.zip"
            ;;
        "redaxo/demo_base")
            echo "redaxo_.*\.zip"
            ;;
        *)
            # Standard-Pattern für unbekannte Repositories
            echo ".*\.zip"
            ;;
    esac
}

# Lädt spezifische Version herunter
download_redaxo() {
    local version=$1
    local force=${2:-false}
    local extract_to=$3
    
    mkdir -p "$TEMP_DIR" "$DOWNLOAD_DIR"
    
    echo -e "${YELLOW}Lade REDAXO Modern Structure herunter...${NC}"
    
    # Hole Release-Informationen
    check_github_api
    
    local tag_name name published_at download_url
    if [ -z "$version" ] || [ "$version" = "latest" ]; then
        echo -e "${BLUE}Ermittle neueste Version...${NC}"
        
        # Direkter API-Aufruf für bessere Kontrolle
        local api_response
        api_response=$(curl -s "$GITHUB_API_URL")
        
        if command -v jq &> /dev/null; then
            tag_name=$(echo "$api_response" | jq -r '.tag_name')
            name=$(echo "$api_response" | jq -r '.name')
            published_at=$(echo "$api_response" | jq -r '.published_at')
            
            # Verwende das korrekte Pattern basierend auf dem Repository
            local pattern
            case "$GITHUB_REPO" in
                "skerbis/REDAXO_MODERN_STRUCTURE")
                    pattern="redaxo-setup.*\\\\.zip$"
                    ;;
                "redaxo/redaxo")
                    pattern="redaxo_.*\\\\.zip$"
                    ;;
                "redaxo/demo_base")
                    pattern="redaxo_.*\\\\.zip$"
                    ;;
                *)
                    pattern=".*\\\\.zip$"
                    ;;
            esac
            download_url=$(echo "$api_response" | jq -r ".assets[] | select(.name | test(\"$pattern\")) | .browser_download_url" | head -1)
        else
            tag_name=$(echo "$api_response" | grep -o '"tag_name":"[^"]*"' | cut -d'"' -f4)
            name=$(echo "$api_response" | grep -o '"name":"[^"]*"' | cut -d'"' -f4)
            published_at=$(echo "$api_response" | grep -o '"published_at":"[^"]*"' | cut -d'"' -f4)
            
            # Verwende das korrekte Pattern basierend auf dem Repository für grep
            local pattern_grep
            case "$GITHUB_REPO" in
                "skerbis/REDAXO_MODERN_STRUCTURE")
                    pattern_grep="redaxo-setup.*\\.zip"
                    ;;
                "redaxo/redaxo")
                    pattern_grep="redaxo_.*\\.zip"
                    ;;
                "redaxo/demo_base")
                    pattern_grep="redaxo_.*\\.zip"
                    ;;
                *)
                    pattern_grep=".*\\.zip"
                    ;;
            esac
            download_url=$(echo "$api_response" | grep -o "\"browser_download_url\":\"[^\"]*$pattern_grep\"" | head -1 | cut -d'"' -f4)
        fi
        
        version="$tag_name"
    fi
    
    if [ -z "$version" ]; then
        echo -e "${RED}Fehler: Keine Version gefunden${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Version: $version${NC}"
    
    # Prüfe ob bereits heruntergeladen (außer bei --force)
    local download_file="$DOWNLOAD_DIR/redaxo-modern-$version.zip"
    local extract_dir="$DOWNLOAD_DIR/redaxo-modern-$version"
    
    if [ -f "$download_file" ] && [ "$force" = false ]; then
        echo -e "${GREEN}Version bereits heruntergeladen: $download_file${NC}"
    else
        # Download URL ermitteln
        if [ -z "$download_url" ]; then
            echo -e "${RED}Fehler: Keine Download-URL für Release $version gefunden${NC}"
            echo -e "${YELLOW}Prüfen Sie: https://github.com/$GITHUB_REPO/releases${NC}"
            exit 1
        fi
        
        echo -e "${BLUE}Download-URL: $download_url${NC}"
        
        # Direkter Download mit der korrekten URL
        echo -e "${BLUE}Lade herunter von: $download_url${NC}"
        
        if curl -L -o "$download_file.tmp" "$download_url" --progress-bar; then
            # Prüfe ob Download erfolgreich war (Dateigröße > 1KB)
            if [ -f "$download_file.tmp" ] && [ $(stat -f%z "$download_file.tmp" 2>/dev/null || stat -c%s "$download_file.tmp" 2>/dev/null) -gt 1024 ]; then
                mv "$download_file.tmp" "$download_file"
                echo -e "${GREEN}✓ Download erfolgreich${NC}"
            else
                rm -f "$download_file.tmp"
                echo -e "${RED}Fehler: Download fehlgeschlagen (Datei zu klein)${NC}"
                exit 1
            fi
        else
            rm -f "$download_file.tmp"
            echo -e "${RED}Fehler: Download fehlgeschlagen${NC}"
            echo -e "${YELLOW}URL: $download_url${NC}"
            exit 1
        fi
    fi
    
    # Extrahiere Archiv
    echo -e "${BLUE}Extrahiere Archiv...${NC}"
    rm -rf "$extract_dir"
    mkdir -p "$extract_dir"
    
    # Erkenne Archiv-Typ und extrahiere entsprechend
    if file "$download_file" | grep -q "Zip"; then
        unzip -q "$download_file" -d "$extract_dir"
    elif file "$download_file" | grep -q "gzip"; then
        tar -xzf "$download_file" -C "$extract_dir"
    else
        echo -e "${RED}Unbekanntes Archiv-Format${NC}"
        exit 1
    fi
    
    # Finde extrahiertes Verzeichnis (kann Unterverzeichnis haben)
    local extracted_content
    if [ -d "$extract_dir"/* ] 2>/dev/null; then
        # Es gibt ein Hauptverzeichnis im Archiv
        extracted_content=$(find "$extract_dir" -mindepth 1 -maxdepth 1 -type d | head -1)
    else
        # Dateien sind direkt im extract_dir
        extracted_content="$extract_dir"
    fi
    
    # Kopiere zu Zielverzeichnis falls angegeben
    if [ -n "$extract_to" ]; then
        echo -e "${BLUE}Kopiere nach: $extract_to${NC}"
        mkdir -p "$extract_to"
        
        # Kopiere Inhalt, nicht das Verzeichnis selbst
        if [ -d "$extracted_content" ] && [ "$extracted_content" != "$extract_dir" ]; then
            # Es gibt ein Unterverzeichnis - kopiere dessen Inhalt
            cp -r "$extracted_content"/* "$extract_to/"
        else
            # Kopiere direkt aus extract_dir
            cp -r "$extract_dir"/* "$extract_to/"
        fi
        
        echo -e "${GREEN}✓ REDAXO Modern Structure installiert in: $extract_to${NC}"
    else
        if [ -d "$extracted_content" ] && [ "$extracted_content" != "$extract_dir" ]; then
            echo -e "${GREEN}✓ REDAXO Modern Structure extrahiert nach: $extracted_content${NC}"
        else
            echo -e "${GREEN}✓ REDAXO Modern Structure extrahiert nach: $extract_dir${NC}"
            extracted_content="$extract_dir"
        fi
    fi
    
    # Zeige Verzeichnisinhalt
    echo -e "${BLUE}Inhalt:${NC}"
    ls -la "$extracted_content" || ls -la "$extract_dir"
    
    echo "$extracted_content"
}

# Listet verfügbare Releases auf
list_releases() {
    echo -e "${YELLOW}Lade Release-Informationen...${NC}"
    check_github_api
    
    local releases_json
    releases_json=$(curl -s "https://api.github.com/repos/$GITHUB_REPO/releases")
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Fehler beim Abrufen der Releases${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}Verfügbare REDAXO Modern Structure Releases:${NC}"
    echo ""
    
    if command -v jq &> /dev/null; then
        echo "$releases_json" | jq -r '.[] | "\(.tag_name) - \(.name) (\(.published_at[:10]))"' | head -10
    else
        # Fallback ohne jq
        echo "$releases_json" | grep -E '"tag_name"|"name"|"published_at"' | \
        sed 'N;N;s/.*"tag_name": *"\([^"]*\)".*"name": *"\([^"]*\)".*"published_at": *"\([^"]*\)".*/\1 - \2 (\3)/' | \
        sed 's/T[0-9:]*Z//' | head -10
    fi
    
    echo ""
    echo -e "${BLUE}Alle Releases anzeigen: $GITHUB_RELEASES_URL${NC}"
}

# Prüft auf neueste Version
check_latest() {
    echo -e "${YELLOW}Prüfe neueste Version...${NC}"
    check_github_api
    
    local release_info
    release_info=($(get_latest_release_info))
    
    if [ ${#release_info[@]} -ge 3 ]; then
        echo -e "${GREEN}Neueste Version:${NC}"
        echo -e "  Tag: ${BLUE}${release_info[0]}${NC}"
        echo -e "  Name: ${BLUE}${release_info[1]}${NC}"
        echo -e "  Datum: ${BLUE}${release_info[2]}${NC}"
        
        # Prüfe ob bereits heruntergeladen
        local download_file="$DOWNLOAD_DIR/redaxo-modern-${release_info[0]}.zip"
        if [ -f "$download_file" ]; then
            echo -e "  Status: ${GREEN}✓ Bereits heruntergeladen${NC}"
        else
            echo -e "  Status: ${YELLOW}Nicht heruntergeladen${NC}"
        fi
    else
        echo -e "${RED}Fehler beim Abrufen der Version${NC}"
        exit 1
    fi
}

# Bereinigt Download-Cache
clean_cache() {
    echo -e "${YELLOW}Bereinige Download-Cache...${NC}"
    
    if [ -d "$DOWNLOAD_DIR" ]; then
        local size=$(du -sh "$DOWNLOAD_DIR" 2>/dev/null | cut -f1)
        rm -rf "$DOWNLOAD_DIR"
        echo -e "${GREEN}✓ $size Cache bereinigt${NC}"
    else
        echo -e "${YELLOW}Kein Cache gefunden${NC}"
    fi
    
    if [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}✓ Temporäre Dateien bereinigt${NC}"
    fi
}

# Hauptlogik
case $1 in
    download)
        shift
        version=""
        force=false
        extract_to=""
        
        # Parse Argumente
        while [[ $# -gt 0 ]]; do
            case $1 in
                --force)
                    force=true
                    shift
                    ;;
                --extract-to)
                    extract_to="$2"
                    shift 2
                    ;;
                --repo)
                    set_repository "$2"
                    shift 2
                    ;;
                *)
                    if [ -z "$version" ]; then
                        version="$1"
                    fi
                    shift
                    ;;
            esac
        done
        
        download_redaxo "$version" "$force" "$extract_to"
        ;;
    list-releases)
        shift
        # Parse Repository-Option für list-releases
        while [[ $# -gt 0 ]]; do
            case $1 in
                --repo)
                    set_repository "$2"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        list_releases
        ;;
    check-latest)
        shift
        # Parse Repository-Option für check-latest
        while [[ $# -gt 0 ]]; do
            case $1 in
                --repo)
                    set_repository "$2"
                    shift 2
                    ;;
                *)
                    shift
                    ;;
            esac
        done
        check_latest
        ;;
    clean)
        clean_cache
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
