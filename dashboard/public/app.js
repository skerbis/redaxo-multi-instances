// REDAXO Dashboard JavaScript
class RedaxoDashboard {
    constructor() {
        this.socket = io();
        this.instances = [];
        this.deleteTarget = null;
        this.creatingInstances = new Set(); // Tracking für erstellende Instanzen
        this.config = null; // Konfiguration vom Server
        this.init();
    }

    async init() {
        await this.loadConfig();
        this.loadInstances();
        this.setupSocketListeners();
        this.setupEventListeners();
    }

    async loadConfig() {
        try {
            const response = await fetch('/api/config');
            if (response.ok) {
                this.config = await response.json();
            } else {
                console.warn('Konfiguration konnte nicht geladen werden');
                this.config = { projectRoot: '', instancesDir: '', features: {} };
            }
        } catch (error) {
            console.error('Fehler beim Laden der Konfiguration:', error);
            this.config = { projectRoot: '', instancesDir: '', features: {} };
        }
    }

    setupSocketListeners() {
        this.socket.on('instancesUpdated', (instances) => {
            this.instances = instances;
            this.renderInstances();
            
            // Prüfe ob erstellende Instanzen jetzt verfügbar sind
            this.creatingInstances.forEach(name => {
                const instance = instances.find(i => i.name === name);
                if (instance) {
                    this.creatingInstances.delete(name);
                    this.showToast(`Instanz ${name} wurde erfolgreich erstellt`, 'success');
                }
            });
        });

        this.socket.on('instanceUpdated', (instance) => {
            const index = this.instances.findIndex(i => i.name === instance.name);
            if (index !== -1) {
                this.instances[index] = instance;
                this.renderInstances();
            }
        });
    }

    setupEventListeners() {
        // Create instance form
        document.getElementById('createInstanceForm').addEventListener('submit', (e) => {
            e.preventDefault();
            this.createInstance();
        });

        // Close modals on backdrop click
        document.getElementById('createModal').addEventListener('click', (e) => {
            if (e.target.id === 'createModal') {
                this.hideCreateModal();
            }
        });

        document.getElementById('deleteModal').addEventListener('click', (e) => {
            if (e.target.id === 'deleteModal') {
                this.hideDeleteModal();
            }
        });

        document.getElementById('backupModal').addEventListener('click', (e) => {
            if (e.target.id === 'backupModal') {
                this.hideBackupModal();
            }
        });

        // Schließe Popovers beim Klicken außerhalb
        document.addEventListener('click', (event) => {
            if (!event.target.closest('.url-popover')) {
                document.querySelectorAll('.url-popover.open').forEach(popover => {
                    popover.classList.remove('open');
                });
            }
        });

        // Dump-Auswahl Toggle
        document.getElementById('importDump').addEventListener('change', () => {
            this.toggleDumpSelection();
        });

        // Webserver-only Toggle
        document.getElementById('webserverOnly').addEventListener('change', () => {
            this.toggleWebserverOnly();
        });
    }

    async loadInstances() {
        try {
            const response = await fetch('/api/instances');
            const instances = await response.json();
            this.instances = instances;
            this.renderInstances();
        } catch (error) {
            console.error('Fehler beim Laden der Instanzen:', error);
            this.showToast('Fehler beim Laden der Instanzen', 'error');
        }
    }

    renderInstances() {
        const grid = document.getElementById('instancesGrid');
        
        // Erstelle Gesamt-Liste aus echten Instanzen + erstellenden Instanzen
        const allInstances = [...this.instances];
        
        // Füge erstellende Instanzen hinzu (falls sie noch nicht in der echten Liste sind)
        this.creatingInstances.forEach(name => {
            if (!this.instances.find(i => i.name === name)) {
                allInstances.push({
                    name: name,
                    running: false,
                    creating: true,
                    status: 'creating'
                });
            }
        });
        
        if (allInstances.length === 0) {
            grid.innerHTML = `
                <div class="empty-state glass-card">
                    <h2><i class="fas fa-server"></i> Noch keine Instanzen vorhanden</h2>
                    <p>Erstellen Sie Ihre erste REDAXO-Instanz um zu beginnen</p>
                    <button class="glass-button primary" onclick="dashboard.showCreateModal()">
                        <i class="fas fa-plus"></i>
                        Erste Instanz erstellen
                    </button>
                </div>
            `;
            return;
        }

        grid.innerHTML = allInstances.map(instance => this.renderInstanceCard(instance)).join('');
        
        // Für alle echten Instanzen prüfen, ob Screenshots vorhanden sind und diese laden
        this.instances.forEach(instance => {
            this.loadExistingScreenshot(instance.name);
        });
    }

    async loadExistingScreenshot(instanceName) {
        try {
            const response = await fetch(`/api/instances/${instanceName}/screenshot`);
            const result = await response.json();
            
            const preview = document.getElementById(`screenshot-preview-${instanceName}`);
            if (!preview) return;
            
            if (result.exists) {
                // Screenshot existiert, lade es
                const instance = this.instances.find(i => i.name === instanceName);
                const statusIcon = instance && !instance.running ? 
                    '<i class="fas fa-pause-circle" style="position: absolute; top: 4px; right: 4px; color: rgba(245, 158, 11, 0.8); font-size: 16px; text-shadow: 0 1px 2px rgba(0,0,0,0.5);"></i>' : '';
                
                preview.innerHTML = `
                    <div style="position: relative;">
                        <img src="${result.url}" alt="Screenshot von ${instanceName}" onclick="window.open('${result.url}', '_blank')" title="Klicken zum Vergrößern - Erstellt: ${new Date(result.timestamp).toLocaleString()}">
                        ${statusIcon}
                    </div>
                `;
                preview.classList.add('show');
            } else {
                // Kein Screenshot vorhanden - zeige Placeholder
                preview.classList.add('show');
            }
        } catch (error) {
            console.warn('Fehler beim Laden des Screenshots:', error);
        }
    }

