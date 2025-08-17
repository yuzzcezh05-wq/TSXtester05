# Dev Project Runner Enhanced 🚀

> **Zero-config development tool with automatic TSX/TypeScript support**

A powerful desktop application that automatically detects and runs development projects, with special focus on **seamless TSX support**. Just drop TSX files in any folder and run them instantly - no configuration needed!

![Dev Project Runner Enhanced](https://img.shields.io/badge/Version-2.0.0-blue) ![Platform](https://img.shields.io/badge/Platform-Windows%20%7C%20macOS%20%7C%20Linux-green) ![License](https://img.shields.io/badge/License-MIT-yellow)

## ✨ Key Features

### 🎯 **Automatic TSX Detection**
- **Drop & Run**: Place `.tsx` files in any folder → Auto-detected as React project
- **Zero Config**: No `package.json` needed → Auto-generated with optimal setup
- **Smart Setup**: Automatically configures Vite + React + TypeScript
- **One-Click**: Install dependencies and run with single button press

### 🚀 **Enhanced Project Support**
- **React TSX**: Vite + React + TypeScript (auto-configured)
- **Next.js TS**: TypeScript Next.js projects  
- **Create React App TS**: CRA with TypeScript
- **Vue.js**: Vue 3 projects with TypeScript support
- **Angular**: Angular projects with TypeScript
- **Legacy Projects**: All existing JS/JSX projects

### 💫 **Smart Features**
- **Visual Indicators**: TSX files highlighted with special badges
- **Auto-Generation**: Creates `package.json`, `vite.config.ts`, `tsconfig.json`
- **Template System**: Built-in project templates for quick setup
- **Hot Reload**: File watching with instant recompilation
- **Port Management**: Automatically finds available ports
- **Multi-Project**: Run multiple projects simultaneously

## 🎬 Quick Start Guide

### **From GitHub Download to Running App in 3 Steps:**

#### **Step 1: Download & Extract**
```bash
# Download the ZIP from GitHub
# Extract to any folder (e.g., C:\DevTools\dev-project-runner\)
```

#### **Step 2: Run Setup**
```bash
# Windows:
SETUP.bat

# macOS/Linux:
./setup.sh           # Coming soon - use npm install for now
npm install
```

#### **Step 3: Launch**
```bash
# All platforms:
npm start

# The Electron desktop app will open
```

### **TSX Support Demo (30 seconds):**
```bash
# Create a folder with TSX files anywhere
mkdir my-tsx-project
cd my-tsx-project

# Drop any .tsx file (App.tsx, index.tsx, etc.)
# Open Dev Project Runner → Browse to folder
# Project auto-detected → Click "Setup & Run"
# Dependencies auto-installed → App launches on localhost!
```

## 📁 Project Structure (Clean & Organized)

```
dev-project-runner/
├── main.js                    # Main Electron process (enhanced version)
├── package.json               # Dependencies and scripts
├── SETUP.bat                  # One-click Windows installer
├── renderer/
│   ├── index.html             # Main UI
│   ├── app.js                 # Enhanced frontend with TSX support
│   └── styles.css             # Enhanced styling
├── templates/                 # Built-in project templates
│   └── react-basic/           # React starter template
├── scripts/
│   └── setup.js              # Auto-setup & template creation
├── assets/
│   └── icon.png              # Application icon
└── README.md                  # This file
```

## 🛠️ Installation Options

### **Option 1: Quick Install (Recommended)**
```bash
# Clone or download ZIP
git clone <your-repo-url>
cd dev-project-runner

# Run setup (Windows)
SETUP.bat

# Or manual (all platforms)
npm install
npm start
```

### **Option 2: Development Setup**
```bash
# For contributors/developers
npm install
npm run dev        # Development mode with debugging
```

### **Option 3: Portable Install**
```bash
# No installation required
# Just extract ZIP and run npm start
# Perfect for USB drives or temporary use
```

## 🎯 System Requirements

### **Minimum Requirements:**
- **Windows 10/11, macOS 10.14+, or Linux (Ubuntu 18.04+)**
- **Node.js 16+** (will auto-install if missing)
- **1GB RAM, 500MB disk space**
- **Internet connection** (for initial setup only)

### **For Full Features:**
- **TypeScript/TSX support**: Works out of the box
- **Multiple projects**: 4GB RAM recommended
- **Hot reload**: SSD recommended for best performance

## 🔧 Usage Guide

### **Basic Workflow:**
1. **Launch App**: Run `npm start` or double-click launcher
2. **Browse Folder**: Click "Browse Folder" and select project directory
3. **Auto-Detection**: App scans for projects and TSX files
4. **Run Projects**: Click "Run" or "Setup & Run" for auto-configured projects
5. **Monitor**: View console output and manage running processes

### **TSX Project Workflow:**
```
📁 Drop .tsx files in folder
    ↓
🔍 Auto-detected as React project  
    ↓
⚡ Auto-generates package.json + vite.config.ts
    ↓
📦 Click "Setup & Run" → Dependencies install
    ↓
🚀 Project launches on localhost
```

### **Supported Project Types:**
- ✅ **React** (Create React App, Vite, custom setups)
- ✅ **Next.js** (with TypeScript support)
- ✅ **Vue.js** (Vue 3 + TypeScript)
- ✅ **Angular** (with TypeScript)
- ✅ **Svelte/SvelteKit**
- ✅ **Node.js** projects
- ✅ **Any project with package.json**

## 🎨 Enhanced UI Features

### **Visual Indicators:**
- **TSX Badge**: Files with `.tsx` extension show ⚛️ icon
- **Project Highlighting**: TSX projects have distinctive blue styling
- **Auto-Gen Badge**: Auto-configured projects show "AUTO-CONFIGURED" label
- **Status Colors**: Green (running), red (stopped), yellow (installing)

### **Smart Project Cards:**
```
┌─────────────────────────────────────┐
│ 🚀 my-tsx-project [AUTO-CONFIGURED] │
│ ⚛️ Vite + React + TypeScript         │  
│ 📝 3 TSX files                      │
│ [Setup & Run] [Stop] [Setup]        │
└─────────────────────────────────────┘
```

### **Console Features:**
- **Color-coded output**: Success (green), errors (red), info (blue)
- **Real-time updates**: Installation progress, compilation status
- **TSX notifications**: Setup completion, port assignments

## ⚡ Performance & Optimization

### **Lightning Fast:**
- **Startup**: ~2-3 seconds to launch
- **Project Detection**: Scans folders in <1 second
- **TSX Setup**: Auto-configures projects in 10-30 seconds
- **Memory Usage**: ~150-200MB typical

### **Smart Caching:**
- **Dependency Caching**: npm packages cached locally
- **Template Caching**: Project templates load instantly
- **Port Management**: Remembers port preferences per project

## 🔍 Troubleshooting

### **Common Issues & Solutions:**

| Problem | Solution |
|---------|----------|
| **App won't start** | Ensure Node.js 16+ installed, run `npm install` |
| **TSX files not detected** | Check file extensions (.tsx), refresh folder view |
| **Auto-setup fails** | Check internet connection, try manual `npm install` |
| **Port conflicts** | App auto-finds available ports (3000, 3001, 3002...) |
| **Build errors** | Run `SETUP.bat` for environment fixes (Windows) |

### **Debug Commands:**
```bash
# Check Node.js version
node --version

# Test npm
npm --version

# Clear npm cache
npm cache clean --force

# Reinstall dependencies
rm -rf node_modules
npm install

# Verbose startup
npm start --verbose
```

## 🤝 Contributing

### **Development Setup:**
```bash
git clone <repo-url>
cd dev-project-runner
npm install
npm run dev        # Development mode
```

### **Adding TSX Support for New Frameworks:**
1. Edit `main.js` → `detectTsxProject()` method
2. Add framework detection logic
3. Update UI in `renderer/app.js`
4. Add template in `/templates` folder
5. Test with sample TSX projects

### **File Structure for Contributors:**
- **Backend Logic**: `main.js` (Electron main process)
- **Frontend UI**: `renderer/app.js` (Enhanced with TSX support)
- **Styling**: `renderer/styles.css` (Modern, responsive design)
- **Templates**: `templates/` (Project starter templates)

## 📊 What's New in Enhanced Version

### **🆕 Version 2.0.0 Features:**
1. **Zero-Config TSX**: Drop TSX files anywhere → instant project
2. **Auto-Configuration**: Smart package.json and vite.config.ts generation
3. **Enhanced Detection**: Detects React, Vue, Angular, Next.js with TypeScript
4. **Visual Excellence**: TSX-specific UI indicators and animations
5. **One-Click Setup**: Dependencies install automatically
6. **GitHub Ready**: Clean structure, proper documentation

### **🔄 Migrating from v1.x:**
- Enhanced versions are backward compatible
- All existing projects will continue to work
- New TSX features work alongside existing functionality
- No breaking changes to core functionality

## 📄 License & Credits

**MIT License** - Feel free to use, modify, and distribute.

### **Built With:**
- **Electron 28.0.0** - Desktop framework
- **Node.js** - Runtime environment  
- **Chokidar** - File watching
- **Portfinder** - Port management
- **Tree-kill** - Process management

### **Special Thanks:**
- React community for TSX inspiration
- Electron team for the amazing framework
- Contributors and testers

---

## 🎉 Why Choose Dev Project Runner Enhanced?

1. **🚀 Zero Configuration**: Works instantly with any project structure
2. **⚡ Lightning Fast**: Optimized for speed and performance
3. **🎯 TSX Focused**: First-class TypeScript + React support
4. **🎨 Beautiful UI**: Modern, intuitive interface
5. **🔧 Developer Friendly**: Made by developers, for developers
6. **📱 Cross-Platform**: Windows, macOS, Linux support
7. **🆓 Open Source**: MIT license, contribute freely

**Perfect for:** React developers, TypeScript enthusiasts, rapid prototyping, learning projects, team collaboration, and anyone who wants to run development projects effortlessly.

---

**🚀 Ready to enhance your development workflow? Download, extract, run `SETUP.bat`, and start building amazing projects in seconds!**

*Built with ❤️ for the developer community. Star ⭐ this repo if you find it useful!*
