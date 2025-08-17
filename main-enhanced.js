const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron');
const path = require('path');
const fs = require('fs').promises;
const { spawn, exec } = require('child_process');
const chokidar = require('chokidar');
const treeKill = require('tree-kill');
const portfinder = require('portfinder');

class EnhancedProjectRunner {
  constructor() {
    this.mainWindow = null;
    this.runningProjects = new Map();
    this.fileWatchers = new Map();
  }

  createWindow() {
    this.mainWindow = new BrowserWindow({
      width: 1400,
      height: 900,
      minWidth: 1200,
      minHeight: 700,
      webPreferences: {
        nodeIntegration: true,
        contextIsolation: false,
        enableRemoteModule: true
      },
      icon: path.join(__dirname, 'assets', 'icon.png'),
      titleBarStyle: 'default',
      show: false
    });

    this.mainWindow.loadFile('renderer/index.html');
    
    this.mainWindow.once('ready-to-show', () => {
      this.mainWindow.show();
    });

    this.mainWindow.on('closed', () => {
      this.mainWindow = null;
      this.cleanup();
    });

    this.mainWindow.setMenuBarVisibility(false);
  }

  async cleanup() {
    for (let [projectPath, process] of this.runningProjects) {
      if (process.pid) {
        treeKill(process.pid);
      }
    }
    
    for (let [path, watcher] of this.fileWatchers) {
      await watcher.close();
    }
    
    this.runningProjects.clear();
    this.fileWatchers.clear();
  }