    renderInstanceCard(instance) {
        // Unterscheide zwischen echten Instanzen und erstellenden
        const isCreating = this.creatingInstances.has(instance.name);
        
        let statusClass, statusText, statusIcon;
        
        if (isCreating) {
            statusClass = 'creating';
            statusText = 'Wird erstellt...';
            statusIcon = '<i class="fas fa-spinner fa-spin text-primary"></i>';
        } else if (instance.running) {
            statusClass = 'running';
            statusText = 'Läuft';
            statusIcon = '<i class="fas fa-circle text-success"></i>';
        } else {
            statusClass = 'stopped';
            statusText = 'Gestoppt';
            statusIcon = '<i class="fas fa-circle text-warning"></i>';
        }

        return `
        <div class="instance-card glass-card ${statusClass}">
            <div class="instance-content">
                <div class="instance-header">
                    <div>
                        <h3 class="instance-name">${instance.name}</h3>
                        <div class="instance-status ${statusClass}">
                            <span class="status-dot"></span>
                            ${statusIcon} ${statusText}
                        </div>
                    </div>
                    ${!isCreating ? `
                    <div class="instance-menu">
                        <div class="url-popover" id="popover-${instance.name}">
                            <button class="url-menu-trigger" onclick="dashboard.toggleUrlPopover('${instance.name}')" title="URLs & Services">
                                <i class="fas fa-ellipsis-v"></i>
                            </button>
                            <div class="url-popover-menu">
                                <a href="${instance.frontendUrl}" target="_blank" class="url-link">
                                    <i class="fas fa-home"></i> Frontend (HTTP)
                                </a>
                                <a href="${instance.frontendUrlHttps}" target="_blank" class="url-link">
                                    <i class="fas fa-lock"></i> Frontend (HTTPS)
                                </a>
                                <a href="${instance.backendUrl}" target="_blank" class="url-link">
                                    <i class="fas fa-cogs"></i> Backend (HTTP)
                                </a>
                                <a href="${instance.backendUrlHttps}" target="_blank" class="url-link">
                                    <i class="fas fa-shield-alt"></i> Backend (HTTPS)
                                </a>
                                ${instance.phpmyadminUrl ? `
                                    <a href="${instance.phpmyadminUrl}" target="_blank" class="url-link">
                                        <i class="fas fa-database"></i> phpMyAdmin
                                    </a>
                                ` : ''}
                                <button class="url-link" onclick="console.log('DB Info clicked for:', '${instance.name}'); window.dashboard.showDatabaseInfo('${instance.name}')" style="width: 100%; text-align: left; background: none; border: none; color: rgba(255,255,255,0.9); padding: 0.75rem; cursor: pointer; display: flex; align-items: center; gap: 0.75rem; transition: all 0.2s ease;" onmouseover="this.style.backgroundColor='rgba(255,255,255,0.1)'" onmouseout="this.style.backgroundColor='transparent'">
                                    <i class="fas fa-key"></i> Zugangsdaten
                                </button>
                                ${instance.mailpitUrl ? `
                                    <a href="${instance.mailpitUrl}" target="_blank" class="url-link">
                                        <i class="fas fa-envelope"></i> Mailpit
                                    </a>
                                ` : ''}
                                <button class="url-link" onclick="window.dashboard.openVSCode('${instance.name}')" style="width: 100%; text-align: left; background: none; border: none; color: rgba(255,255,255,0.9); padding: 0.75rem; cursor: pointer; display: flex; align-items: center; gap: 0.75rem; transition: all 0.2s ease;" onmouseover="this.style.backgroundColor='rgba(255,255,255,0.1)'" onmouseout="this.style.backgroundColor='transparent'">
                                    <i class="fab fa-microsoft"></i> VS Code öffnen
                                </button>
                                <button class="url-link" onclick="window.dashboard.openInFinder('${instance.name}')" style="width: 100%; text-align: left; background: none; border: none; color: rgba(255,255,255,0.9); padding: 0.75rem; cursor: pointer; display: flex; align-items: center; gap: 0.75rem; transition: all 0.2s ease;" onmouseover="this.style.backgroundColor='rgba(255,255,255,0.1)'" onmouseout="this.style.backgroundColor='transparent'">
                                    <i class="fas fa-folder-open"></i> Im Finder öffnen
                                </button>
                                ${this.config && this.config.features.terminalIntegration !== false ? `
                                    <button class="url-link" onclick="window.dashboard.openTerminal('${instance.name}')" style="width: 100%; text-align: left; background: none; border: none; color: rgba(255,255,255,0.9); padding: 0.75rem; cursor: pointer; display: flex; align-items: center; gap: 0.75rem; transition: all 0.2s ease;" onmouseover="this.style.backgroundColor='rgba(255,255,255,0.1)'" onmouseout="this.style.backgroundColor='transparent'">
                                        <i class="fas fa-terminal"></i> Docker Terminal
                                    </button>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                    ` : ''}
                </div>
                
                ${!isCreating ? `
                <div class="instance-info">
                    <div class="instance-details">
                        <div class="detail-item">
                            <div class="detail-label">PHP Version</div>
                            <div class="detail-value">
                                <button onclick="window.dashboard.showVersionUpdate('${instance.name}', 'php', '${instance.phpVersion || 'N/A'}')" class="version-button" title="PHP-Version ändern">
                                    <i class="fab fa-php"></i>
                                    ${instance.phpVersion || 'N/A'}
                                    <i class="fas fa-edit version-edit-icon"></i>
                                </button>
                            </div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">MariaDB</div>
                            <div class="detail-value">
                                <button onclick="window.dashboard.showVersionUpdate('${instance.name}', 'mariadb', '${instance.mariadbVersion || 'N/A'}')" class="version-button" title="MariaDB-Version ändern">
                                    <i class="fas fa-database"></i>
                                    ${instance.mariadbVersion || 'N/A'}
                                    <i class="fas fa-edit version-edit-icon"></i>
                                </button>
                            </div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Container Status</div>
                            <div class="detail-value ${instance.running ? 'status-healthy' : 'status-unhealthy'}">
                                <i class="fas fa-${instance.running ? 'check-circle' : 'times-circle'}"></i>
                                ${instance.running ? 'Healthy' : 'Stopped'}
                            </div>
                        </div>
                        <div class="detail-item">
                            <div class="detail-label">Port</div>
                            <div class="detail-value">
                                <i class="fas fa-network-wired"></i>
                                ${instance.port || 'Auto'}
                            </div>
                        </div>
                    </div>
                    
                    <div class="screenshot-section">
                        <div class="screenshot-preview show" id="screenshot-preview-${instance.name}" onclick="dashboard.takeScreenshot('${instance.name}')" style="cursor: pointer;">
                            <div style="padding: 1rem; text-align: center; color: rgba(255,255,255,0.6); font-size: 0.8rem;">
                                <i class="fas fa-image" style="margin-bottom: 0.5rem; font-size: 1.5rem; opacity: 0.5;"></i>
                                <div>Klicken Sie hier für Screenshot</div>
                            </div>
                        </div>
                        ${instance.running ? `
                            <button class="screenshot-trigger" onclick="dashboard.takeScreenshot('${instance.name}')" id="screenshot-btn-${instance.name}">
                                <i class="fas fa-camera"></i>
                                Screenshot aktualisieren
                            </button>
                        ` : `
                            <button class="screenshot-trigger" onclick="dashboard.showToast('Instanz muss laufen für neuen Screenshot', 'warning')" style="opacity: 0.5; cursor: not-allowed;">
                                <i class="fas fa-camera"></i>
                                Screenshot (nur bei laufender Instanz)
                            </button>
                        `}
                    </div>
                </div>
                ` : `
                <div class="instance-info">
                    <div style="text-align: center; padding: 2rem; color: rgba(255,255,255,0.7);">
                        <div style="margin-bottom: 1rem;">
                            <i class="fas fa-cogs fa-2x fa-spin" style="color: var(--primary-color);"></i>
                        </div>
                        <div style="font-size: 0.9rem;">Die Instanz wird erstellt...</div>
                        <div style="font-size: 0.75rem; margin-top: 0.5rem; opacity: 0.6;">
                            Dies kann je nach Art 1-5 Minuten dauern
                        </div>
                    </div>
                </div>
                `}
            </div>
            
            ${!isCreating ? `
            <div class="instance-controls">
                ${instance.running ? `
                    <button class="control-button glass-button warning" onclick="dashboard.stopInstance('${instance.name}')">
                        <i class="fas fa-stop"></i>
                        Stoppen
                    </button>
                ` : `
                    <button class="control-button glass-button success" onclick="dashboard.startInstance('${instance.name}')">
                        <i class="fas fa-play"></i>
                        Starten
                    </button>
                `}
                <button class="control-button glass-button danger" onclick="dashboard.showDeleteModal('${instance.name}')">
                    <i class="fas fa-trash"></i>
                    Löschen
                </button>
                <button class="control-button glass-button" onclick="dashboard.createSnapshot('${instance.name}')">
                    <i class="fas fa-save"></i> Snapshot anlegen
                </button>
                <button class="control-button glass-button" onclick="dashboard.recoverSnapshot('${instance.name}')" ${!instance.hasSnapshot ? 'disabled style="opacity:0.5;cursor:not-allowed;"' : ''}>
                    <i class="fas fa-history"></i> Snapshot wiederherstellen
                </button>
            </div>
            ` : `
            <div class="instance-controls">
                <button class="control-button glass-button secondary" disabled style="opacity: 0.5; cursor: not-allowed;">
                    <i class="fas fa-clock"></i>
                    Wird erstellt...
                </button>
            </div>
            `}
        </div>
    `;
    }

    async startInstance(name) {
        try {
            this.showToast(`Starte Instanz ${name}...`, 'success');
            
            const response = await fetch(`/api/instances/${name}/start`, {
                method: 'POST'
            });
            
            const result = await response.json();
            
            if (response.ok) {
                this.showToast(result.message, 'success');
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            console.error('Fehler beim Starten der Instanz:', error);
            this.showToast(`Fehler beim Starten: ${error.message}`, 'error');
        }
    }

    async stopInstance(name) {
        try {
            this.showToast(`Stoppe Instanz ${name}...`, 'warning');
            
            const response = await fetch(`/api/instances/${name}/stop`, {
                method: 'POST'
            });
            
            const result = await response.json();
            
            if (response.ok) {
                this.showToast(result.message, 'success');
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            console.error('Fehler beim Stoppen der Instanz:', error);
            this.showToast(`Fehler beim Stoppen: ${error.message}`, 'error');
        }
    }

    async createInstance() {
        const form = document.getElementById('createInstanceForm');
        const formData = new FormData(form);
        
        const instanceData = {
            name: formData.get('name'),
            phpVersion: formData.get('phpVersion'),
            mariadbVersion: formData.get('mariadbVersion'),
            autoInstall: formData.get('autoInstall') === 'on',
            importDump: formData.get('importDump') === 'on',
            webserverOnly: formData.get('webserverOnly') === 'on',
            dumpFile: formData.get('dumpFile')
        };

        try {
            // Validierung
            if (instanceData.importDump && !instanceData.dumpFile) {
                this.showToast('Bitte wählen Sie eine Dump-Datei aus', 'error');
                return;
            }

            const message = instanceData.importDump 
                ? `Erstelle Instanz ${instanceData.name} mit Dump-Import...`
                : instanceData.webserverOnly
                    ? `Erstelle Webserver-Instanz ${instanceData.name}...`
                    : `Erstelle REDAXO-Instanz ${instanceData.name}...`;
                
            this.showToast(message, 'success');
            this.hideCreateModal();
            
            // Instanz zu "erstellenden" Liste hinzufügen
            this.creatingInstances.add(instanceData.name);
            this.renderInstances(); // Sofort neu rendern um "wird erstellt" anzuzeigen
            
            const response = await fetch('/api/instances', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify(instanceData)
            });
            
            const result = await response.json();
            
            if (response.ok) {
                const successMessage = result.type === 'import'
                    ? `${result.message} (Import kann 3-5 Minuten dauern)`
                    : result.message;
                this.showToast(successMessage, 'success');
                form.reset();
                
                // Reset alle Optionen
                document.getElementById('dumpSelection').classList.remove('show');
                document.getElementById('autoInstall').disabled = false;
                document.getElementById('autoInstall').checked = true;
                document.getElementById('webserverOnly').disabled = false;
                document.getElementById('webserverOnly').checked = false;
                document.getElementById('importDump').disabled = false;
                document.getElementById('importDump').checked = false;
            } else {
                // Fehler: Aus "erstellenden" Liste entfernen
                this.creatingInstances.delete(instanceData.name);
                this.renderInstances();
                throw new Error(result.error);
            }
        } catch (error) {
            console.error('Fehler beim Erstellen der Instanz:', error);
            this.creatingInstances.delete(instanceData.name);
            this.renderInstances();
            this.showToast(`Fehler beim Erstellen: ${error.message}`, 'error');
        }
    }

    async deleteInstance(name) {
        try {
            this.showToast(`Lösche Instanz ${name}...`, 'warning');
            
            const response = await fetch(`/api/instances/${name}`, {
                method: 'DELETE'
            });
            
            const result = await response.json();
            
            if (response.ok) {
                this.showToast(result.message, 'success');
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            console.error('Fehler beim Löschen der Instanz:', error);
            this.showToast(`Fehler beim Löschen: ${error.message}`, 'error');
        }
    }

    async openTerminal(instanceName) {
        try {
            const response = await fetch('/api/terminal', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ 
                    instanceName: instanceName 
                }),
            });
            
            if (response.ok) {
                const result = await response.json();
                if (result.success) {
                    this.showToast(`Docker Terminal für ${instanceName} geöffnet`, 'success');
                } else {
                    throw new Error(result.error || 'Terminal konnte nicht geöffnet werden');
                }
            } else {
                throw new Error('Terminal konnte nicht geöffnet werden');
            }
        } catch (error) {
            console.error('Fehler beim Öffnen des Terminals:', error);
            this.showToast(`Fehler beim Terminal: ${error.message}`, 'error');
        }
    }

    async openVSCode(instanceName) {
        try {
            const response = await fetch('/api/vscode', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ 
                    instanceName: instanceName 
                }),
            });
            
            if (response.ok) {
                const result = await response.json();
                if (result.success) {
                    this.showToast(`VS Code für ${instanceName} geöffnet`, 'success');
                } else {
                    throw new Error(result.error || 'VS Code konnte nicht geöffnet werden');
                }
            } else {
                const errorData = await response.json();
                throw new Error(errorData.error || 'VS Code konnte nicht geöffnet werden');
            }
        } catch (error) {
            console.error('Fehler beim Öffnen von VS Code:', error);
            this.showToast(`Fehler beim Öffnen von VS Code: ${error.message}`, 'error');
        }
    }

    async openInFinder(instanceName) {
        try {
            const response = await fetch('/api/finder', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ 
                    instanceName: instanceName 
                }),
            });
            
            if (response.ok) {
                const result = await response.json();
                if (result.success) {
                    this.showToast(`Finder für ${instanceName} geöffnet`, 'success');
                } else {
                    throw new Error(result.error || 'Finder konnte nicht geöffnet werden');
                }
            } else {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Finder konnte nicht geöffnet werden');
            }
        } catch (error) {
            console.error('Fehler beim Öffnen des Finders:', error);
            this.showToast(`Fehler beim Öffnen des Finders: ${error.message}`, 'error');
        }
    }

    async showDatabaseInfo(instanceName) {
        console.log('showDatabaseInfo called with:', instanceName);
        try {
            console.log('Fetching database info...');
            const response = await fetch(`/api/instances/${instanceName}/database`);
            console.log('Response status:', response.status);
            
            if (response.ok) {
                const dbInfo = await response.json();
                
                // Modal für DB-Info erstellen
                const modal = document.createElement('div');
                modal.className = 'modal-backdrop';
                modal.innerHTML = `
                    <div class="modal glass-card">
                        <div class="modal-header">
                            <h2><i class="fas fa-key"></i> Zugangsdaten – ${instanceName}</h2>
                            <button class="close-button" onclick="this.closest('.modal-backdrop').classList.remove('show'); setTimeout(() => this.closest('.modal-backdrop').remove(), 300);">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                        <div class="modal-body">
                            <div class="info-text" style="margin-bottom:2rem;">
                                <i class="fas fa-info-circle"></i> <b>Hinweis:</b> Im Docker-Container lautet der Host meist <code>mariadb</code>.<br>
                                Für automatisch angelegte REDAXO-Instanzen lauten die Zugangsdaten:<br>
                                <span style="display:inline-block;margin-top:0.25em;margin-bottom:0.5em;padding:0.25em 0.75em;background:rgba(79,125,243,0.08);border-radius:6px;font-size:1.05em;">
                                  <b>Benutzer:</b> <code>admin</code> &nbsp; <b>Passwort:</b> <code>admin123</code>
                                </span>
                            </div>
                            <div class="db-info-glass-list" style="display:grid;gap:1.2rem;">
                                ${[
                                  {label: "<i class='fas fa-server'></i> Host", value: dbInfo.host},
                                  {label: "<i class='fas fa-database'></i> Datenbank", value: dbInfo.database},
                                  {label: "<i class='fas fa-user'></i> Benutzer", value: dbInfo.user},
                                  {label: "<i class='fas fa-lock'></i> Passwort", value: dbInfo.password},
                                  {label: "<i class='fas fa-user-shield'></i> Root-Passwort", value: dbInfo.rootPassword}
                                ].map(item => `
                                  <div class='glass-list-item' style="display:flex;align-items:center;gap:1rem;background:rgba(255,255,255,0.07);border-radius:10px;padding:1rem 1.2rem;box-shadow:0 2px 8px 0 rgba(79,125,243,0.07);border:1px solid rgba(255,255,255,0.13);">
                                    <span style="min-width:140px;font-weight:500;">${item.label}:</span>
                                    <span style="flex:1;font-family:monospace;font-size:1.08em;word-break:break-all;">${item.value}</span>
                                    <button onclick="navigator.clipboard.writeText('${item.value}')" title="Kopieren" style="margin-left:0.5rem;background:rgba(79,125,243,0.13);border:none;border-radius:6px;padding:0.4em 0.7em;cursor:pointer;transition:background 0.2s;"><i class="fas fa-copy"></i></button>
                                  </div>
                                `).join('')}
                                ${dbInfo.phpmyadminUrl ? `
                                  <div class='glass-list-item' style="display:flex;align-items:center;gap:1rem;background:rgba(255,255,255,0.07);border-radius:10px;padding:1rem 1.2rem;box-shadow:0 2px 8px 0 rgba(79,125,243,0.07);border:1px solid rgba(255,255,255,0.13);">
                                    <span style="min-width:140px;font-weight:500;"><i class='fas fa-database'></i> phpMyAdmin:</span>
                                    <span style="flex:1;overflow-wrap:anywhere;">
                                      <button onclick="window.open('${dbInfo.phpmyadminUrl}', '_blank')" class="glass-button secondary" style="margin:0;padding:0.5rem 1rem;font-size:0.95em;">
                                        <i class="fas fa-external-link-alt"></i> ${dbInfo.phpmyadminUrl}
                                      </button>
                                      <small style="display:block;color:rgba(255,255,255,0.7);margin-top:4px;"><i class="fas fa-info-circle"></i> Läuft mit Root-Berechtigung</small>
                                    </span>
                                  </div>
                                ` : ''}
                            </div>
                            <div class="modal-footer" style="margin-top:2.5rem;">
                                <button type="button" class="glass-button secondary" onclick="this.closest('.modal-backdrop').classList.remove('show'); setTimeout(() => this.closest('.modal-backdrop').remove(), 300);">
                                    Schließen
                                </button>
                                ${dbInfo.phpmyadminUrl ? `
                                <button onclick="window.open('${dbInfo.phpmyadminUrl}', '_blank')" class="glass-button primary">
                                    <i class="fas fa-external-link-alt"></i>
                                    phpMyAdmin öffnen
                                </button>
                                ` : ''}
                            </div>
                        </div>
                    </div>
                `;
                
                // Modal zum Body hinzufügen
                console.log('Adding modal to body...');
                document.body.appendChild(modal);
                
                // Show-Klasse hinzufügen für Animation
                setTimeout(() => {
                    modal.classList.add('show');
                }, 10);
                console.log('Modal added successfully');
                
                // Click outside to close
                modal.addEventListener('click', (e) => {
                    if (e.target === modal) {
                        modal.classList.remove('show');
                        setTimeout(() => modal.remove(), 300);
                    }
                });
                
            } else {
                console.error('Response not ok:', response.status, response.statusText);
                const errorData = await response.json();
                console.error('Error data:', errorData);
                throw new Error(errorData.error || 'DB-Info konnte nicht geladen werden');
            }
        } catch (error) {
            console.error('Fehler beim Laden der DB-Info:', error);
            this.showToast(`Fehler beim Laden der DB-Info: ${error.message}`, 'error');
        }
    }

    async backupInstance(instanceName) {
        const button = document.querySelector(`#popover-${instanceName} button i.fa-save`).closest('button');
        const originalButtonHtml = button.innerHTML;

        try {
            button.disabled = true;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Backup läuft...';
            this.showToast(`Erstelle Backup für Instanz ${instanceName}...`, 'warning');

            const response = await fetch(`/api/instances/${instanceName}/backup`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({}),
            });
            const result = await response.json();
            if (response.ok) {
                this.showToast(result.message, 'success');
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            console.error('Fehler beim Erstellen des Backups:', error);
            this.showToast(`Fehler beim Backup: ${error.message}`, 'error');
        } finally {
            button.disabled = false;
            button.innerHTML = originalButtonHtml;
        }
    }

