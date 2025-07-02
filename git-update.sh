#!/bin/bash

# REDAXO Multi-Instance Manager - Git Update
# Aktualisiert über Git (für Entwickler/Git-Benutzer)
# Repository: https://github.com/skerbis/redaxo-multi-instances

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${BLUE}🔄 Git-Update für REDAXO Multi-Instance Manager${NC}"
echo ""

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Prüfe ob Git-Repository vorhanden ist
if [ ! -d "$PROJECT_DIR/.git" ]; then
    echo -e "${RED}❌ Dies ist kein Git-Repository${NC}"
    echo -e "${YELLOW}💡 Verwenden Sie './update-manager.sh' für Downloads ohne Git${NC}"
    echo ""
    echo -e "${CYAN}Oder initialisieren Sie Git:${NC}"
    echo "git init"
    echo "git remote add origin https://github.com/skerbis/redaxo-multi-instances.git"
    echo "git fetch"
    echo "git reset --hard origin/main"
    exit 1
fi

# Prüfe Git-Status
echo -e "${BLUE}📋 Git-Status wird geprüft...${NC}"

# Uncommitted changes prüfen
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Sie haben uncommitted changes!${NC}"
    echo ""
    echo -e "${CYAN}Geänderte Dateien:${NC}"
    git status --porcelain
    echo ""
    echo -e "${YELLOW}Möchten Sie Ihre Änderungen stashen? (y/n):${NC}"
    read -p "> " stash_changes
    
    if [ "$stash_changes" = "y" ] || [ "$stash_changes" = "Y" ]; then
        git stash push -m "Auto-stash vor Update $(date)"
        echo -e "${GREEN}✅ Änderungen gestasht${NC}"
        STASHED=true
    else
        echo -e "${RED}❌ Update abgebrochen - committen Sie Ihre Änderungen zuerst${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}✅ Arbeitsverzeichnis ist sauber${NC}"
    STASHED=false
fi

# Remote-Informationen
echo -e "${BLUE}🌐 Remote-Repository wird geprüft...${NC}"
git fetch --quiet

# Commits behind prüfen
commits_behind=$(git rev-list HEAD..origin/main --count 2>/dev/null || echo "0")

if [ "$commits_behind" -eq 0 ]; then
    echo -e "${GREEN}✅ Repository ist bereits aktuell${NC}"
    
    if [ "$STASHED" = true ]; then
        echo -e "${YELLOW}💡 Möchten Sie Ihre gestashten Änderungen wiederherstellen? (y/n):${NC}"
        read -p "> " restore_stash
        if [ "$restore_stash" = "y" ] || [ "$restore_stash" = "Y" ]; then
            git stash pop
            echo -e "${GREEN}✅ Stash wiederhergestellt${NC}"
        fi
    fi
    
    exit 0
fi

echo -e "${YELLOW}📥 $commits_behind neue Commits verfügbar${NC}"

# Zeige verfügbare Updates
echo -e "${CYAN}📋 Neue Commits:${NC}"
git log --oneline HEAD..origin/main | head -5

echo ""
echo -e "${YELLOW}Möchten Sie das Update durchführen? (y/n):${NC}"
read -p "> " do_update

if [ "$do_update" != "y" ] && [ "$do_update" != "Y" ]; then
    echo -e "${YELLOW}Update abgebrochen${NC}"
    
    if [ "$STASHED" = true ]; then
        git stash pop
        echo -e "${GREEN}✅ Stash wiederhergestellt${NC}"
    fi
    
    exit 0
fi

# Backup erstellen
echo -e "${BLUE}💾 Backup wird erstellt...${NC}"
backup_dir="$PROJECT_DIR/backup-git-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$backup_dir"

# Wichtige Konfigurationsdateien sichern
if [ -f "dashboard/.env" ]; then
    cp "dashboard/.env" "$backup_dir/"
fi
if [ -d "ssl" ]; then
    cp -r "ssl" "$backup_dir/" 2>/dev/null || true
fi
if [ -d "instances" ]; then
    find instances -name "docker-compose.yml" -exec cp --parents {} "$backup_dir/" \; 2>/dev/null || true
fi

echo -e "${GREEN}✅ Backup erstellt in: $backup_dir${NC}"

# Git Pull durchführen
echo -e "${BLUE}🔄 Git Pull wird durchgeführt...${NC}"

if git pull origin main; then
    echo -e "${GREEN}✅ Repository erfolgreich aktualisiert${NC}"
    
    # Berechtigungen setzen
    echo -e "${BLUE}🔐 Berechtigungen werden gesetzt...${NC}"
    chmod +x redaxo manager setup.sh maintenance.sh diagnose.sh status.sh import-dump redaxo-downloader.sh dashboard-start 2>/dev/null || true
    if [ -f "dashboard/dashboard-start" ]; then
        chmod +x dashboard/dashboard-start
    fi
    
    # Dashboard-Dependencies prüfen
    if [ -f "dashboard/package.json" ]; then
        echo -e "${BLUE}📦 Dashboard-Dependencies werden geprüft...${NC}"
        cd dashboard
        npm install --silent
        cd ..
        echo -e "${GREEN}✅ Dashboard-Dependencies aktualisiert${NC}"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Git-Update erfolgreich abgeschlossen!${NC}"
    echo ""
    echo -e "${CYAN}📊 Was wurde aktualisiert:${NC}"
    echo -e "   • $commits_behind neue Commits eingespielt"
    echo -e "   • Berechtigungen gesetzt"
    echo -e "   • Dashboard-Dependencies aktualisiert"
    echo ""
    echo -e "${CYAN}🚀 Empfohlene nächste Schritte:${NC}"
    echo -e "   • Dashboard starten: ${YELLOW}./dashboard-start${NC}"
    echo -e "   • System-Status prüfen: ${YELLOW}./status.sh${NC}"
    echo ""
    echo -e "${BLUE}💾 Backup verfügbar in: ${YELLOW}$backup_dir${NC}"
    
    # Stash wiederherstellen
    if [ "$STASHED" = true ]; then
        echo ""
        echo -e "${YELLOW}💡 Sie haben gestashte Änderungen. Möchten Sie diese wiederherstellen? (y/n):${NC}"
        read -p "> " restore_stash
        if [ "$restore_stash" = "y" ] || [ "$restore_stash" = "Y" ]; then
            if git stash pop; then
                echo -e "${GREEN}✅ Stash erfolgreich wiederhergestellt${NC}"
            else
                echo -e "${YELLOW}⚠️  Merge-Konflikte beim Stash-Restore${NC}"
                echo -e "${CYAN}Lösen Sie die Konflikte manuell mit: git status${NC}"
            fi
        fi
    fi
    
else
    echo -e "${RED}❌ Git Pull fehlgeschlagen${NC}"
    
    if [ "$STASHED" = true ]; then
        git stash pop
        echo -e "${GREEN}✅ Stash wiederhergestellt${NC}"
    fi
    
    exit 1
fi
