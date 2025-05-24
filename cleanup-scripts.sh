#!/bin/bash

# 🧹 REDAXO Multi-Instance Script Cleanup
# Automatische Bereinigung der duplizierten Scripts

# Farben für Terminal-Output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Projektverzeichnis
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
PROJECT_DIR="$SCRIPT_DIR"
BACKUP_DIR="$PROJECT_DIR/cleanup-backup-$(date +%Y%m%d_%H%M%S)"

echo -e "${GREEN}🧹 REDAXO Script Cleanup Tool${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════${NC}"
echo ""

# Funktion zum Erstellen von Backups
create_backup() {
    echo -e "${YELLOW}Erstelle Sicherung...${NC}"
    mkdir -p "$BACKUP_DIR"
    
    # Sichere scripts/ Verzeichnis
    if [ -d "$PROJECT_DIR/scripts" ]; then
        cp -r "$PROJECT_DIR/scripts" "$BACKUP_DIR/"
        echo -e "${GREEN}✓ scripts/ Verzeichnis gesichert${NC}"
    fi
    
    # Sichere relevante Root-Scripts
    for script in instance-manager.sh redaxo update-manager.sh; do
        if [ -f "$PROJECT_DIR/$script" ]; then
            cp "$PROJECT_DIR/$script" "$BACKUP_DIR/"
            echo -e "${GREEN}✓ $script gesichert${NC}"
        fi
    done
    
    echo -e "${BLUE}Backup erstellt in: $BACKUP_DIR${NC}"
    echo ""
}

# Funktion zum Korrigieren der Pfad-Referenzen
fix_path_references() {
    echo -e "${YELLOW}Korrigiere Pfad-Referenzen...${NC}"
    
    # 1. instance-manager.sh - Korrigiere scripts/ Referenz
    if [ -f "$PROJECT_DIR/instance-manager.sh" ]; then
        sed -i.bak 's|./scripts/instance-manager.sh|./instance-manager.sh|g' "$PROJECT_DIR/instance-manager.sh"
        rm -f "$PROJECT_DIR/instance-manager.sh.bak"
        echo -e "${GREEN}✓ instance-manager.sh korrigiert${NC}"
    fi
    
    # 2. redaxo Wrapper - Korrigiere alle scripts/ Referenzen
    if [ -f "$PROJECT_DIR/redaxo" ]; then
        # Korrigiere scripts/instance-manager.sh zu instance-manager.sh
        sed -i.bak 's|"$SCRIPT_DIR/scripts/instance-manager.sh"|"$SCRIPT_DIR/instance-manager.sh"|g' "$PROJECT_DIR/redaxo"
        # Korrigiere scripts/backup-manager.sh zu backup-manager.sh  
        sed -i.bak 's|"$SCRIPT_DIR/scripts/backup-manager.sh"|"$SCRIPT_DIR/backup-manager.sh"|g' "$PROJECT_DIR/redaxo"
        # Korrigiere scripts/redaxo-downloader.sh zu redaxo-downloader.sh
        sed -i.bak 's|"$SCRIPT_DIR/scripts/redaxo-downloader.sh"|"$SCRIPT_DIR/redaxo-downloader.sh"|g' "$PROJECT_DIR/redaxo"
        # Korrigiere scripts/update-manager.sh zu update-manager.sh
        sed -i.bak 's|"$SCRIPT_DIR/scripts/update-manager.sh"|"$SCRIPT_DIR/update-manager.sh"|g' "$PROJECT_DIR/redaxo"
        rm -f "$PROJECT_DIR/redaxo.bak"
        echo -e "${GREEN}✓ redaxo Wrapper korrigiert${NC}"
    fi
    
    # 3. update-manager.sh - Korrigiere backup-manager.sh Referenz
    if [ -f "$PROJECT_DIR/update-manager.sh" ]; then
        sed -i.bak 's|"$PROJECT_DIR/scripts/backup-manager.sh"|"$PROJECT_DIR/backup-manager.sh"|g' "$PROJECT_DIR/update-manager.sh"
        rm -f "$PROJECT_DIR/update-manager.sh.bak"
        echo -e "${GREEN}✓ update-manager.sh korrigiert${NC}"
    fi
    
    # 4. Korrigiere instance-manager.sh download Referenzen
    if [ -f "$PROJECT_DIR/instance-manager.sh" ]; then
        sed -i.bak 's|"$SCRIPT_DIR/redaxo-downloader.sh"|"$PROJECT_DIR/redaxo-downloader.sh"|g' "$PROJECT_DIR/instance-manager.sh"
        rm -f "$PROJECT_DIR/instance-manager.sh.bak"
        echo -e "${GREEN}✓ instance-manager.sh Download-Referenzen korrigiert${NC}"
    fi
    
    echo ""
}