    async takeScreenshot(instanceName) {
        const button = document.getElementById(`screenshot-btn-${instanceName}`);
        const preview = document.getElementById(`screenshot-preview-${instanceName}`);
        
        if (!preview) return;
        
        // Überprüfe ob die Instanz läuft
        const instance = this.instances.find(i => i.name === instanceName);
        if (!instance || !instance.running) {
            this.showToast('Instanz muss laufen um einen Screenshot zu erstellen', 'warning');
            return;
        }
        
        // Button in Loading-Zustand versetzen (falls vorhanden)
        if (button) {
            button.classList.add('loading');
            button.innerHTML = '<i class="fas fa-spinner"></i> Erstelle Screenshot...';
        }
        
        try {
            const response = await fetch(`/api/instances/${instanceName}/screenshot`, {
                method: 'POST'
            });
            
            if (response.ok) {
                const result = await response.json();
                
                if (result.success && result.screenshot) {
                    // Screenshot als URL anzeigen (wird als Datei gespeichert)
                    preview.innerHTML = `
                        <div style="position: relative;">
                            <img src="${result.screenshot}" alt="Screenshot von ${instanceName}" onclick="window.open('${result.screenshot}', '_blank')" title="Klicken zum Vergrößern - Erstellt: ${new Date(result.timestamp).toLocaleString()}">
                        </div>
                    `;
                    preview.classList.add('show');
                    this.showToast('Screenshot erfolgreich erstellt', 'success');
                } else if (result.success && result.message) {
                    // Fallback wenn Puppeteer nicht verfügbar ist
                    preview.innerHTML = `
                        <div style="padding: 0.75rem; text-align: center; color: var(--text-white); opacity: 0.7; font-size: 0.75rem;">
                            <i class="fas fa-info-circle" style="margin-bottom: 0.25rem; font-size: 1rem;"></i>
                            <p style="margin: 0;">${result.message}</p>
                            <a href="${result.url}" target="_blank" style="color: var(--primary-color); text-decoration: none; font-size: 0.7rem;">
                                <i class="fas fa-external-link-alt"></i> Instanz öffnen
                            </a>
                        </div>
                    `;
                    preview.classList.add('show');
                    this.showToast(result.message, 'warning');
                } else {
                    throw new Error(result.error || 'Screenshot konnte nicht erstellt werden');
                }
            } else {
                throw new Error('Screenshot konnte nicht erstellt werden');
            }
        } catch (error) {
            console.error('Fehler beim Erstellen des Screenshots:', error);
            preview.innerHTML = `
                <div style="padding: 0.75rem; text-align: center; color: var(--danger-color); font-size: 0.75rem;">
                    <i class="fas fa-exclamation-triangle"></i>
                    <p style="margin: 0;">Screenshot fehlgeschlagen</p>
                </div>
            `;
            this.showToast(`Fehler beim Screenshot: ${error.message}`, 'error');
        } finally {
            // Button zurücksetzen (falls vorhanden)
            if (button) {
                button.classList.remove('loading');
                button.innerHTML = '<i class="fas fa-camera"></i> Screenshot aktualisieren';
            }
        }
    }

