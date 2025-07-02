#!/bin/bash

# REDAXO Dashboard - Schnelles Update Script
# Optimiert für Dashboard-spezifische Updates

# Farben
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Dashboard Update wird gestartet...${NC}"

# Wechsle ins Dashboard-Verzeichnis
cd "$(dirname "$0")"

# Prüfe ob Dashboard läuft
if pgrep -f "node.*server.js" >/dev/null; then
    echo -e "${YELLOW}⚠️  Dashboard läuft - wird für Update gestoppt${NC}"
    pkill -f "node.*server.js" || true
    sleep 2
    RESTART_DASHBOARD=true
else
    RESTART_DASHBOARD=false
fi

echo -e "${BLUE}📦 Abhängigkeiten werden aktualisiert...${NC}"

# npm cache bereinigen
npm cache clean --force >/dev/null 2>&1

# Abhängigkeiten aktualisieren
npm update

# Sicherheits-Updates
echo -e "${BLUE}🛡️  Sicherheits-Updates werden geprüft...${NC}"
npm audit fix --force

# Node-modules neu installieren falls nötig
if [ ! -d "node_modules" ] || [ ! -f "package-lock.json" ]; then
    echo -e "${YELLOW}📥 Node-modules werden neu installiert...${NC}"
    npm install
fi

# Logs bereinigen
if [ -d "logs" ]; then
    find logs -name "*.log" -mtime +7 -delete 2>/dev/null || true
    echo -e "${GREEN}✅ Alte Logs bereinigt${NC}"
fi

# Screenshots bereinigen
if [ -d "public/screenshots" ]; then
    find public/screenshots -name "*.png" -mtime +7 -delete 2>/dev/null || true
    echo -e "${GREEN}✅ Alte Screenshots bereinigt${NC}"
fi

# Dashboard neu starten falls es vorher lief
if [ "$RESTART_DASHBOARD" = true ]; then
    echo -e "${BLUE}🔄 Dashboard wird neu gestartet...${NC}"
    chmod +x dashboard-start
    ./dashboard-start &
    sleep 3
    echo -e "${GREEN}✅ Dashboard ist wieder verfügbar unter http://localhost:3000${NC}"
fi

echo -e "${GREEN}✅ Dashboard-Update abgeschlossen!${NC}"
