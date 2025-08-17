const { ipcRenderer } = require('electron');

class EnhancedDevProjectRunner {
    constructor() {
        this.currentFolder = null;
        this.projects = new Map();
        this.runningProjects = new Map();
        this.packageManager = 'npm';
        this.initializeApp();
    }

    initializeApp() {
        this.setupEventListeners();
        this.setupIPC();
        this.updateStatus('Ready');
        this.showWelcomeMessage();
    }

    showWelcomeMessage() {
        this.logToConsole('🚀 Dev Project Runner Enhanced - Ready!', 'success');
        this.logToConsole('✨ Now with automatic TSX/TypeScript support', 'info');
        this.logToConsole('📁 Drop TSX files in any folder and run instantly!', 'info');
    }

    setupEventListeners() {
        document.getElementById('browse-btn').onclick = () => this.browseFolder();
        document.getElementById('browse-empty').onclick = () => this.browseFolder();
        document.getElementById('refresh-btn').onclick = () => this.refreshFileTree();
        document.getElementById('clear-console').onclick = () => this.clearConsole();
        document.getElementById('toggle-console').onclick = () => this.toggleConsole();
        document.getElementById('stop-all-btn').onclick = () => this.stopAllProjects();
        document.getElementById('open-explorer-btn').onclick = () => this.openInExplorer();
        document.getElementById('create-tsx-btn').onclick = () => this.createTsxProject();
        
        document.getElementById('package-manager').onchange = (e) => {
            this.packageManager = e.target.value;
        };
    }