    toggleUrlPopover(instanceName) {
        // Schließe alle anderen Popovers
        document.querySelectorAll('.url-popover.open').forEach(popover => {
            if (popover.id !== `popover-${instanceName}`) {
                popover.classList.remove('open');
            }
        });
        
        // Toggle aktuelles Popover
        const popover = document.getElementById(`popover-${instanceName}`);
        if (popover) {
            popover.classList.toggle('open');
        }
    }

    showCreateModal() {
        const modal = document.getElementById('createModal');
        modal.classList.add('show');
        
        // Reset form und dump selection
        const form = document.getElementById('createInstanceForm');
        form.reset();
        document.getElementById('dumpSelection').classList.remove('show');
        document.getElementById('autoInstall').disabled = false;
        document.getElementById('autoInstall').checked = true;
        
        // Lade verfügbare Dumps
        this.loadAvailableDumps();
    }

    hideCreateModal() {
        document.getElementById('createModal').classList.remove('show');
    }

    showDeleteModal(name) {
        this.deleteTarget = name;
        document.getElementById('deleteInstanceName').textContent = name;
        document.getElementById('deleteModal').classList.add('show');
    }

    hideDeleteModal() {
        this.deleteTarget = null;
        document.getElementById('deleteModal').classList.remove('show');
    }

