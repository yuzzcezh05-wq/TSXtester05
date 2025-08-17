const { ipcRenderer } = require('electron');

class DevProjectRunner {
    constructor() {
        this.currentFolder = null;
        this.projects = new Map();
        this.runningProjects = new Map();
        this.initializeApp();
    }

    initializeApp() {
        this.setupEventListeners();
        this.setupIPC();
        this.updateStatus('Ready');
    }

    setupEventListeners() {
        // Browse folder buttons
        document.getElementById('browse-btn').onclick = () => this.browseFolder();
        document.getElementById('browse-empty').onclick = () => this.browseFolder();
        
        // Panel actions
        document.getElementById('refresh-btn').onclick = () => this.refreshFileTree();
        document.getElementById('clear-console').onclick = () => this.clearConsole();
        document.getElementById('toggle-console').onclick = () => this.toggleConsole();
        
        // Quick actions
        document.getElementById('stop-all-btn').onclick = () => this.stopAllProjects();
        document.getElementById('open-explorer-btn').onclick = () => this.openInExplorer();
        
        // Package manager change
        document.getElementById('package-manager').onchange = (e) => {
            this.packageManager = e.target.value;
        };
    }

    setupIPC() {
        // Project output
        ipcRenderer.on('project-output', (event, data) => {
            this.handleProjectOutput(data);
        });

        // Install output
        ipcRenderer.on('install-output', (event, data) => {
            this.handleInstallOutput(data);
        });
    }

    async browseFolder() {
        try {
            this.updateStatus('Browsing...');
            const folderPath = await ipcRenderer.invoke('browse-folder');
            
            if (folderPath) {
                this.currentFolder = folderPath;
                await this.loadFolder(folderPath);
                this.updateQuickActions();
            }
            
            this.updateStatus('Ready');
        } catch (error) {
            this.logToConsole(`Error browsing folder: ${error.message}`, 'error');
            this.updateStatus('Error');
        }
    }

    async loadFolder(folderPath) {
        try {
            this.updateStatus('Loading folder...');
            
            // Clear previous data
            this.projects.clear();
            this.clearFileTree();
            this.clearProjects();
            
            // Load directory contents
            await this.loadFileTree(folderPath);
            
            // Scan for projects
            await this.scanForProjects(folderPath);
            
            this.logToConsole(`📁 Loaded folder: ${folderPath}`, 'info');
            this.updateStatus('Ready');
        } catch (error) {
            this.logToConsole(`Error loading folder: ${error.message}`, 'error');
            this.updateStatus('Error');
        }
    }

    async loadFileTree(dirPath, container = null, level = 0) {
        if (level > 3) return; // Limit depth to prevent performance issues
        
        try {
            const items = await ipcRenderer.invoke('read-directory', dirPath);
            const treeContainer = container || document.getElementById('file-tree');
            
            if (!container) {
                treeContainer.innerHTML = '';
            }
            
            for (const item of items) {
                if (item.name.startsWith('.') || item.name === 'node_modules') continue;
                
                const fileElement = this.createFileElement(item, level);
                treeContainer.appendChild(fileElement);
                
                // Load subdirectories for projects
                if (item.isDirectory && level < 2) {
                    const hasPackageJson = await this.hasPackageJson(item.path);
                    if (hasPackageJson) {
                        fileElement.classList.add('project');
                        const badge = document.createElement('div');
                        badge.className = 'project-badge';
                        badge.textContent = 'PROJECT';
                        fileElement.appendChild(badge);
                    }
                }
            }
        } catch (error) {
            this.logToConsole(`Error loading directory ${dirPath}: ${error.message}`, 'error');
        }
    }

