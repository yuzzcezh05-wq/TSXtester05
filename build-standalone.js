const { execSync } = require('child_process');
const fs = require('fs');
const path = require('path');

console.log('🚀 Building standalone Dev Project Runner...');

// Create dist directory
if (!fs.existsSync('dist-standalone')) {
    fs.mkdirSync('dist-standalone');
}

// Build the Electron app
console.log('📦 Building Electron application...');
try {
    execSync('npm run build', { stdio: 'inherit' });
} catch (error) {
    console.error('Build failed:', error);
    process.exit(1);
}

// Copy templates
console.log('📋 Copying templates...');
const templatesSource = path.join(__dirname, 'templates');
const templatesTarget = path.join(__dirname, 'dist-standalone', 'templates');

if (fs.existsSync(templatesSource)) {
    fs.cpSync(templatesSource, templatesTarget, { recursive: true });
}

// Create launch script for Windows
const windowsLauncher = `@echo off
echo Starting Dev Project Runner...
cd /d "%~dp0"
if exist "Dev Project Runner.exe" (
    start "" "Dev Project Runner.exe"
) else (
    echo Error: Dev Project Runner.exe not found
    pause
)`;

fs.writeFileSync(path.join(__dirname, 'dist-standalone', 'Launch.bat'), windowsLauncher);

// Create launch script for macOS/Linux
const unixLauncher = `#!/bin/bash
echo "Starting Dev Project Runner..."
cd "$(dirname "$0")"
if [ -f "./Dev Project Runner" ]; then
    ./Dev\ Project\ Runner
elif [ -f "./Dev Project Runner.app/Contents/MacOS/Dev Project Runner" ]; then
    open "./Dev Project Runner.app"
else
    echo "Error: Dev Project Runner executable not found"
    read -p "Press enter to continue"
fi`;

fs.writeFileSync(path.join(__dirname, 'dist-standalone', 'launch.sh'), unixLauncher);
fs.chmodSync(path.join(__dirname, 'dist-standalone', 'launch.sh'), '755');

// Create README
const readme = `# Dev Project Runner - Standalone Edition

## 🚀 What is this?

Dev Project Runner is a standalone desktop application that helps you browse, detect, and run development projects from any folder on your computer.

## ✨ Features

- **File System Browser**: Navigate through folders like Windows Explorer
- **Project Detection**: Automatically detects React, Next.js, Vue, Svelte projects
- **One-Click Running**: Start projects with a single click
- **Dependency Management**: Install npm/yarn/pnpm packages automatically
- **Real-time Console**: See build outputs and logs in real-time
- **Fully Offline**: Works completely offline - no internet required

## 🖥️ How to Use

### Windows:
1. Double-click \`Launch.bat\` or \`Dev Project Runner.exe\`

### macOS:
1. Double-click \`Dev Project Runner.app\` or run \`./launch.sh\`

### Linux:
1. Run \`./launch.sh\` or execute the binary directly

## 📁 Supported Project Types

- **React** (Create React App, Custom React)
- **Next.js** (Full-stack React framework)
- **Vue.js** (Vue 2 & 3)
- **Svelte** (Svelte & SvelteKit)
- **Vite** (Any Vite-based project)
- **Custom npm projects** (Any project with package.json)

## 🛠️ How It Works

1. **Browse**: Click "Browse Folder" to select your projects directory
2. **Detect**: App automatically scans for projects with package.json files
3. **Install**: Click "Install" to install project dependencies
4. **Run**: Click "Run" to start the development server
5. **Monitor**: Watch real-time logs in the console panel

## ⚡ Quick Start

1. Launch the application
2. Click "Browse Folder" and select a folder containing your projects
3. The app will automatically detect all projects in subdirectories
4. Click "Install" on any project to install dependencies
5. Click "Run" to start the development server
6. Your project will open in your default browser

## 🔧 Package Managers

Supports all major package managers:
- **npm** (default)
- **yarn** 
- **pnpm**

Switch between them using the dropdown in the Project Dashboard.

## 📦 What's Included

This standalone package includes:
- Node.js runtime (v18+)
- npm, yarn, pnpm package managers
- Build tools (Vite, Webpack, Parcel)
- Framework support (React, Vue, Svelte)
- Project templates

## 💡 Tips

- **Multiple Projects**: You can run multiple projects simultaneously
- **Port Management**: App automatically assigns available ports
- **File Watching**: Changes to files are detected automatically
- **Stop All**: Use "Stop All" button to stop all running projects
- **Explorer Integration**: Click "Open Explorer" to open current folder

## 🐛 Troubleshooting

### Project won't start?
- Make sure dependencies are installed (click "Install")
- Check the console for error messages
- Verify the project has a valid package.json

### Port already in use?
- The app automatically finds available ports
- If issues persist, restart the application

### Dependencies failing to install?
- Check your internet connection
- Try switching package managers (npm → yarn → pnpm)
- Delete node_modules folder and try again

## 📄 License

MIT License - Feel free to use and modify!

## 🎯 Version

Standalone Edition v1.0.0
Built with Electron + Node.js

---

**Happy Coding! 🚀**
`;

fs.writeFileSync(path.join(__dirname, 'dist-standalone', 'README.md'), readme);

console.log('✅ Standalone build complete!');
console.log('📁 Files are in: dist-standalone/');
console.log('🎯 Ready to distribute!');