    confirmDelete() {
        if (this.deleteTarget) {
            this.deleteInstance(this.deleteTarget);
            this.hideDeleteModal();
        }
    }

    async showBackupModal(instanceName) {
        this.currentInstanceForBackup = instanceName;
        document.getElementById('backupInstanceName').textContent = instanceName;
        const modal = document.getElementById('backupModal');
        modal.classList.add('show');
        await this.loadBackups(instanceName);
    }

    hideBackupModal() {
        document.getElementById('backupModal').classList.remove('show');
        document.getElementById('backupList').innerHTML = '<p class="loading-text"><i class="fas fa-spinner fa-spin"></i> Lade Backups...</p>';
    }

    async loadBackups(instanceName) {
        const backupListDiv = document.getElementById('backupList');
        backupListDiv.innerHTML = '<p class="loading-text"><i class="fas fa-spinner fa-spin"></i> Lade Backups...</p>';
        try {
            const response = await fetch(`/api/instances/${instanceName}/backups`);
            const result = await response.json();

            if (response.ok && result.success) {
                if (result.backups.length === 0) {
                    backupListDiv.innerHTML = '<p class="info-text">Keine Backups für diese Instanz gefunden.</p>';
                } else {
                    backupListDiv.innerHTML = result.backups.map(backup => `
                        <div class="backup-item glass-card">
                            <span><i class="fas fa-archive"></i> ${backup.name} (${backup.size})</span>
                            <button class="glass-button primary small" onclick="dashboard.restoreBackup('${instanceName}', '${backup.name}')">
                                <i class="fas fa-undo"></i> Wiederherstellen
                            </button>
                        </div>
                    `).join('');
                }
            } else {
                throw new Error(result.error || 'Fehler beim Laden der Backups');
            }
        } catch (error) {
            console.error('Fehler beim Laden der Backups:', error);
            backupListDiv.innerHTML = `<p class="error-text"><i class="fas fa-exclamation-triangle"></i> Fehler: ${error.message}</p>`;
            this.showToast(`Fehler beim Laden der Backups: ${error.message}`, 'error');
        }
    }