    createFileElement(item, level) {
        const element = document.createElement('div');
        element.className = `file-item ${item.isDirectory ? 'directory' : 'file'}`;
        element.style.paddingLeft = `${12 + (level * 20)}px`;
        
        const icon = document.createElement('span');
        icon.className = 'file-icon';
        icon.textContent = item.isDirectory ? '📁' : this.getFileIcon(item.name);
        
        const name = document.createElement('span');
        name.className = 'file-name';
        name.textContent = item.name;
        
        element.appendChild(icon);
        element.appendChild(name);
        
        // Add click handlers
        element.onclick = () => {
            if (item.isDirectory) {
                this.selectFolder(item.path);
            }
        };
        
        return element;
    }

    getFileIcon(filename) {
        const ext = filename.split('.').pop().toLowerCase();
        const iconMap = {
            'js': '📄',
            'jsx': '⚛️',
            'ts': '📘',
            'tsx': '⚛️',
            'vue': '💚',
            'svelte': '🔥',
            'html': '🌐',
            'css': '🎨',
            'scss': '🎨',
            'json': '📋',
            'md': '📝',
            'py': '🐍',
            'java': '☕',
            'php': '🐘',
            'rb': '💎'
        };
        return iconMap[ext] || '📄';
    }

    async hasPackageJson(dirPath) {
        try {
            const items = await ipcRenderer.invoke('read-directory', dirPath);
            return items.some(item => item.name === 'package.json' && !item.isDirectory);
        } catch {
            return false;
        }
    }

    async scanForProjects(rootPath) {
        try {
            this.updateStatus('Scanning for projects...');
            await this.scanDirectory(rootPath);
            this.renderProjects();
        } catch (error) {
            this.logToConsole(`Error scanning for projects: ${error.message}`, 'error');
        }
    }

    async scanDirectory(dirPath, level = 0) {
        if (level > 2) return; // Limit recursion depth
        
        try {
            const items = await ipcRenderer.invoke('read-directory', dirPath);
            
            // Check if current directory is a project
            const hasPackageJson = items.some(item => item.name === 'package.json' && !item.isDirectory);
            
            if (hasPackageJson) {
                const projectInfo = await ipcRenderer.invoke('detect-project', dirPath);
                if (projectInfo.type !== 'unknown' && projectInfo.type !== 'error') {
                    this.projects.set(dirPath, {
                        ...projectInfo,
                        path: dirPath,
                        status: 'stopped'
                    });
                    this.logToConsole(`🚀 Found ${projectInfo.framework || projectInfo.type} project: ${projectInfo.name}`, 'success');
                }
            }
            
            // Recursively scan subdirectories (but skip node_modules, .git, etc.)
            for (const item of items) {
                if (item.isDirectory && !['node_modules', '.git', 'dist', 'build', '.next'].includes(item.name)) {
                    await this.scanDirectory(item.path, level + 1);
                }
            }
        } catch (error) {
            // Silently continue if directory can't be read
        }
    }

    renderProjects() {
        const container = document.getElementById('projects-container');
        
        if (this.projects.size === 0) {
            container.innerHTML = `
                <div class="empty-state">
                    <div class="empty-icon">🚀</div>
                    <p>No projects detected</p>
                    <small>Select a folder with package.json to get started</small>
                </div>
            `;
            return;
        }
        
        container.innerHTML = '';
        
        for (const [path, project] of this.projects) {
            const card = this.createProjectCard(project);
            container.appendChild(card);
        }
    }

    createProjectCard(project) {
        const card = document.createElement('div');
        card.className = 'project-card';
        
        const statusClass = project.status === 'running' ? 'status-running' : 
                           project.status === 'installing' ? 'status-installing' : 'status-stopped';
        
        const statusText = project.status === 'running' ? '🟢 Running' : 
                          project.status === 'installing' ? '🟡 Installing' : '🔴 Stopped';
        
        card.innerHTML = `
            <div class="project-header">
                <div class="project-info">
                    <h4>${project.name}</h4>
                    <div class="project-type">
                        ${project.framework ? `<span class="type-badge type-${project.type}">${project.framework}</span>` : ''}
                        ${project.buildTool ? `<span class="type-badge">${project.buildTool}</span>` : ''}
                    </div>
                </div>
                <div class="project-status ${statusClass}">
                    ${statusText}
                </div>
            </div>
            <div class="project-path">${project.path}</div>
            <div class="project-actions">
                <button class="btn-small btn-run" onclick="app.runProject('${project.path}')" 
                        ${project.status === 'running' ? 'disabled' : ''}>
                    ▶️ Run
                </button>
                <button class="btn-small btn-stop" onclick="app.stopProject('${project.path}')" 
                        ${project.status !== 'running' ? 'disabled' : ''}>
                    ⏹️ Stop
                </button>
                <button class="btn-small btn-install" onclick="app.installDependencies('${project.path}')" 
                        ${project.status === 'installing' ? 'disabled' : ''}>
                    📦 Install
                </button>
            </div>
        `;
        
        return card;
    }

