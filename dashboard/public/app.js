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
                    <h2><i class="fas fa-rocket"></i> Noch keine Instanzen vorhanden</h2>
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
                                    ${instance.mailpitUrl ? `
                                        <a href="${instance.mailpitUrl}" target="_blank" class="url-link">
                                            <i class="fas fa-envelope"></i> Mailpit
                                        </a>
                                    ` : ''}
                                    ${this.config && this.config.features.vscodeIntegration !== false && this.config.instancesDir ? `
                                        <a href="vscode://file/${this.config.instancesDir}/${instance.name}/app" class="url-link">
                                            <i class="fab fa-microsoft"></i> VS Code öffnen
                                        </a>
                                    ` : ''}
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
                                    <i class="fab fa-php"></i>
                                    ${instance.phpVersion || 'N/A'}
                                </div>
                            </div>
                            <div class="detail-item">
                                <div class="detail-label">MariaDB</div>
                                <div class="detail-value">
                                    <i class="fas fa-database"></i>
                                    ${instance.mariadbVersion || 'N/A'}
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
                : `Erstelle Instanz ${instanceData.name}...`;
                
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
                
                // Reset dump selection
                document.getElementById('dumpSelection').classList.remove('show');
                document.getElementById('autoInstall').disabled = false;
                document.getElementById('autoInstall').checked = true;
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
        
        if (importDumpCheckbox.checked) {
            dumpSelection.classList.add('show');
            autoInstallCheckbox.checked = false;
            autoInstallCheckbox.disabled = true;
            this.loadAvailableDumps();
        } else {
            dumpSelection.classList.remove('show');
            autoInstallCheckbox.disabled = false;
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
}

// Global functions for onclick handlers
window.showCreateModal = () => dashboard.showCreateModal();
window.hideCreateModal = () => dashboard.hideCreateModal();
window.hideDeleteModal = () => dashboard.hideDeleteModal();
window.confirmDelete = () => dashboard.confirmDelete();

// Initialize dashboard when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    window.dashboard = new RedaxoDashboard();
});