    async restoreBackup(instanceName, backupName) {
        if (!confirm(`Möchten Sie das Backup '${backupName}' für Instanz '${instanceName}' wirklich wiederherstellen? Die aktuelle Instanz wird überschrieben!`)) {
            return;
        }

        this.showToast(`Stelle Backup '${backupName}' für Instanz ${instanceName} wieder her...`, 'warning');
        this.hideBackupModal();

        try {
            const response = await fetch(`/api/instances/${instanceName}/restore`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json'
                },
                body: JSON.stringify({ backupName }),
            });
            const result = await response.json();

            if (response.ok) {
                this.showToast(result.message, 'success');
                // Instanzen neu laden, um den aktualisierten Status anzuzeigen
                setTimeout(() => {
                    this.loadInstances();
                }, 3000); // Etwas Verzögerung, damit der Server die Instanz neu starten kann
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            console.error('Fehler beim Wiederherstellen des Backups:', error);
            this.showToast(`Fehler beim Wiederherstellen: ${error.message}`, 'error');
        }
    }

    async showReadmeModal() {
        // README als Markdown laden
        const response = await fetch('README.md');
        const markdown = await response.text();
        // Markdown zu HTML parsen (mit marked.js oder fallback)
        let html;
        if (window.marked) {
            html = window.marked.parse(markdown);
        } else {
            html = `<pre style='white-space:pre-wrap'>${markdown.replace(/</g,'&lt;')}</pre>`;
        }
        // Modal erzeugen
        const modal = document.createElement('div');
        modal.className = 'modal-backdrop show';
        modal.innerHTML = `
            <div class="modal glass-card" style="max-width: 800px; max-height: 90vh; overflow-y: auto;">
                <div class="modal-header">
                    <h2><i class="fas fa-book"></i> README</h2>
                    <button class="close-button" title="Schließen" onclick="this.closest('.modal-backdrop').classList.remove('show'); setTimeout(() => this.closest('.modal-backdrop').remove(), 300);"><i class="fas fa-times"></i></button>
                </div>
                <div class="modal-body" style="padding: 1.5rem; background: rgba(255,255,255,0.95);">
                    ${html}
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    showToast(message, type = 'success') {
        const container = document.getElementById('toastContainer');
        const toast = document.createElement('div');
        toast.className = `toast ${type}`;
        toast.textContent = message;
        
        container.appendChild(toast);
        
        // Auto-remove after 5 seconds
        setTimeout(() => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 5000);
        
        // Remove on click
        toast.addEventListener('click', () => {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        });
    }

    // Dump-Auswahl Toggle
    toggleDumpSelection() {
        const importDumpCheckbox = document.getElementById('importDump');
        const dumpSelection = document.getElementById('dumpSelection');
        const autoInstallCheckbox = document.getElementById('autoInstall');
        const webserverOnlyCheckbox = document.getElementById('webserverOnly');
        
        if (importDumpCheckbox.checked) {
            dumpSelection.classList.add('show');
            autoInstallCheckbox.checked = false;
            autoInstallCheckbox.disabled = true;
            webserverOnlyCheckbox.checked = false;
            webserverOnlyCheckbox.disabled = true;
            this.loadAvailableDumps();
        } else {
            dumpSelection.classList.remove('show');
            autoInstallCheckbox.disabled = false;
            webserverOnlyCheckbox.disabled = false;
            if (!webserverOnlyCheckbox.checked) {
                autoInstallCheckbox.checked = true;
            }
        }
    }

    // Webserver-only Toggle
    toggleWebserverOnly() {
        const webserverOnlyCheckbox = document.getElementById('webserverOnly');
        const autoInstallCheckbox = document.getElementById('autoInstall');
        const importDumpCheckbox = document.getElementById('importDump');
        
        if (webserverOnlyCheckbox.checked) {
            autoInstallCheckbox.checked = false;
            autoInstallCheckbox.disabled = true;
            importDumpCheckbox.checked = false;
            importDumpCheckbox.disabled = true;
            // Verstecke Dump-Auswahl falls sichtbar
            document.getElementById('dumpSelection').classList.remove('show');
        } else {
            autoInstallCheckbox.disabled = false;
            importDumpCheckbox.disabled = false;
            autoInstallCheckbox.checked = true;
        }
    }

    // Verfügbare Dumps laden
    async loadAvailableDumps() {
        try {
            const response = await fetch('/api/dumps');
            const dumps = await response.json();
            
            const dumpSelect = document.getElementById('dumpFile');
            dumpSelect.innerHTML = '';
            
            if (dumps.length === 0) {
                dumpSelect.innerHTML = '<option value="">Keine Dumps gefunden</option>';
            } else {
                dumpSelect.innerHTML = '<option value="">Dump auswählen...</option>';
                dumps.forEach(dump => {
                    const option = document.createElement('option');
                    option.value = dump.path;
                    option.textContent = `${dump.basename} (${dump.size})`;
                    dumpSelect.appendChild(option);
                });
            }
        } catch (error) {
            console.error('Fehler beim Laden der Dumps:', error);
            const dumpSelect = document.getElementById('dumpFile');
            dumpSelect.innerHTML = '<option value="">Fehler beim Laden der Dumps</option>';
        }
    }

    async showVersionUpdate(instanceName, type, currentVersion) {
        try {
            const versions = {
                php: [
                    { version: '7.4', label: 'PHP 7.4 (Legacy)' },
                    { version: '8.0', label: 'PHP 8.0' },
                    { version: '8.1', label: 'PHP 8.1 (LTS)' },
                    { version: '8.2', label: 'PHP 8.2' },
                    { version: '8.3', label: 'PHP 8.3 (Current)' },
                    { version: '8.4', label: 'PHP 8.4 (Latest)' }
                ],
                mariadb: [
                    { version: '10.4', label: 'MariaDB 10.4' },
                    { version: '10.5', label: 'MariaDB 10.5' },
                    { version: '10.6', label: 'MariaDB 10.6 (LTS)' },
                    { version: '10.11', label: 'MariaDB 10.11 (LTS)' },
                    { version: '11.0', label: 'MariaDB 11.0' },
                    { version: 'latest', label: 'MariaDB Latest' }
                ]
            };

            const typeLabel = type === 'php' ? 'PHP' : 'MariaDB';
            const availableVersions = versions[type];
            
            // Modal für Version-Update erstellen
            const modal = document.createElement('div');
            modal.className = 'modal-backdrop';
            modal.innerHTML = `
                <div class="modal version-modal">
                    <div class="modal-header">
                        <h2><i class="fas fa-${type === 'php' ? 'code' : 'database'}"></i> ${typeLabel}-Version ändern - ${instanceName}</h2>
                        <button class="close-button" onclick="this.closest('.modal-backdrop').classList.remove('show'); setTimeout(() => this.closest('.modal-backdrop').remove(), 300);">
                            <i class="fas fa-times"></i>
                        </button>
                    </div>
                    <div class="modal-body">
                        <p>Wählen Sie eine neue ${typeLabel}-Version für die Instanz <strong>${instanceName}</strong>:</p>
                        <div class="version-grid">
                            ${availableVersions.map(v => `
                                <div class="version-option ${v.version === currentVersion ? 'current' : ''}" 
                                     data-version="${v.version}" 
                                     onclick="this.parentElement.querySelectorAll('.version-option').forEach(el => el.classList.remove('selected')); this.classList.add('selected');">
                                    <div class="version-number">${v.version}</div>
                                    <div class="version-label">${v.label.replace(/^(PHP|MariaDB) /, '')}</div>
                                </div>
                            `).join('')}
                        </div>
                        <div class="modal-footer">
                            <button type="button" class="glass-button secondary" onclick="this.closest('.modal-backdrop').classList.remove('show'); setTimeout(() => this.closest('.modal-backdrop').remove(), 300);">
                                Abbrechen
                            </button>
                            <button type="button" class="glass-button primary" onclick="window.dashboard.updateVersion('${instanceName}', '${type}', this)">
                                <i class="fas fa-sync"></i>
                                Version aktualisieren
                            </button>
                        </div>
                    </div>
                </div>
            `;
            
            // Modal zum Body hinzufügen
            document.body.appendChild(modal);
            
            // Show-Klasse hinzufügen für Animation
            setTimeout(() => {
                modal.classList.add('show');
            }, 10);
            
            // Click outside to close
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    modal.classList.remove('show');
                    setTimeout(() => modal.remove(), 300);
                }
            });
            
        } catch (error) {
            console.error('Fehler beim Anzeigen des Version-Updates:', error);
            this.showToast(`Fehler: ${error.message}`, 'error');
        }
    }

    async updateVersion(instanceName, type, button) {
        let originalText = ''; // Definiere außerhalb des try-blocks
        
        try {
            // Finde die ausgewählte Version
            const modal = button.closest('.modal');
            const selectedOption = modal.querySelector('.version-option.selected');
            
            if (!selectedOption) {
                this.showToast('Bitte wählen Sie eine Version aus', 'warning');
                return;
            }
            
            const newVersion = selectedOption.dataset.version;
            
            // Button in Loading-Zustand
            originalText = button.innerHTML;
            button.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Wird aktualisiert...';
            button.disabled = true;
            
            // API-Call für Version-Update (mit längerem Timeout)
            const requestBody = {};
            if (type === 'php') {
                requestBody.phpVersion = newVersion;
            } else {
                requestBody.mariadbVersion = newVersion;
            }
            
            // AbortController für Timeout-Handling
            const controller = new AbortController();
            const timeoutId = setTimeout(() => controller.abort(), 360000); // 6 Minuten
            
            const response = await fetch(`/api/instances/${instanceName}/update-versions`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify(requestBody),
                signal: controller.signal
            });
            
            clearTimeout(timeoutId);
            
            if (response.ok) {
                const result = await response.json();
                this.showToast(`${type === 'php' ? 'PHP' : 'MariaDB'}-Version erfolgreich auf ${newVersion} aktualisiert`, 'success');
                
                // Modal schließen
                const modalBackdrop = button.closest('.modal-backdrop');
                modalBackdrop.classList.remove('show');
                setTimeout(() => modalBackdrop.remove(), 300);
                
                // Instanzen neu laden um aktuelle Versionen anzuzeigen
                setTimeout(() => {
                    this.loadInstances();
                }, 1000);
                
            } else {
                const errorData = await response.json();
                throw new Error(errorData.error || 'Version konnte nicht aktualisiert werden');
            }
            
        } catch (error) {
            console.error('Fehler beim Aktualisieren der Version:', error);
            
            let errorMessage = error.message;
            if (error.name === 'AbortError') {
                errorMessage = 'Timeout: Version-Update dauert länger als erwartet. Bitte prüfen Sie den Status der Instanz.';
            }
            
            this.showToast(`Fehler beim Aktualisieren: ${errorMessage}`, 'error');
            
            // Button zurücksetzen
            if (button) {
                button.innerHTML = originalText;
                button.disabled = false;
            }
        }
    }

    async createSnapshot(instanceName) {
        try {
            this.showToast(`Snapshot für ${instanceName} wird erstellt...`, 'info');
            const response = await fetch(`/api/instances/${instanceName}/snapshot`, { method: 'POST' });
            const result = await response.json();
            if (response.ok) {
                this.showToast(result.message, 'success');
                setTimeout(() => this.loadInstances(), 1000);
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            this.showToast(`Fehler beim Snapshot: ${error.message}`, 'error');
        }
    }

    async recoverSnapshot(instanceName) {
        try {
            this.showToast(`Snapshot für ${instanceName} wird wiederhergestellt...`, 'warning');
            const response = await fetch(`/api/instances/${instanceName}/snapshot-recover`, { method: 'POST' });
            const result = await response.json();
            if (response.ok) {
                this.showToast(result.message, 'success');
                setTimeout(() => this.loadInstances(), 2000);
            } else {
                throw new Error(result.error);
            }
        } catch (error) {
            this.showToast(`Fehler beim Wiederherstellen: ${error.message}`, 'error');
        }
    }
}

// Global functions for onclick handlers
window.showCreateModal = () => dashboard.showCreateModal();
window.hideCreateModal = () => dashboard.hideCreateModal();
window.hideDeleteModal = () => dashboard.hideDeleteModal();
window.confirmDelete = () => dashboard.confirmDelete();
window.showBackupModal = (name) => dashboard.showBackupModal(name);
window.hideBackupModal = () => dashboard.hideBackupModal();

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new RedaxoDashboard();
});
// Canvas-Animation entfernt, Wellen werden nun per SVG/CSS in index.html/styles.css realisiert

// Abstrakte, animierte Formen im Hintergrund (Canvas)
(function() {
    const canvas = document.getElementById('abstract-bg');
    if (!canvas) return;
    const ctx = canvas.getContext('2d');
    let w = window.innerWidth;
    let h = window.innerHeight;
    canvas.width = w;
    canvas.height = h;

    // Farben für die Formen (dunkel, dezent, leicht transparent)
    const palette = [
        'rgba(36, 40, 56, 0.55)',
        'rgba(60, 72, 100, 0.45)',
        'rgba(79, 125, 243, 0.18)',
        'rgba(30, 41, 59, 0.33)',
        'rgba(71, 85, 105, 0.22)'
    ];

    // Erzeuge abstrakte Formen
    function randomShape() {
        const type = Math.random() < 0.5 ? 'circle' : (Math.random() < 0.5 ? 'polygon' : 'blob');
        const x = Math.random() * w;
        const y = Math.random() * h;
        const r = 60 + Math.random() * 120;
        const sides = 5 + Math.floor(Math.random() * 4);
        const color = palette[Math.floor(Math.random() * palette.length)];
        const angle = Math.random() * Math.PI * 2;
        const speed = 0.1 + Math.random() * 0.15;
        const rotSpeed = (Math.random() - 0.5) * 0.003;
        const scale = 0.7 + Math.random() * 0.6;
        return { type, x, y, r, sides, color, angle, speed, rot: angle, rotSpeed, scale, scaleDir: Math.random() < 0.5 ? 1 : -1 };
    }

    let shapes = Array.from({length: 10}, randomShape);

    function drawShape(s) {
        ctx.save();
        ctx.translate(s.x, s.y);
        ctx.rotate(s.rot);
        ctx.scale(s.scale, s.scale);
        ctx.beginPath();
        if (s.type === 'circle') {
            ctx.arc(0, 0, s.r, 0, Math.PI * 2);
        } else if (s.type === 'polygon') {
            for (let i = 0; i < s.sides; i++) {
                const a = (i / s.sides) * Math.PI * 2;
                const rad = s.r * (0.85 + 0.15 * Math.sin(a * s.sides + s.rot));
                const px = Math.cos(a) * rad;
                const py = Math.sin(a) * rad;
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();
        } else if (s.type === 'blob') {
            for (let i = 0; i < s.sides; i++) {
                const a = (i / s.sides) * Math.PI * 2;
                const rad = s.r * (0.7 + 0.3 * Math.sin(a * s.sides + s.rot + Math.sin(s.rot)));
                const px = Math.cos(a) * rad;
                const py = Math.sin(a) * rad;
                if (i === 0) ctx.moveTo(px, py);
                else ctx.lineTo(px, py);
            }
            ctx.closePath();
        }
        ctx.fillStyle = s.color;
        ctx.shadowColor = s.color.replace('0.', '0.18');
        ctx.shadowBlur = 32;
        ctx.fill();
        ctx.restore();
    }

    function animate() {
        ctx.clearRect(0, 0, w, h);
        for (const s of shapes) {
            drawShape(s);
            // Bewegung
            s.x += Math.cos(s.angle) * s.speed;
            s.y += Math.sin(s.angle) * s.speed;
            s.rot += s.rotSpeed;
            s.scale += 0.002 * s.scaleDir;
            if (s.scale > 1.2 || s.scale < 0.7) s.scaleDir *= -1;
            // Wrap-around
            if (s.x < -200) s.x = w + 200;
            if (s.x > w + 200) s.x = -200;
            if (s.y < -200) s.y = h + 200;
            if (s.y > h + 200) s.y = -200;
        }
        requestAnimationFrame(animate);
    }

    window.addEventListener('resize', () => {
        w = window.innerWidth;
        h = window.innerHeight;
        canvas.width = w;
        canvas.height = h;
    });

    animate();
})();
