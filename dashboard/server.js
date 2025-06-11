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

// API: Neue Instanz erstellen
app.post('/api/instances', async (req, res) => {
    try {
        const { name, phpVersion, mariadbVersion, autoInstall, importDump, dumpFile } = req.body;
        
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
        } else {
            // Normale Instanz-Erstellung
            let command = `./redaxo create ${name}`;
            if (phpVersion) command += ` --php-version ${phpVersion}`;
            if (mariadbVersion) command += ` --mariadb-version ${mariadbVersion}`;
            if (autoInstall) command += ` --auto`;
            
            await executeCommand(command);
            
            res.json({ 
                success: true, 
                message: `Instanz ${name} wird erstellt...`,
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
        const match = line.match(/^([^#=]+)=(.*)$/);
        if (match) {
            vars[match[1].trim()] = match[2].trim();
        }
    });
    return vars;
}

async function checkInstanceStatus(name) {
    return new Promise((resolve) => {
        exec(`docker ps --format "table {{.Names}}" | grep -q "redaxo-${name}-apache"`, (error) => {
            resolve(error === null);
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
        // PHP Version aus Container abfragen
        const phpVersionCmd = `docker exec redaxo-${instanceName}-apache php -v 2>/dev/null | head -n1 | cut -d' ' -f2 || echo 'Unknown'`;
        const mariadbVersionCmd = `docker exec redaxo-${instanceName}-mariadb mariadb --version 2>/dev/null | cut -d' ' -f5 | cut -d'-' -f1 || echo 'Unknown'`;
        
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