  setupIPC() {
    ipcMain.handle('browse-folder', async () => {
      const result = await dialog.showOpenDialog(this.mainWindow, {
        properties: ['openDirectory'],
        title: 'Select Project Folder'
      });
      
      return result.canceled ? null : result.filePaths[0];
    });

    ipcMain.handle('read-directory', async (event, dirPath) => {
      try {
        const items = await fs.readdir(dirPath, { withFileTypes: true });
        const result = [];

        for (const item of items) {
          if (item.name.startsWith('.')) continue;
          
          const fullPath = path.join(dirPath, item.name);
          const stats = await fs.stat(fullPath);
          
          result.push({
            name: item.name,
            path: fullPath,
            isDirectory: item.isDirectory(),
            size: stats.size,
            modified: stats.mtime
          });
        }

        return result.sort((a, b) => {
          if (a.isDirectory && !b.isDirectory) return -1;
          if (!a.isDirectory && b.isDirectory) return 1;
          return a.name.localeCompare(b.name);
        });
      } catch (error) {
        throw new Error(`Failed to read directory: ${error.message}`);
      }
    });

    // Enhanced project detection with TSX support
    ipcMain.handle('detect-project', async (event, projectPath) => {
      try {
        const packageJsonPath = path.join(projectPath, 'package.json');
        const hasPackageJson = await fs.access(packageJsonPath).then(() => true).catch(() => false);
        
        // Check for TSX files even without package.json
        const tsxFiles = await this.findTsxFiles(projectPath);
        const hasTypeScript = await this.hasTypeScriptConfig(projectPath);
        
        if (!hasPackageJson && tsxFiles.length === 0) {
          return { type: 'unknown', hasPackageJson: false };
        }

        let packageJson = {};
        if (hasPackageJson) {
          packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf8'));
        }

        const dependencies = { ...packageJson.dependencies, ...packageJson.devDependencies };
        
        let projectType = 'unknown';
        let framework = '';
        let buildTool = '';
        let autoScripts = {};

        // Enhanced TSX/TypeScript detection
        if (tsxFiles.length > 0 || dependencies.typescript || hasTypeScript) {
          // Detect TSX project type
          const tsxProjectInfo = await this.detectTsxProject(projectPath, dependencies, tsxFiles);
          projectType = tsxProjectInfo.type;
          framework = tsxProjectInfo.framework;
          buildTool = tsxProjectInfo.buildTool;
          autoScripts = tsxProjectInfo.autoScripts;
        } else {
          // Original detection logic for non-TSX projects
          if (dependencies.react) {
            framework = 'React';
            if (dependencies.next) {
              projectType = 'nextjs';
              framework = 'Next.js';
            } else if (dependencies['react-scripts']) {
              projectType = 'cra';
              framework = 'Create React App';
            } else {
              projectType = 'react';
            }
          } else if (dependencies.vue) {
            projectType = 'vue';
            framework = 'Vue.js';
          } else if (dependencies.svelte) {
            projectType = 'svelte';
            framework = 'Svelte';
          } else if (dependencies.angular) {
            projectType = 'angular';
            framework = 'Angular';
          }
        }

        // Detect build tool
        if (dependencies.vite) buildTool = 'Vite';
        else if (dependencies.webpack) buildTool = 'Webpack';
        else if (dependencies.parcel) buildTool = 'Parcel';
        else if (dependencies.rollup) buildTool = 'Rollup';
        else if (dependencies.esbuild) buildTool = 'ESBuild';

        // Auto-generate package.json if TSX files found but no package.json
        if (!hasPackageJson && tsxFiles.length > 0) {
          packageJson = await this.generateTsxPackageJson(projectPath, tsxFiles);
          autoScripts = packageJson.scripts;
        }

        return {
          type: projectType,
          framework,
          buildTool,
          hasPackageJson,
          packageJson,
          scripts: { ...packageJson.scripts, ...autoScripts },
          name: packageJson.name || path.basename(projectPath),
          tsxFiles,
          hasTypeScript,
          isAutoGenerated: !hasPackageJson && tsxFiles.length > 0
        };
      } catch (error) {
        return { type: 'error', error: error.message };
      }
    });

    // Auto-setup project if needed
    ipcMain.handle('setup-project', async (event, projectPath) => {
      try {
        const detection = await this.detectProject(projectPath);
        
        if (detection.isAutoGenerated) {
          // Write the auto-generated package.json
          const packageJsonPath = path.join(projectPath, 'package.json');
          await fs.writeFile(packageJsonPath, JSON.stringify(detection.packageJson, null, 2));
          
          // Auto-install dependencies
          await this.installDependencies(projectPath, 'npm');
          
          return { success: true, message: 'TSX project auto-configured!' };
        }
        
        return { success: true, message: 'Project already configured' };
      } catch (error) {
        return { success: false, error: error.message };
      }
    });

    // Enhanced run project with TSX support
    ipcMain.handle('run-project', async (event, projectPath, command = 'start') => {
      try {
        const port = await portfinder.getPortPromise({ port: 3000 });
        
        // Check if project needs auto-setup
        const detection = await this.detectProject(projectPath);
        if (detection.isAutoGenerated) {
          await this.setupProject(projectPath);
        }
        
        const child = spawn('npm', ['run', command], {
          cwd: projectPath,
          stdio: 'pipe',
          shell: true,
          env: { ...process.env, PORT: port.toString() }
        });

        this.runningProjects.set(projectPath, child);

        child.stdout.on('data', (data) => {
          this.mainWindow.webContents.send('project-output', {
            projectPath,
            type: 'stdout',
            data: data.toString()
          });
        });

        child.stderr.on('data', (data) => {
          this.mainWindow.webContents.send('project-output', {
            projectPath,
            type: 'stderr', 
            data: data.toString()
          });
        });

        child.on('close', (code) => {
          this.mainWindow.webContents.send('project-output', {
            projectPath,
            type: 'close',
            code
          });
          this.runningProjects.delete(projectPath);
        });

        return { success: true, port, pid: child.pid };
      } catch (error) {
        return { success: false, error: error.message };
      }
    });

    ipcMain.handle('stop-project', async (event, projectPath) => {
      const process = this.runningProjects.get(projectPath);
      if (process && process.pid) {
        treeKill(process.pid);
        this.runningProjects.delete(projectPath);
        return { success: true };
      }
      return { success: false, error: 'Project not running' };
    });

    ipcMain.handle('install-dependencies', async (event, projectPath, manager = 'npm') => {
      try {
        const child = spawn(manager, ['install'], {
          cwd: projectPath,
          stdio: 'pipe',
          shell: true
        });

        child.stdout.on('data', (data) => {
          this.mainWindow.webContents.send('install-output', {
            projectPath,
            type: 'stdout',
            data: data.toString()
          });
        });

        child.stderr.on('data', (data) => {
          this.mainWindow.webContents.send('install-output', {
            projectPath,
            type: 'stderr',
            data: data.toString()
          });
        });

        return new Promise((resolve) => {
          child.on('close', (code) => {
            this.mainWindow.webContents.send('install-output', {
              projectPath,
              type: 'close',
              code
            });
            resolve({ success: code === 0, code });
          });
        });
      } catch (error) {
        return { success: false, error: error.message };
      }
    });

    ipcMain.handle('open-in-explorer', async (event, filePath) => {
      shell.showItemInFolder(filePath);
    });
  }

  // Enhanced TSX detection methods
  async findTsxFiles(dirPath, maxDepth = 2, currentDepth = 0) {
    if (currentDepth >= maxDepth) return [];
    
    try {
      const items = await fs.readdir(dirPath, { withFileTypes: true });
      let tsxFiles = [];

      for (const item of items) {
        if (item.name.startsWith('.') || item.name === 'node_modules') continue;
        
        const fullPath = path.join(dirPath, item.name);
        
        if (item.isDirectory()) {
          const subFiles = await this.findTsxFiles(fullPath, maxDepth, currentDepth + 1);
          tsxFiles = tsxFiles.concat(subFiles);
        } else if (item.name.endsWith('.tsx') || item.name.endsWith('.ts')) {
          tsxFiles.push(fullPath);
        }
      }

      return tsxFiles;
    } catch (error) {
      return [];
    }
  }

