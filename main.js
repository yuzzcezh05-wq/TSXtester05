const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron');
const path = require('path');
const fs = require('fs').promises;
const { spawn, exec } = require('child_process');
const chokidar = require('chokidar');
const treeKill = require('tree-kill');
const portfinder = require('portfinder');

class ProjectRunner {
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

    // Remove menu bar
    this.mainWindow.setMenuBarVisibility(false);
  }

  async cleanup() {
    // Kill all running projects
    for (let [projectPath, process] of this.runningProjects) {
      if (process.pid) {
        treeKill(process.pid);
      }
    }
    
    // Close file watchers
    for (let [path, watcher] of this.fileWatchers) {
      await watcher.close();
    }
    
    this.runningProjects.clear();
    this.fileWatchers.clear();
  }

  setupIPC() {
    // Browse for folder
    ipcMain.handle('browse-folder', async () => {
      const result = await dialog.showOpenDialog(this.mainWindow, {
        properties: ['openDirectory'],
        title: 'Select Project Folder'
      });
      
      return result.canceled ? null : result.filePaths[0];
    });

    // Read directory contents
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

    // Detect project type
    ipcMain.handle('detect-project', async (event, projectPath) => {
      try {
        const packageJsonPath = path.join(projectPath, 'package.json');
        const hasPackageJson = await fs.access(packageJsonPath).then(() => true).catch(() => false);
        
        if (!hasPackageJson) {
          return { type: 'unknown', hasPackageJson: false };
        }

        const packageJson = JSON.parse(await fs.readFile(packageJsonPath, 'utf8'));
        const dependencies = { ...packageJson.dependencies, ...packageJson.devDependencies };
        
        let projectType = 'unknown';
        let framework = '';
        let buildTool = '';

        // Detect framework
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

        // Detect build tool
        if (dependencies.vite) buildTool = 'Vite';
        else if (dependencies.webpack) buildTool = 'Webpack';
        else if (dependencies.parcel) buildTool = 'Parcel';
        else if (dependencies.rollup) buildTool = 'Rollup';

        return {
          type: projectType,
          framework,
          buildTool,
          hasPackageJson: true,
          packageJson,
          scripts: packageJson.scripts || {},
          name: packageJson.name || path.basename(projectPath)
        };
      } catch (error) {
        return { type: 'error', error: error.message };
      }
    });

    // Run project
    ipcMain.handle('run-project', async (event, projectPath, command = 'start') => {
      try {
        // Find available port
        const port = await portfinder.getPortPromise({ port: 3000 });
        
        // Change to project directory and run command
        const child = spawn('npm', ['run', command], {
          cwd: projectPath,
          stdio: 'pipe',
          shell: true,
          env: { ...process.env, PORT: port.toString() }
        });

        this.runningProjects.set(projectPath, child);

        // Send output to renderer
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

    // Stop project
    ipcMain.handle('stop-project', async (event, projectPath) => {
      const process = this.runningProjects.get(projectPath);
      if (process && process.pid) {
        treeKill(process.pid);
        this.runningProjects.delete(projectPath);
        return { success: true };
      }
      return { success: false, error: 'Project not running' };
    });

    // Install dependencies
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

    // Open in file explorer
    ipcMain.handle('open-in-explorer', async (event, filePath) => {
      shell.showItemInFolder(filePath);
    });
  }
}

const projectRunner = new ProjectRunner();

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