# Funktion zum Entfernen des scripts/ Verzeichnisses
remove_scripts_directory() {
    echo -e "${YELLOW}Entferne scripts/ Verzeichnis...${NC}"
    
    if [ -d "$PROJECT_DIR/scripts" ]; then
        # Zähle Dateien vor Löschung
        local file_count=$(find "$PROJECT_DIR/scripts" -type f | wc -l | tr -d ' ')
        
        # Entferne das Verzeichnis
        rm -rf "$PROJECT_DIR/scripts"
        
        if [ ! -d "$PROJECT_DIR/scripts" ]; then
            echo -e "${GREEN}✓ scripts/ Verzeichnis entfernt ($file_count Dateien)${NC}"
        else
            echo -e "${RED}✗ Fehler beim Entfernen des scripts/ Verzeichnisses${NC}"
            return 1
        fi
    else
        echo -e "${YELLOW}scripts/ Verzeichnis nicht gefunden${NC}"
    fi
    
    echo ""
}

# Funktion zum Aktualisieren der Dokumentation
update_documentation() {
    echo -e "${YELLOW}Aktualisiere Dokumentation...${NC}"
    
    # README.md aktualisieren
    if [ -f "$PROJECT_DIR/README.md" ]; then
        # Ersetze scripts/ Referenzen mit ./ 
        sed -i.bak 's|scripts/setup\.sh|setup.sh|g' "$PROJECT_DIR/README.md"
        sed -i.bak 's|scripts/instance-manager\.sh|instance-manager.sh|g' "$PROJECT_DIR/README.md"
        sed -i.bak 's|scripts/monitor\.sh|monitor.sh|g' "$PROJECT_DIR/README.md"
        sed -i.bak 's|chmod +x redaxo scripts/\*\.sh|chmod +x *.sh|g' "$PROJECT_DIR/README.md"
        rm -f "$PROJECT_DIR/README.md.bak"
        echo -e "${GREEN}✓ README.md aktualisiert${NC}"
    fi
    
    # QUICKSTART-BEGINNERS.md aktualisieren
    if [ -f "$PROJECT_DIR/QUICKSTART-BEGINNERS.md" ]; then
        sed -i.bak 's|scripts/setup\.sh|setup.sh|g' "$PROJECT_DIR/QUICKSTART-BEGINNERS.md"
        sed -i.bak 's|scripts/\*\.sh|*.sh|g' "$PROJECT_DIR/QUICKSTART-BEGINNERS.md"
        rm -f "$PROJECT_DIR/QUICKSTART-BEGINNERS.md.bak"
        echo -e "${GREEN}✓ QUICKSTART-BEGINNERS.md aktualisiert${NC}"
    fi
    
    echo ""
}