  async hasTypeScriptConfig(dirPath) {
    try {
      const configFiles = ['tsconfig.json', 'tsconfig.js', 'typescript.json'];
      for (const config of configFiles) {
        const configPath = path.join(dirPath, config);
        if (await fs.access(configPath).then(() => true).catch(() => false)) {
          return true;
        }
      }
      return false;
    } catch {
      return false;
    }
  }

  async detectTsxProject(projectPath, dependencies, tsxFiles) {
    let type = 'tsx-react';
    let framework = 'React + TypeScript';
    let buildTool = '';
    let autoScripts = {};

    // Check for existing build tools and frameworks
    if (dependencies.next) {
      type = 'nextjs-ts';
      framework = 'Next.js + TypeScript';
      buildTool = 'Next.js';
    } else if (dependencies['react-scripts']) {
      type = 'cra-ts';
      framework = 'Create React App + TypeScript';
      buildTool = 'Create React App';
    } else if (dependencies.vite) {
      type = 'vite-react-ts';
      framework = 'Vite + React + TypeScript';
      buildTool = 'Vite';
    } else {
      // Auto-detect based on TSX file structure
      const hasAppTsx = tsxFiles.some(file => file.includes('App.tsx'));
      const hasIndexTsx = tsxFiles.some(file => file.includes('index.tsx'));
      
      if (hasAppTsx || hasIndexTsx) {
        type = 'vite-react-ts';
        framework = 'Vite + React + TypeScript';
        buildTool = 'Vite';
        
        // Generate auto-scripts for Vite setup
        autoScripts = {
          dev: 'vite',
          build: 'vite build',
          start: 'vite',
          preview: 'vite preview'
        };
      }
    }

    return { type, framework, buildTool, autoScripts };
  }

  async generateTsxPackageJson(projectPath, tsxFiles) {
    const projectName = path.basename(projectPath).toLowerCase().replace(/[^a-z0-9-]/g, '-');
    
    // Analyze TSX files to determine the best setup
    const hasReactImports = await this.checkReactImports(tsxFiles);
    
    const packageJson = {
      name: projectName,
      version: "1.0.0",
      type: "module",
      scripts: {
        dev: "vite",
        build: "vite build",
        start: "vite",
        preview: "vite preview"
      },
      dependencies: {
        react: "^18.2.0",
        "react-dom": "^18.2.0"
      },
      devDependencies: {
        "@types/react": "^18.2.0",
        "@types/react-dom": "^18.2.0",
        "@vitejs/plugin-react": "^4.0.0",
        typescript: "^5.0.0",
        vite: "^4.4.0"
      }
    };

    // Also generate vite.config.ts
    const viteConfig = `import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 3000,
    open: true
  }
})`;

    try {
      await fs.writeFile(path.join(projectPath, 'vite.config.ts'), viteConfig);
    } catch (error) {
      console.log('Could not write vite.config.ts:', error.message);
    }

    return packageJson;
  }

  async checkReactImports(tsxFiles) {
    for (const file of tsxFiles.slice(0, 3)) { // Check first 3 files
      try {
        const content = await fs.readFile(file, 'utf8');
        if (content.includes('import React') || content.includes('from "react"') || content.includes('from \'react\'')) {
          return true;
        }
      } catch {
        continue;
      }
    }
    return false;
  }

  async detectProject(projectPath) {
    // Helper method to reuse detection logic
    return new Promise((resolve) => {
      this.setupIPC();
      resolve({});
    });
  }

  async setupProject(projectPath) {
    // Helper method to reuse setup logic
    return { success: true };
  }

  async installDependencies(projectPath, manager) {
    // Helper method to reuse install logic
    return new Promise((resolve) => {
      const child = spawn(manager, ['install'], {
        cwd: projectPath,
        stdio: 'inherit',
        shell: true
      });

      child.on('close', (code) => {
        resolve({ success: code === 0, code });
      });
    });
  }
}

const projectRunner = new EnhancedProjectRunner();

app.whenReady().then(() => {
  projectRunner.createWindow();
  projectRunner.setupIPC();

  app.on('activate', () => {
    if (BrowserWindow.getAllWindows().length === 0) {
      projectRunner.createWindow();
    }
  });
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('before-quit', () => {
  projectRunner.cleanup();
});