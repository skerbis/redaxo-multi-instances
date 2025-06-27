const express = require('express');
const { exec } = require('child_process');
const path = require('path');
const fs = require('fs');
const http = require('http');
const socketIo = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = socketIo(server);

const PORT = process.env.PORT || 3000;
const PROJECT_ROOT = path.join(__dirname, '..');
const INSTANCES_DIR = path.join(PROJECT_ROOT, 'instances');

// Middleware
app.use(express.json());
app.use(express.static(path.join(__dirname, 'public')));

// API: Konfiguration abrufen
app.get('/api/config', (req, res) => {
    res.json({
        projectRoot: PROJECT_ROOT,
        instancesDir: INSTANCES_DIR,
        features: {
            terminalIntegration: true,
            vscodeIntegration: true,
            databaseInfo: true
        }
    });
});

// API: Alle Instanzen abrufen
app.get('/api/instances', async (req, res) => {
    try {
        const instances = await getInstances();
        res.json(instances);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Instanz starten
app.post('/api/instances/:name/start', async (req, res) => {
    try {
        const { name } = req.params;
        await executeCommand(`./redaxo start ${name}`);
        
        // Status nach dem Start abrufen
        setTimeout(async () => {
            const instances = await getInstances();
            const instance = instances.find(i => i.name === name);
            io.emit('instanceUpdated', instance);
        }, 2000);
        
        res.json({ success: true, message: `Instanz ${name} wird gestartet...` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Instanz stoppen
app.post('/api/instances/:name/stop', async (req, res) => {
    try {
        const { name } = req.params;
        await executeCommand(`./redaxo stop ${name}`);
        
        // Status nach dem Stop abrufen
        setTimeout(async () => {
            const instances = await getInstances();
            const instance = instances.find(i => i.name === name);
            io.emit('instanceUpdated', instance);
        }, 2000);
        
        res.json({ success: true, message: `Instanz ${name} wird gestoppt...` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Instanz Backup erstellen
app.post('/api/instances/:name/backup', async (req, res) => {
    try {
        const { name } = req.params;
        await executeCommand(`./redaxo backup ${name}`);
        res.json({ success: true, message: `Backup für Instanz ${name} erstellt.` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Backups einer Instanz auflisten
app.get('/api/instances/:name/backups', async (req, res) => {
    try {
        const { name } = req.params;
        const output = await executeCommand(`./redaxo backups ${name}`);
        const cleanOutput = stripAnsiCodes(output);
        
        // Parse the output to extract backup names and details
        const backups = cleanOutput.split('\n')
            .filter(line => line.includes('📁'))
            .map(line => {
                const match = line.match(/📁\s*(\S+)\s*\(([^)]+)\)/);
                if (match) {
                    return { name: match[1], size: match[2] };
                }
                return null;
            })
            .filter(Boolean);

        res.json({ success: true, backups });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Backup einer Instanz wiederherstellen
app.post('/api/instances/:name/restore', async (req, res) => {
    try {
        const { name } = req.params;
        const { backupName } = req.body;

        if (!backupName) {
            return res.status(400).json({ error: 'Backup-Name fehlt' });
        }

        await executeCommand(`./redaxo restore ${name} ${backupName}`);
        res.json({ success: true, message: `Backup ${backupName} für Instanz ${name} wiederhergestellt.` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Neue Instanz erstellen

app.post('/api/instances', async (req, res) => {
    try {
        const { name, phpVersion, mariadbVersion, autoInstall, importDump, webserverOnly, dumpFile } = req.body;
        
        if (!name || !name.match(/^[a-zA-Z0-9_-]+$/)) {
            return res.status(400).json({ error: 'Ungültiger Instanzname' });
        }

        // Prüfe ob Instanz bereits existiert
        const instanceDir = path.join(INSTANCES_DIR, name);
        if (fs.existsSync(instanceDir)) {
            return res.status(400).json({ error: `Instanz '${name}' existiert bereits. Bitte wählen Sie einen anderen Namen.` });
        }
        
        // Prüfe ob Import-Dump gewählt wurde
        if (importDump && dumpFile) {
            // Verwende import-dump Script (absoluter Pfad)
            let command = `./import-dump ${name} "${dumpFile}"`;
            if (phpVersion) command += ` --php-version ${phpVersion}`;
            if (mariadbVersion) command += ` --mariadb-version ${mariadbVersion}`;
            
            // Führe Befehl im PROJECT_ROOT aus
            await executeCommand(command, '', PROJECT_ROOT);
            
            res.json({ 
                success: true, 
                message: `Instanz ${name} wird mit Dump "${dumpFile}" erstellt...`,
                type: 'import'
            });
        } else if (webserverOnly) {
            // Webserver-only Instanz (ohne REDAXO)
            let command = `./redaxo create ${name} --type webserver`;
            if (phpVersion) command += ` --php-version ${phpVersion}`;
            if (mariadbVersion) command += ` --mariadb-version ${mariadbVersion}`;
            
            await executeCommand(command);
            
            res.json({ 
                success: true, 
                message: `Webserver-Instanz ${name} wird erstellt...`,
                type: 'webserver'
            });
        } else {
            // Normale REDAXO-Instanz-Erstellung
            let command = `./redaxo create ${name}`;
            if (phpVersion) command += ` --php-version ${phpVersion}`;
            if (mariadbVersion) command += ` --mariadb-version ${mariadbVersion}`;
            if (autoInstall) command += ` --auto`;
            
            await executeCommand(command);
            
            res.json({ 
                success: true, 
                message: `REDAXO-Instanz ${name} wird erstellt...`,
                type: 'create'
            });
        }
        
        // Neue Instanz laden (etwas länger warten bei Import)
        const delay = importDump ? 5000 : 3000;
        setTimeout(async () => {
            const instances = await getInstances();
            io.emit('instancesUpdated', instances);
        }, delay);
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Instanz löschen
app.delete('/api/instances/:name', async (req, res) => {
    try {
        const { name } = req.params;
        
        // Erst stoppen, dann löschen
        await executeCommand(`./redaxo stop ${name}`);
        await executeCommand(`./redaxo remove ${name}`, 'y\n');
        
        // Aktualisierte Liste senden
        setTimeout(async () => {
            const instances = await getInstances();
            io.emit('instancesUpdated', instances);
        }, 2000);
        
        res.json({ success: true, message: `Instanz ${name} wurde gelöscht` });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Screenshot erstellen
app.post('/api/instances/:name/screenshot', async (req, res) => {
    try {
        const { name } = req.params;
        const instances = await getInstances();
        const instance = instances.find(i => i.name === name);
        
        if (!instance) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        if (!instance.running) {
            return res.status(400).json({ error: 'Instanz läuft nicht - Screenshot nur bei laufenden Instanzen möglich' });
        }
        
        const screenshotsDir = path.join(__dirname, 'public', 'screenshots');
        if (!fs.existsSync(screenshotsDir)) {
            fs.mkdirSync(screenshotsDir, { recursive: true });
        }
        
        const screenshotPath = path.join(screenshotsDir, `${name}.png`);
        
        // Puppeteer für Screenshot verwenden (falls installiert) oder Fallback
        try {
            const puppeteer = require('puppeteer');
            const browser = await puppeteer.launch({ 
                headless: true,
                args: [
                    '--no-sandbox', 
                    '--disable-setuid-sandbox', 
                    '--disable-dev-shm-usage',
                    '--ignore-certificate-errors',
                    '--ignore-ssl-errors',
                    '--ignore-certificate-errors-spki-list',
                    '--disable-web-security'
                ]
            });
            const page = await browser.newPage();
            await page.setViewport({ width: 1280, height: 720 });
            
            // Frontend-URL verwenden - erst HTTPS probieren, dann HTTP fallback
            let targetUrl = instance.frontendUrlHttps;
            try {
                await page.goto(targetUrl, { 
                    waitUntil: 'networkidle2',
                    timeout: 30000
                });
            } catch (httpsError) {
                console.warn('HTTPS fehlgeschlagen, versuche HTTP:', httpsError.message);
                targetUrl = instance.frontendUrl;
                await page.goto(targetUrl, { 
                    waitUntil: 'networkidle2',
                    timeout: 30000
                });
            }
            
            // Screenshot als Datei speichern
            await page.screenshot({ 
                path: screenshotPath,
                format: 'png'
            });
            
            await browser.close();
            
            res.json({ 
                success: true, 
                screenshot: `/screenshots/${name}.png?t=${Date.now()}`,
                timestamp: new Date().toISOString()
            });
        } catch (puppeteerError) {
            // Fallback: Placeholder-Screenshot erstellen
            console.warn('Puppeteer nicht verfügbar, verwende Fallback:', puppeteerError.message);
            
            // Erstelle ein einfaches Placeholder-Bild
            const placeholderPath = path.join(screenshotsDir, `${name}.png`);
            await createPlaceholderImage(placeholderPath, name, instance.frontendUrl);
            
            res.json({ 
                success: true, 
                screenshot: `/screenshots/${name}.png?t=${Date.now()}`,
                message: 'Placeholder erstellt - Puppeteer für echte Screenshots installieren: npm install puppeteer',
                url: instance.frontendUrl,
                timestamp: new Date().toISOString()
            });
        }
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Screenshot abrufen
app.get('/api/instances/:name/screenshot', (req, res) => {
    const { name } = req.params;
    const screenshotPath = path.join(__dirname, 'public', 'screenshots', `${name}.png`);
    
    if (fs.existsSync(screenshotPath)) {
        const stats = fs.statSync(screenshotPath);
        res.json({
            exists: true,
            url: `/screenshots/${name}.png?t=${stats.mtime.getTime()}`,
            timestamp: stats.mtime.toISOString()
        });
    } else {
        res.json({
            exists: false
        });
    }
});

// API: Verfügbare Dumps auflisten
app.get('/api/dumps', async (req, res) => {
    try {
        const dumpDir = path.join(__dirname, '..', 'dump');
        
        // Prüfe ob dump-Verzeichnis existiert
        if (!fs.existsSync(dumpDir)) {
            fs.mkdirSync(dumpDir, { recursive: true });
        }
        
        const files = await fs.promises.readdir(dumpDir);
        const dumps = files
            .filter(file => file.endsWith('.zip'))
            .map(file => {
                const filePath = path.join(dumpDir, file);
                const stats = fs.statSync(filePath);
                return {
                    name: file,
                    basename: path.basename(file, '.zip'),
                    size: formatFileSize(stats.size),
                    modified: stats.mtime.toISOString(),
                    path: file
                };
            })
            .sort((a, b) => new Date(b.modified) - new Date(a.modified));
        
        res.json(dumps);
    } catch (error) {
        console.error('Fehler beim Laden der Dumps:', error);
        res.status(500).json({ error: 'Fehler beim Laden der Dumps' });
    }
});

// API: Terminal öffnen
app.post('/api/terminal', async (req, res) => {
    try {
        const { instanceName } = req.body;
        
        if (!instanceName) {
            return res.status(400).json({ error: 'Instanz-Name fehlt' });
        }
        
        // Pfad zur Instanz
        const instancePath = path.join(INSTANCES_DIR, instanceName);
        
        // Prüfe ob Instanz existiert
        if (!fs.existsSync(instancePath)) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        // Erstelle ein Bash-Script für Docker Terminal
        const bashScript = `#!/bin/bash
cd "${instancePath}"
clear
echo "🐳 REDAXO Docker Terminal - Instanz: ${instanceName}"
echo "────────────────────────────────────────────────"
echo ""

# Prüfe ob Container läuft
if docker compose ps apache 2>/dev/null | grep -q "Up"; then
    echo "✅ Apache Container läuft - Verbinde mit PHP/Apache Container..."
    echo "📁 Arbeitsverzeichnis: /var/www/html"
    echo ""
    # Direkt in den Apache/PHP Container
    docker compose exec apache bash 2>/dev/null || docker compose exec apache sh
else
    echo "❌ Apache Container läuft nicht"
    echo ""
    echo "💡 Verfügbare Befehle:"
    echo "  docker compose up -d         # Container starten"
    echo "  docker compose down          # Container stoppen"  
    echo "  docker compose logs -f       # Logs anzeigen"
    echo "  docker compose exec apache bash  # In Apache Container einloggen"
    echo ""
    echo "Starte Container automatisch? (j/n)"
    read -n 1 answer
    if [[ \\$answer == "j" || \\$answer == "J" ]]; then
        echo ""
        echo "🚀 Starte Container..."
        docker compose up -d
        sleep 3
        echo "✅ Container gestartet - Verbinde mit Apache..."
        docker compose exec apache bash 2>/dev/null || docker compose exec apache sh
    fi
fi

# Lass Terminal offen
exec bash
`;
        
        // Schreibe das Script in eine temporäre Datei
        const scriptPath = path.join(instancePath, '.docker-terminal.sh');
        fs.writeFileSync(scriptPath, bashScript, { mode: 0o755 });
        
        // AppleScript für macOS Terminal
        const appleScript = `tell application "Terminal"
            do script "cd '${instancePath}' && ./.docker-terminal.sh"
            activate
        end tell`;
        
        // AppleScript ausführen
        const command = `osascript -e '${appleScript}'`;
        
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error('Terminal-Fehler:', error);
                return res.status(500).json({ error: 'Fehler beim Öffnen des Terminals' });
            }
            
            res.json({ 
                success: true, 
                message: `Docker Terminal für ${instanceName} geöffnet`,
                path: instancePath
            });
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: VS Code öffnen
app.post('/api/vscode', async (req, res) => {
    try {
        const { instanceName } = req.body;
        
        if (!instanceName) {
            return res.status(400).json({ error: 'Instanz-Name fehlt' });
        }
        
        // Pfad zur Instanz
        const instancePath = path.join(INSTANCES_DIR, instanceName, 'app');
        
        // Prüfe ob Instanz existiert
        if (!fs.existsSync(instancePath)) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        // VS Code öffnen - verwende verschiedene Methoden
        let command;
        
        // Methode 1: Über macOS open-Befehl (funktioniert immer wenn VS Code installiert ist)
        if (fs.existsSync('/Applications/Visual Studio Code.app')) {
            command = `open -a "Visual Studio Code" "${instancePath}"`;
        }
        // Methode 2: Über code-Befehl (falls verfügbar)
        else if (fs.existsSync('/usr/local/bin/code')) {
            command = `/usr/local/bin/code "${instancePath}"`;
        }
        // Methode 3: Direkter Pfad zur VS Code Binary
        else if (fs.existsSync('/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code')) {
            command = `"/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" "${instancePath}"`;
        }
        // Fallback: Versuche normalen code-Befehl
        else {
            command = `code "${instancePath}"`;
        }
        
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error('VS Code-Fehler:', error);
                
                // Prüfe ob VS Code installiert ist
                if (!fs.existsSync('/Applications/Visual Studio Code.app')) {
                    return res.status(500).json({ 
                        error: 'Visual Studio Code ist nicht installiert. Bitte installieren Sie VS Code von https://code.visualstudio.com' 
                    });
                } else {
                    return res.status(500).json({ 
                        error: 'Fehler beim Öffnen von VS Code. Versuchen Sie das Setup-Script auszuführen: ./setup.sh' 
                    });
                }
            }
            
            res.json({ 
                success: true, 
                message: `VS Code geöffnet für ${instanceName}`,
                path: instancePath
            });
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Im Finder öffnen
app.post('/api/finder', async (req, res) => {
    try {
        const { instanceName } = req.body;
        
        if (!instanceName) {
            return res.status(400).json({ error: 'Instanz-Name fehlt' });
        }
        
        // Pfad zur Instanz (app-Verzeichnis)
        const instancePath = path.join(INSTANCES_DIR, instanceName, 'app');
        
        // Prüfe ob Instanz existiert
        if (!fs.existsSync(instancePath)) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        // Finder mit dem app-Verzeichnis öffnen
        const command = `open "${instancePath}"`;
        
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error('Finder-Fehler:', error);
                return res.status(500).json({ 
                    error: 'Fehler beim Öffnen des Finders' 
                });
            }
            
            res.json({ 
                success: true, 
                message: `Finder geöffnet für ${instanceName}`,
                path: instancePath
            });
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: PHP/MariaDB-Versionen einer Instanz aktualisieren
app.post('/api/instances/:name/update-versions', async (req, res) => {
    try {
        const { name } = req.params;
        const { phpVersion, mariadbVersion } = req.body;
        
        if (!name) {
            return res.status(400).json({ error: 'Instanz-Name fehlt' });
        }
        
        if (!phpVersion && !mariadbVersion) {
            return res.status(400).json({ error: 'Mindestens eine Version muss angegeben werden' });
        }
        
        // Prüfe ob Instanz existiert
        const instancePath = path.join(INSTANCES_DIR, name);
        if (!fs.existsSync(instancePath)) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        // Baue den update-Befehl zusammen
        let command = `./redaxo update "${name}"`;
        
        if (phpVersion) {
            // Validiere PHP-Version
            const validPhpVersions = ['7.4', '8.0', '8.1', '8.2', '8.3', '8.4'];
            if (!validPhpVersions.includes(phpVersion)) {
                return res.status(400).json({ 
                    error: `Ungültige PHP-Version: ${phpVersion}. Verfügbar: ${validPhpVersions.join(', ')}` 
                });
            }
            command += ` --php-version ${phpVersion}`;
        }
        
        if (mariadbVersion) {
            // Validiere MariaDB-Version
            const validMariadbVersions = ['10.4', '10.5', '10.6', '10.11', '11.0', 'latest'];
            if (!validMariadbVersions.includes(mariadbVersion)) {
                return res.status(400).json({ 
                    error: `Ungültige MariaDB-Version: ${mariadbVersion}. Verfügbar: ${validMariadbVersions.join(', ')}` 
                });
            }
            command += ` --mariadb-version ${mariadbVersion}`;
        }
        
        console.log('Executing version update:', command);
        
        exec(command, { 
            cwd: PROJECT_ROOT, 
            timeout: 300000 // 5 Minuten Timeout
        }, (error, stdout, stderr) => {
            console.log('Version update completed');
            console.log('STDOUT:', stdout);
            console.log('STDERR:', stderr);
            console.log('ERROR:', error);
            
            if (error) {
                console.error('Version-Update-Fehler:', error);
                return res.status(500).json({ 
                    error: 'Fehler beim Aktualisieren der Versionen: ' + (stderr || error.message),
                    details: {
                        stdout: stdout,
                        stderr: stderr,
                        code: error.code
                    }
                });
            }
            
            res.json({ 
                success: true, 
                message: `Versionen für ${name} erfolgreich aktualisiert`,
                phpVersion: phpVersion || 'unverändert',
                mariadbVersion: mariadbVersion || 'unverändert',
                output: stdout
            });
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Im Finder öffnen
app.post('/api/finder', async (req, res) => {
    try {
        const { instanceName } = req.body;
        
        if (!instanceName) {
            return res.status(400).json({ error: 'Instanz-Name fehlt' });
        }
        
        // Pfad zur Instanz (app-Verzeichnis)
        const instancePath = path.join(INSTANCES_DIR, instanceName, 'app');
        
        // Prüfe ob Instanz existiert
        if (!fs.existsSync(instancePath)) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        // Finder mit dem app-Verzeichnis öffnen
        const command = `open "${instancePath}"`;
        
        exec(command, (error, stdout, stderr) => {
            if (error) {
                console.error('Finder-Fehler:', error);
                return res.status(500).json({ 
                    error: 'Fehler beim Öffnen des Finders' 
                });
            }
            
            res.json({ 
                success: true, 
                message: `Finder geöffnet für ${instanceName}`,
                path: instancePath
            });
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// API: Datenbankzugangsdaten abrufen
app.get('/api/instances/:name/database', async (req, res) => {
    try {
        const { name } = req.params;
        const instancePath = path.join(INSTANCES_DIR, name);
        const envPath = path.join(instancePath, '.env');
        
        if (!fs.existsSync(envPath)) {
            return res.status(404).json({ error: 'Instanz nicht gefunden' });
        }
        
        const envContent = fs.readFileSync(envPath, 'utf8');
        const envVars = parseEnvFile(envContent);
        
        res.json({
            host: 'localhost',
            database: envVars.MYSQL_DATABASE || 'N/A',
            user: envVars.MYSQL_USER || 'N/A',
            password: envVars.MYSQL_PASSWORD || 'N/A',
            rootPassword: envVars.MYSQL_ROOT_PASSWORD || 'N/A',
            phpmyadminPort: envVars.PHPMYADMIN_PORT || null,
            phpmyadminUrl: envVars.PHPMYADMIN_PORT ? `http://localhost:${envVars.PHPMYADMIN_PORT}` : null
        });
        
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

function stripAnsiCodes(str) {
    return str.replace(/\u001b\[[0-9;]*m/g, '');
}

// Hilfsfunktion für Dateigröße
function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Hilfsfunktionen
async function getInstances() {
    return new Promise((resolve, reject) => {
        if (!fs.existsSync(INSTANCES_DIR)) {
            return resolve([]);
        }
        
        fs.readdir(INSTANCES_DIR, async (err, dirs) => {
            if (err) return reject(err);
            
            const instances = [];
            
            for (const dir of dirs) {
                if (dir === '.gitkeep') continue;
                
                const instancePath = path.join(INSTANCES_DIR, dir);
                const envPath = path.join(instancePath, '.env');
                
                if (fs.existsSync(envPath)) {
                    const envContent = fs.readFileSync(envPath, 'utf8');
                    const envVars = parseEnvFile(envContent);
                    
                    const isRunning = await checkInstanceStatus(dir);
                    const containerInfo = await getContainerInfo(dir);
                    
                    instances.push({
                        name: dir,
                        running: isRunning,
                        httpPort: envVars.HTTP_PORT,
                        httpsPort: envVars.HTTPS_PORT,
                        phpmyadminPort: envVars.PHPMYADMIN_PORT || null,
                        mailpitPort: envVars.MAILPIT_PORT || null,
                        database: envVars.MYSQL_DATABASE || null,
                        phpVersion: containerInfo.phpVersion || envVars.PHP_VERSION || '8.4',
                        mariadbVersion: containerInfo.mariadbVersion || envVars.MARIADB_VERSION || 'latest',
                        port: envVars.HTTP_PORT,
                        frontendUrl: `http://localhost:${envVars.HTTP_PORT}`,
                        frontendUrlHttps: `https://localhost:${envVars.HTTPS_PORT}`,
                        backendUrl: `http://localhost:${envVars.HTTP_PORT}/redaxo/`,
                        backendUrlHttps: `https://localhost:${envVars.HTTPS_PORT}/redaxo/`,
                        phpmyadminUrl: envVars.PHPMYADMIN_PORT ? `http://localhost:${envVars.PHPMYADMIN_PORT}` : null,
                        mailpitUrl: envVars.MAILPIT_PORT ? `http://localhost:${envVars.MAILPIT_PORT}` : null
                    });
                }
            }
            
            resolve(instances);
        });
    });
}

function parseEnvFile(content) {
    const vars = {};
    content.split('\n').forEach(line => {
        // Ignoriere Kommentare und leere Zeilen
        line = line.trim();
        if (line && !line.startsWith('#')) {
            const equalIndex = line.indexOf('=');
            if (equalIndex > 0) {
                const key = line.substring(0, equalIndex).trim();
                const value = line.substring(equalIndex + 1).trim();
                // Entferne Anführungszeichen falls vorhanden
                vars[key] = value.replace(/^["']|["']$/g, '');
            }
        }
    });
    return vars;
}

async function checkInstanceStatus(name) {
    return new Promise((resolve) => {
        // Prüfe sowohl REDAXO- als auch Webserver-Container
        const checkRedaxo = `docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"`;
        const checkWebserver = `docker ps --format "table {{.Names}}" | grep -q "webserver-${name}-apache"`;
        
        exec(checkRedaxo, (error1) => {
            if (error1 === null) {
                // REDAXO-Container läuft
                resolve(true);
            } else {
                // Prüfe Webserver-Container
                exec(checkWebserver, (error2) => {
                    resolve(error2 === null);
                });
            }
        });
    });
}

async function executeCommand(command, input = '', workingDir = PROJECT_ROOT) {
    return new Promise((resolve, reject) => {
        const childProcess = exec(command, { cwd: workingDir }, (error, stdout, stderr) => {
            if (error) {
                reject(new Error(stderr || error.message));
            } else {
                resolve(stdout);
            }
        });
        
        if (input) {
            childProcess.stdin.write(input);
            childProcess.stdin.end();
        }
    });
}

async function getContainerInfo(instanceName) {
    try {
        // Erkenne Container-Typ (REDAXO oder Webserver)
        const checkRedaxo = `docker ps --format "table {{.Names}}" | grep -q "redaxo-${instanceName}-apache"`;
        const isRedaxo = await new Promise((resolve) => {
            exec(checkRedaxo, (error) => resolve(error === null));
        });
        
        const containerPrefix = isRedaxo ? 'redaxo' : 'webserver';
        
        // PHP Version aus Container abfragen
        const phpVersionCmd = `docker exec ${containerPrefix}-${instanceName}-apache php -v 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'Unknown'`;
        const mariadbVersionCmd = `docker exec ${containerPrefix}-${instanceName}-mariadb mariadb --version 2>/dev/null | cut -d' ' -f5 | cut -d'-' -f1 || echo 'Unknown'`;
        
        const [phpVersion, mariadbVersion] = await Promise.allSettled([
            executeCommand(phpVersionCmd),
            executeCommand(mariadbVersionCmd)
        ]);
        
        return {
            phpVersion: phpVersion.status === 'fulfilled' ? phpVersion.value.trim() : 'Unknown',
            mariadbVersion: mariadbVersion.status === 'fulfilled' ? mariadbVersion.value.trim() : 'Unknown'
        };
    } catch (error) {
        console.warn(`Warnung: Container-Info für ${instanceName} konnte nicht abgerufen werden:`, error.message);
        return {
            phpVersion: 'Unknown',
            mariadbVersion: 'Unknown'
        };
    }
}

async function createPlaceholderImage(imagePath, instanceName, url) {
    // Erstelle ein einfaches SVG als Placeholder
    const svgContent = `
        <svg width="400" height="240" xmlns="http://www.w3.org/2000/svg">
            <defs>
                <linearGradient id="grad1" x1="0%" y1="0%" x2="100%" y2="100%">
                    <stop offset="0%" style="stop-color:#4f7df3;stop-opacity:1" />
                    <stop offset="100%" style="stop-color:#6b7df5;stop-opacity:1" />
                </linearGradient>
            </defs>
            <rect width="100%" height="100%" fill="url(#grad1)"/>
            <text x="50%" y="40%" dominant-baseline="middle" text-anchor="middle" fill="white" font-family="Arial, sans-serif" font-size="24" font-weight="bold">REDAXO</text>
            <text x="50%" y="55%" dominant-baseline="middle" text-anchor="middle" fill="rgba(255,255,255,0.9)" font-family="Arial, sans-serif" font-size="16">${instanceName}</text>
            <text x="50%" y="70%" dominant-baseline="middle" text-anchor="middle" fill="rgba(255,255,255,0.7)" font-family="Arial, sans-serif" font-size="12">${url}</text>
            <text x="50%" y="85%" dominant-baseline="middle" text-anchor="middle" fill="rgba(255,255,255,0.6)" font-family="Arial, sans-serif" font-size="10">Screenshot nicht verfügbar</text>
        </svg>
    `;
    
    try {
        // Versuche sharp für SVG zu PNG Konvertierung zu verwenden
        const sharp = require('sharp');
        await sharp(Buffer.from(svgContent))
            .png()
            .toFile(imagePath);
    } catch (sharpError) {
        // Fallback: Speichere SVG als .svg Datei
        const svgPath = imagePath.replace('.png', '.svg');
        fs.writeFileSync(svgPath, svgContent);
        
        // Erstelle eine einfache HTML-Datei als Fallback
        const htmlContent = `
            <!DOCTYPE html>
            <html><head><style>
                body { margin: 0; width: 400px; height: 240px; background: linear-gradient(135deg, #4f7df3, #6b7df5); 
                       display: flex; flex-direction: column; justify-content: center; align-items: center; 
                       font-family: Arial, sans-serif; color: white; }
                .title { font-size: 24px; font-weight: bold; margin-bottom: 10px; }
                .instance { font-size: 16px; margin-bottom: 5px; }
                .url { font-size: 12px; opacity: 0.7; margin-bottom: 10px; }
                .note { font-size: 10px; opacity: 0.6; }
            </style></head><body>
                <div class="title">REDAXO</div>
                <div class="instance">${instanceName}</div>
                <div class="url">${url}</div>
                <div class="note">Screenshot nicht verfügbar</div>
            </body></html>
        `;
        
        // Als einfache PNG-Alternative speichere eine Textdatei
        fs.writeFileSync(imagePath.replace('.png', '.html'), htmlContent);
        
        // Erstelle leere PNG-Datei
        fs.writeFileSync(imagePath, Buffer.alloc(0));
    }
}

// Socket.IO für Live-Updates
io.on('connection', (socket) => {
    console.log('Client verbunden');
    
    socket.on('disconnect', () => {
        console.log('Client getrennt');
    });
});

// Periodische Updates
setInterval(async () => {
    try {
        const instances = await getInstances();
        io.emit('instancesUpdated', instances);
    } catch (error) {
        console.error('Fehler beim Aktualisieren der Instanzen:', error);
    }
}, 10000); // Alle 10 Sekunden

// Serve main page
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

server.listen(PORT, () => {
    console.log(`REDAXO Dashboard läuft auf http://localhost:${PORT}`);
    console.log('Drücke Ctrl+C zum Beenden');
});