    async runProject(projectPath) {
        try {
            const project = this.projects.get(projectPath);
            if (!project) return;
            
            this.updateProjectStatus(projectPath, 'running');
            this.logToConsole(`🚀 Starting ${project.name}...`, 'info');
            
            const result = await ipcRenderer.invoke('run-project', projectPath, 'start');
            
            if (result.success) {
                this.runningProjects.set(projectPath, {
                    name: project.name,
                    port: result.port,
                    pid: result.pid
                });
                
                this.updateRunningProjects();
                this.logToConsole(`✅ ${project.name} started on port ${result.port}`, 'success');
            } else {
                this.updateProjectStatus(projectPath, 'stopped');
                this.logToConsole(`❌ Failed to start ${project.name}: ${result.error}`, 'error');
            }
        } catch (error) {
            this.updateProjectStatus(projectPath, 'stopped');
            this.logToConsole(`Error running project: ${error.message}`, 'error');
        }
    }

    async stopProject(projectPath) {
        try {
            const project = this.projects.get(projectPath);
            if (!project) return;
            
            this.logToConsole(`⏹️ Stopping ${project.name}...`, 'info');
            
            const result = await ipcRenderer.invoke('stop-project', projectPath);
            
            if (result.success) {
                this.updateProjectStatus(projectPath, 'stopped');
                this.runningProjects.delete(projectPath);
                this.updateRunningProjects();
                this.logToConsole(`✅ ${project.name} stopped`, 'success');
            } else {
                this.logToConsole(`❌ Failed to stop ${project.name}: ${result.error}`, 'error');
            }
        } catch (error) {
            this.logToConsole(`Error stopping project: ${error.message}`, 'error');
        }
    }

    async installDependencies(projectPath) {
        try {
            const project = this.projects.get(projectPath);
            if (!project) return;
            
            this.updateProjectStatus(projectPath, 'installing');
            this.logToConsole(`📦 Installing dependencies for ${project.name}...`, 'info');
            
            const manager = document.getElementById('package-manager').value;
            const result = await ipcRenderer.invoke('install-dependencies', projectPath, manager);
            
            if (result.success) {
                this.updateProjectStatus(projectPath, 'stopped');
                this.logToConsole(`✅ Dependencies installed for ${project.name}`, 'success');
            } else {
                this.updateProjectStatus(projectPath, 'stopped');
                this.logToConsole(`❌ Failed to install dependencies for ${project.name}`, 'error');
            }
        } catch (error) {
            this.updateProjectStatus(projectPath, 'stopped');
            this.logToConsole(`Error installing dependencies: ${error.message}`, 'error');
        }
    }

    stopAllProjects() {
        for (const projectPath of this.runningProjects.keys()) {
            this.stopProject(projectPath);
        }
    }

    openInExplorer() {
        if (this.currentFolder) {
            ipcRenderer.invoke('open-in-explorer', this.currentFolder);
        }
    }

    updateProjectStatus(projectPath, status) {
        const project = this.projects.get(projectPath);
        if (project) {
            project.status = status;
            this.renderProjects();
        }
    }