    setupIPC() {
        ipcRenderer.on('project-output', (event, data) => {
            this.handleProjectOutput(data);
        });

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
            
            this.projects.clear();
            this.clearFileTree();
            this.clearProjects();
            
            await this.loadFileTree(folderPath);
            await this.scanForProjects(folderPath);
            
            this.logToConsole(`📁 Loaded folder: ${folderPath}`, 'info');
            this.updateStatus('Ready');
        } catch (error) {
            this.logToConsole(`Error loading folder: ${error.message}`, 'error');
            this.updateStatus('Error');
        }
    }

    async loadFileTree(dirPath, container = null, level = 0) {
        if (level > 3) return;
        
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
                
                if (item.isDirectory && level < 2) {
                    const hasPackageJson = await this.hasPackageJson(item.path);
                    const hasTsxFiles = await this.hasTsxFiles(item.path);
                    
                    if (hasPackageJson || hasTsxFiles) {
                        fileElement.classList.add('project');
                        const badge = document.createElement('div');
                        badge.className = 'project-badge';
                        badge.textContent = hasTsxFiles ? 'TSX PROJECT' : 'PROJECT';
                        if (hasTsxFiles) badge.classList.add('tsx-badge');
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
        
        // Add TSX indicator for .tsx files
        if (item.name.endsWith('.tsx')) {
            name.classList.add('tsx-file');
            const tsxBadge = document.createElement('span');
            tsxBadge.className = 'tsx-indicator';
            tsxBadge.textContent = 'TSX';
            name.appendChild(tsxBadge);
        }
        
        element.appendChild(icon);
        element.appendChild(name);
        
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
            'tsx': '⚛️',
            'ts': '📘', 
            'js': '📄',
            'jsx': '⚛️',
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

    async hasTsxFiles(dirPath) {
        try {
            const items = await ipcRenderer.invoke('read-directory', dirPath);
            return items.some(item => 
                !item.isDirectory && (item.name.endsWith('.tsx') || item.name.endsWith('.ts'))
            );
        } catch {
            return false;
        }
    }

    async scanForProjects(rootPath) {
        try {
            this.updateStatus('Scanning for projects and TSX files...');
            await this.scanDirectory(rootPath);
            this.renderProjects();
        } catch (error) {
            this.logToConsole(`Error scanning for projects: ${error.message}`, 'error');
        }
    }

    async scanDirectory(dirPath, level = 0) {
        if (level > 2) return;
        
        try {
            const items = await ipcRenderer.invoke('read-directory', dirPath);
            
            // Enhanced project detection
            const projectInfo = await ipcRenderer.invoke('detect-project', dirPath);
            
            if (projectInfo.type !== 'unknown' && projectInfo.type !== 'error') {
                this.projects.set(dirPath, {
                    ...projectInfo,
                    path: dirPath,
                    status: 'stopped'
                });
                
                const projectTypeText = projectInfo.tsxFiles && projectInfo.tsxFiles.length > 0 
                    ? `🚀 Found TSX project: ${projectInfo.name} (${projectInfo.framework})`
                    : `🚀 Found ${projectInfo.framework || projectInfo.type} project: ${projectInfo.name}`;
                
                this.logToConsole(projectTypeText, 'success');
                
                if (projectInfo.isAutoGenerated) {
                    this.logToConsole(`✨ Auto-configured TSX project with ${projectInfo.tsxFiles.length} TSX files`, 'info');
                }
            }
            
            // Recursively scan subdirectories
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
                    <small>Select a folder with package.json or TSX files to get started</small>
                    <button class="btn-primary create-tsx-btn" onclick="app.createTsxProject()">
                        ⚛️ Create TSX Project
                    </button>
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
        
        // Add TSX-specific styling
        if (project.tsxFiles && project.tsxFiles.length > 0) {
            card.classList.add('tsx-project');
        }
        
        const statusClass = project.status === 'running' ? 'status-running' : 
                           project.status === 'installing' ? 'status-installing' : 'status-stopped';
        
        const statusText = project.status === 'running' ? '🟢 Running' : 
                          project.status === 'installing' ? '🟡 Installing' : '🔴 Stopped';
        
        const tsxInfo = project.tsxFiles && project.tsxFiles.length > 0 
            ? `<div class="tsx-info">📝 ${project.tsxFiles.length} TSX files</div>`
            : '';
        
        const autoGenBadge = project.isAutoGenerated 
            ? '<span class="auto-gen-badge">AUTO-CONFIGURED</span>'
            : '';
        
        card.innerHTML = `
            <div class="project-header">
                <div class="project-info">
                    <h4>${project.name} ${autoGenBadge}</h4>
                    <div class="project-type">
                        ${project.framework ? `<span class="type-badge type-${project.type}">${project.framework}</span>` : ''}
                        ${project.buildTool ? `<span class="type-badge">${project.buildTool}</span>` : ''}
                    </div>
                    ${tsxInfo}
                </div>
                <div class="project-status ${statusClass}">
                    ${statusText}
                </div>
            </div>
            <div class="project-path">${project.path}</div>
            <div class="project-actions">
                <button class="btn-small btn-run" onclick="app.runProject('${project.path}')" 
                        ${project.status === 'running' ? 'disabled' : ''}>
                    ▶️ ${project.isAutoGenerated ? 'Setup & Run' : 'Run'}
                </button>
                <button class="btn-small btn-stop" onclick="app.stopProject('${project.path}')" 
                        ${project.status !== 'running' ? 'disabled' : ''}>
                    ⏹️ Stop
                </button>
                <button class="btn-small btn-install" onclick="app.installDependencies('${project.path}')" 
                        ${project.status === 'installing' ? 'disabled' : ''}>
                    📦 ${project.isAutoGenerated ? 'Setup' : 'Install'}
                </button>
            </div>
        `;
        
        return card;
    }

    async createTsxProject() {
        if (!this.currentFolder) {
            this.logToConsole('❌ Please select a folder first', 'error');
            return;
        }
        
        try {
            this.logToConsole('🔨 Creating new TSX project...', 'info');
            
            // Create a new TSX project in a subfolder
            const projectName = `tsx-project-${Date.now()}`;
            const projectPath = require('path').join(this.currentFolder, projectName);
            
            // Create the project using templates
            await this.createProjectFromTemplate(projectPath, 'react-tsx');
            
            this.logToConsole(`✅ Created TSX project: ${projectName}`, 'success');
            this.refreshFileTree();
        } catch (error) {
            this.logToConsole(`❌ Failed to create TSX project: ${error.message}`, 'error');
        }
    }

    async createProjectFromTemplate(projectPath, templateName) {
        const fs = require('fs').promises;
        const path = require('path');
        
        // Create project directory
        await fs.mkdir(projectPath, { recursive: true });
        
        // Copy template files (simplified version - in real implementation you'd copy from templates)
        const packageJson = {
            name: path.basename(projectPath),
            version: '1.0.0',
            type: 'module',
            scripts: {
                dev: 'vite',
                build: 'vite build', 
                start: 'vite',
                preview: 'vite preview'
            },
            dependencies: {
                react: '^18.2.0',
                'react-dom': '^18.2.0'
            },
            devDependencies: {
                '@types/react': '^18.2.0',
                '@types/react-dom': '^18.2.0',
                '@vitejs/plugin-react': '^4.0.0',
                typescript: '^5.0.0',
                vite: '^4.4.0'
            }
        };
        
        await fs.writeFile(
            path.join(projectPath, 'package.json'),
            JSON.stringify(packageJson, null, 2)
        );
        
        // Create src directory and basic files
        const srcPath = path.join(projectPath, 'src');
        await fs.mkdir(srcPath, { recursive: true });
        
        const appTsx = `import React, { useState } from 'react'
import './App.css'

function App() {
  const [count, setCount] = useState(0)

  return (
    <div className="App">
      <h1>React + TypeScript + Vite</h1>
      <div className="card">
        <button onClick={() => setCount((count) => count + 1)}>
          count is {count}
        </button>
        <p>Edit src/App.tsx and save to test HMR</p>
      </div>
      <p>Auto-created by Dev Project Runner!</p>
    </div>
  )
}

export default App`;

        await fs.writeFile(path.join(srcPath, 'App.tsx'), appTsx);
    }

    async runProject(projectPath) {
        try {
            const project = this.projects.get(projectPath);
            if (!project) return;
            
            this.updateProjectStatus(projectPath, 'running');
            this.logToConsole(`🚀 Starting ${project.name}...`, 'info');
            
            if (project.isAutoGenerated) {
                this.logToConsole(`⚡ Auto-setting up TSX project dependencies...`, 'info');
            }
            
            const result = await ipcRenderer.invoke('run-project', projectPath, 'start');
            
            if (result.success) {
                this.runningProjects.set(projectPath, {
                    name: project.name,
                    port: result.port,
                    pid: result.pid
                });
                
                this.updateRunningProjects();
                this.logToConsole(`✅ ${project.name} started on port ${result.port}`, 'success');
                
                if (project.tsxFiles && project.tsxFiles.length > 0) {
                    this.logToConsole(`🎉 TSX project ready! Open http://localhost:${result.port}`, 'success');
                }
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
            
            if (project.isAutoGenerated) {
                this.logToConsole(`📦 Setting up TSX project dependencies for ${project.name}...`, 'info');
            } else {
                this.logToConsole(`📦 Installing dependencies for ${project.name}...`, 'info');
            }
            
            const result = await ipcRenderer.invoke('install-dependencies', projectPath, this.packageManager);
            
            if (result.success) {
                this.updateProjectStatus(projectPath, 'stopped');
                this.logToConsole(`✅ Dependencies ${project.isAutoGenerated ? 'set up' : 'installed'} for ${project.name}`, 'success');
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
                    this.logToConsole(`✅ Dependencies ${project.isAutoGenerated ? 'set up' : 'installed'} successfully for ${project.name}`, 'success');
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
                <small>Select a folder with package.json or TSX files to get started</small>
                <button class="btn-primary create-tsx-btn" onclick="app.createTsxProject()">
                    ⚛️ Create TSX Project
                </button>
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
        
        dot.style.background = status === 'Ready' ? '#238636' :
                              status === 'Error' ? '#f85149' :
                              '#d29922';
    }
}

// Initialize the enhanced app
const app = new EnhancedDevProjectRunner();