# Funktion zur Validierung der Änderungen
validate_cleanup() {
    echo -e "${YELLOW}Validiere Cleanup...${NC}"
    
    local errors=0
    
    # Prüfe ob scripts/ Verzeichnis wirklich entfernt wurde
    if [ -d "$PROJECT_DIR/scripts" ]; then
        echo -e "${RED}✗ scripts/ Verzeichnis noch vorhanden${NC}"
        ((errors++))
    else
        echo -e "${GREEN}✓ scripts/ Verzeichnis erfolgreich entfernt${NC}"
    fi
    
    # Prüfe ob wichtige Scripts im Root vorhanden sind
    local required_scripts=("instance-manager.sh" "backup-manager.sh" "redaxo-downloader.sh" "redaxo")
    
    for script in "${required_scripts[@]}"; do
        if [ -f "$PROJECT_DIR/$script" ]; then
            echo -e "${GREEN}✓ $script verfügbar${NC}"
        else
            echo -e "${RED}✗ $script fehlt${NC}"
            ((errors++))
        fi
    done
    
    # Prüfe ob keine scripts/ Referenzen mehr vorhanden sind
    local script_refs=$(grep -r "scripts/" "$PROJECT_DIR"/*.sh "$PROJECT_DIR/redaxo" 2>/dev/null | wc -l | tr -d ' ')
    
    if [ "$script_refs" -eq 0 ]; then
        echo -e "${GREEN}✓ Keine scripts/ Referenzen mehr vorhanden${NC}"
    else
        echo -e "${YELLOW}⚠ Noch $script_refs scripts/ Referenzen gefunden${NC}"
        echo -e "${BLUE}Details:${NC}"
        grep -r "scripts/" "$PROJECT_DIR"/*.sh "$PROJECT_DIR/redaxo" 2>/dev/null || true
    fi
    
    echo ""
    
    if [ $errors -eq 0 ]; then
        echo -e "${GREEN}✅ Cleanup erfolgreich abgeschlossen!${NC}"
        return 0
    else
        echo -e "${RED}❌ Cleanup mit $errors Fehlern abgeschlossen${NC}"
        return 1
    fi
}

# Funktion zum Anzeigen der neuen Struktur
show_new_structure() {
    echo -e "${BLUE}Neue Script-Struktur:${NC}"
    echo ""
    echo "redaxo-multi-instances/"
    echo "├── instance-manager.sh    # 🎯 Haupt-Manager (erweitert)"
    echo "├── backup-manager.sh      # 💾 Backup-Tool"  
    echo "├── update.sh             # 🔄 Global Docker Update"
    echo "├── logger.sh             # 📝 Logging-System"
    echo "├── monitor.sh            # 📊 System-Monitor"
    echo "├── redaxo-downloader.sh  # 📥 GitHub-Download"
    echo "├── redaxo-docker.sh      # 🐳 Docker-Utilities"
    echo "├── update-manager.sh     # ⬆️ Instance-Updates"
    echo "├── setup.sh              # ⚙️ System-Setup"
    echo "├── demo.sh               # 🎪 Demo-Tool"
    echo "└── redaxo                # 🚀 Haupt-Interface"
    echo ""
    echo -e "${GREEN}🗑️ scripts/ Verzeichnis vollständig entfernt${NC}"
    echo ""
}

# Interaktive Bestätigung
echo -e "${BLUE}Dieser Vorgang wird:${NC}"
echo "  1. 💾 Backup aller Scripts erstellen"
echo "  2. 🔧 Pfad-Referenzen korrigieren"
echo "  3. 🗑️ scripts/ Verzeichnis entfernen"
echo "  4. 📝 Dokumentation aktualisieren"
echo "  5. ✅ Änderungen validieren"
echo ""
echo -e "${YELLOW}Backup wird erstellt in: $BACKUP_DIR${NC}"
echo ""

read -p "Möchten Sie fortfahren? [j/N] " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[JjYy]$ ]]; then
    echo -e "${YELLOW}Cleanup abgebrochen${NC}"
    exit 0
fi

echo ""

# Hauptablauf
create_backup

if fix_path_references && remove_scripts_directory && update_documentation; then
    if validate_cleanup; then
        show_new_structure
        echo -e "${GREEN}🎉 Script-Cleanup erfolgreich abgeschlossen!${NC}"
        echo ""
        echo -e "${BLUE}Nächste Schritte:${NC}"
        echo "  1. Testen Sie die Hauptfunktionen:"
        echo -e "     ${YELLOW}./redaxo help${NC}"
        echo -e "     ${YELLOW}./instance-manager.sh help${NC}"
        echo ""
        echo "  2. Bei Problemen können Sie das Backup wiederherstellen:"
        echo -e "     ${YELLOW}cp -r $BACKUP_DIR/scripts ./${NC}"
        echo ""
        echo -e "${GREEN}✨ Ihre REDAXO Multi-Instance Installation ist jetzt optimiert!${NC}"
    else
        echo -e "${RED}❌ Validation fehlgeschlagen. Prüfen Sie das Backup.${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Cleanup fehlgeschlagen. Prüfen Sie das Backup.${NC}"
    exit 1
fi