    updateRunningProjects() {
        const container = document.getElementById('running-list');
        
        if (this.runningProjects.size === 0) {
            container.innerHTML = '<p class="empty-text">No projects running</p>';
            document.getElementById('stop-all-btn').disabled = true;
            return;
        }
        
        document.getElementById('stop-all-btn').disabled = false;
        container.innerHTML = '';
        
        for (const [path, info] of this.runningProjects) {
            const item = document.createElement('div');
            item.className = 'running-item';
            item.innerHTML = `
                <span class="running-name">${info.name}</span>
                <span class="running-port">:${info.port}</span>
            `;
            container.appendChild(item);
        }
    }

    updateQuickActions() {
        document.getElementById('open-explorer-btn').disabled = !this.currentFolder;
    }

    handleProjectOutput(data) {
        const { projectPath, type, data: output, code } = data;
        const project = this.projects.get(projectPath);
        
        if (type === 'close') {
            if (project) {
                this.updateProjectStatus(projectPath, 'stopped');
                this.runningProjects.delete(projectPath);
                this.updateRunningProjects();
                this.logToConsole(`🔴 ${project.name} stopped (exit code: ${code})`, code === 0 ? 'info' : 'error');
            }
        } else {
            this.logToConsole(output, type === 'stderr' ? 'error' : 'info');
        }
    }

    handleInstallOutput(data) {
        const { projectPath, type, data: output, code } = data;
        
        if (type === 'close') {
            const project = this.projects.get(projectPath);
            if (project) {
                this.updateProjectStatus(projectPath, 'stopped');
                if (code === 0) {
                    this.logToConsole(`✅ Dependencies installed successfully for ${project.name}`, 'success');
                } else {
                    this.logToConsole(`❌ Failed to install dependencies for ${project.name}`, 'error');
                }
            }
        } else {
            this.logToConsole(output, type === 'stderr' ? 'error' : 'info');
        }
    }

    logToConsole(message, type = 'info') {
        const console = document.getElementById('console-content');
        const line = document.createElement('div');
        line.className = `console-line console-${type}`;
        
        const timestamp = new Date().toLocaleTimeString();
        line.textContent = `[${timestamp}] ${message}`;
        
        console.appendChild(line);
        console.scrollTop = console.scrollHeight;
        
        // Remove welcome message if it exists
        const welcome = console.querySelector('.console-welcome');
        if (welcome) {
            welcome.remove();
        }
    }

    clearConsole() {
        const console = document.getElementById('console-content');
        console.innerHTML = `
            <div class="console-welcome">
                <p>🎯 Console cleared - Ready for new output</p>
            </div>
        `;
    }

    toggleConsole() {
        const panel = document.getElementById('bottom-panel');
        const currentHeight = panel.style.height;
        
        if (currentHeight === '40px' || currentHeight === '') {
            panel.style.height = '250px';
        } else {
            panel.style.height = '40px';
        }
    }

    clearFileTree() {
        document.getElementById('file-tree').innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">📁</div>
                <p>No folder selected</p>
                <button class="btn-primary" id="browse-empty">Browse Folder</button>
            </div>
        `;
        document.getElementById('browse-empty').onclick = () => this.browseFolder();
    }

    clearProjects() {
        document.getElementById('projects-container').innerHTML = `
            <div class="empty-state">
                <div class="empty-icon">🚀</div>
                <p>No projects detected</p>
                <small>Select a folder with package.json to get started</small>
            </div>
        `;
    }

    refreshFileTree() {
        if (this.currentFolder) {
            this.loadFolder(this.currentFolder);
        }
    }

    selectFolder(folderPath) {
        this.currentFolder = folderPath;
        this.loadFolder(folderPath);
    }

    updateStatus(status) {
        const indicator = document.getElementById('status-indicator');
        const dot = indicator.querySelector('.status-dot');
        const text = indicator.querySelector('span');
        
        text.textContent = status;
        
        // Update dot color based on status
        dot.style.background = status === 'Ready' ? '#238636' :
                              status === 'Error' ? '#f85149' :
                              '#d29922';
    }
}

// Initialize the app
const app = new DevProjectRunner();