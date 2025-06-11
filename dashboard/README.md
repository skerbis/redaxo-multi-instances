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

3. Dashboard starten:
```bash
npm start
```

4. Im Browser öffnen:
```
http://localhost:3000
```

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
