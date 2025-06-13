# REDAXO Dashboard

Ein schönes Dashboard im Morphing Glass Look zur Verwaltung aller REDAXO-Instanzen.

## Features

- 🎨 **Morphing Glass Design** - Modernes glasmorphisches UI mit Wellenanimationen
- 🎯 **Font Awesome Icons** - Professionelle Icons statt Emojis
- 📋 **Instanzen-Übersicht** - Alle REDAXO-Instanzen auf einen Blick
- 🚀 **Start/Stop-Kontrolle** - Instanzen direkt über das Dashboard steuern
- ➕ **Neue Instanzen erstellen** - Einfache Erstellung neuer REDAXO-Instanzen
- 🗑️ **Instanzen löschen** - Sichere Löschung mit Bestätigung
- 🔗 **Direkte Links** - Frontend, Backend, phpMyAdmin und Mailpit
- 📱 **Responsive Design** - Funktioniert auf Desktop und Mobile
- 🔄 **Live-Updates** - Automatische Aktualisierung des Status
- 🌊 **Wellenanimationen** - Dynamischer Hintergrund in gedecktem Blau

## Installation

1. In das Dashboard-Verzeichnis wechseln:
```bash
cd dashboard
```

2. Abhängigkeiten installieren:
```bash
npm install
```

3. Konfiguration anpassen (optional):
```bash
cp .env.example .env
# Bearbeite .env für projektspezifische Einstellungen
```

4. Dashboard starten:
```bash
npm start
```

5. Im Browser öffnen:
```
http://localhost:3000
```

## Konfiguration

Das Dashboard erkennt automatisch die Projekt-Pfade und ist vollständig portierbar. Optionale Konfiguration über `.env`:

```bash
# Projekt-Pfade (automatisch erkannt)
PROJECT_ROOT=/pfad/zu/redaxo-multi-instances
INSTANCES_DIR=/pfad/zu/redaxo-multi-instances/instances

# Dashboard-Features
ENABLE_SCREENSHOTS=true
ENABLE_VSCODE_INTEGRATION=true
ENABLE_REALTIME_UPDATES=true
ENABLE_TERMINAL_INTEGRATION=true

# Server-Einstellungen
PORT=3000
NODE_ENV=development
```

### Portierbarkeit

Das Dashboard ist vollständig portierbar und funktioniert auf jedem System:

- ✅ **Automatische Pfad-Erkennung** - Keine hardcodierten Pfade
- ✅ **Umgebungsvariablen** - Alle Einstellungen konfigurierbar
- ✅ **Cross-Platform** - Funktioniert auf macOS, Linux und Windows
- ✅ **VS Code Integration** - Dynamische Links zum Code-Editor
- ✅ **Terminal Integration** - Plattformspezifische Terminal-Öffnung

## Entwicklung

Für die Entwicklung mit automatischem Neuladen:

```bash
npm run dev
```

## Verwendung

### Neue Instanz erstellen
1. Auf "Neue Instanz" klicken
2. Instanzname eingeben (nur Buchstaben, Zahlen, Bindestriche, Unterstriche)
3. Optional: PHP- und MariaDB-Version wählen
4. Automatische Installation aktivieren (empfohlen)
5. "Instanz erstellen" klicken

### Instanz verwalten
- **Starten**: Grüner "Starten"-Button
- **Stoppen**: Orangener "Stoppen"-Button
- **Löschen**: Roter "Löschen"-Button (mit Bestätigung)

### Links verwenden
Jede Instanz-Karte zeigt direkte Links zu:
- Frontend (HTTP/HTTPS)
- Backend/Admin-Bereich (HTTP/HTTPS)
- phpMyAdmin (Datenbank-Verwaltung)
- Mailpit (E-Mail-Testing)

## Technische Details

- **Backend**: Node.js mit Express
- **Frontend**: Vanilla JavaScript mit Glass-Morphism CSS
- **Real-time**: Socket.IO für Live-Updates
- **API**: RESTful API für Instanz-Verwaltung

Das Dashboard nutzt die vorhandenen Shell-Skripte (`./redaxo`) für alle Operationen.

## Ports

- Dashboard: `3000` (Standard)
- REDAXO-Instanzen: Automatisch zugewiesene Ports (ab 8080)

## Sicherheit

- Nur lokaler Zugriff (localhost)
- Keine Authentifizierung erforderlich (lokale Entwicklung)
- Sichere Löschbestätigung
