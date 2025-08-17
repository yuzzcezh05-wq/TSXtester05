# Dev Project Runner

A standalone Electron application for browsing and running development projects with enhanced Windows environment handling.

## 🚀 Quick Start

### Easy Installation (Recommended)
```bash
# Download and run the enhanced installer
DevProjectRunner-Installer-Enhanced.bat
```

**Choose installation type:**
- **Smart Install** - Auto-detects and fixes environment issues
- **Standard Install** - Full features (requires proper build environment)  
- **Lite Install** - No terminal features (works on any Windows system)

### Manual Installation
```bash
# Basic installation
InstallAndRun.bat

# If you encounter build errors
WindowsEnvFix.bat
```

## 📋 System Requirements

### Minimum Requirements
- Windows 10/11 (64-bit)
- 1GB free disk space
- Internet connection (for initial setup)

### For Full Features (Standard Install)
- Visual Studio 2022 with C++ workload
- Windows SDK (latest)
- Python 3.8+ (added to PATH)
- **Spectre-mitigated libraries** (see troubleshooting)

### For Lite Installation
- Only basic Windows and Node.js

## 🔧 Features

### Standard Installation
✅ Project browsing and detection  
✅ Running npm scripts and commands  
✅ File watching with hot reload  
✅ Port management (auto-finds available ports)  
✅ **Integrated terminal** (node-pty based)  
✅ Multiple project support  

### Lite Installation  
✅ Project browsing and detection  
✅ Running npm scripts and commands  
✅ File watching with hot reload  
✅ Port management  
❌ Integrated terminal (removed for compatibility)  

## 🛠️ Installation Options

### Option 1: Enhanced Installer (Recommended)
```bash
DevProjectRunner-Installer-Enhanced.bat
```
- Smart environment detection
- Automatic issue fixing
- Multiple installation types
- Comprehensive error handling

### Option 2: Environment Fix First
```bash
WindowsEnvFix.bat
```
Use this if you're getting Visual Studio or build errors:
- Detects Visual Studio issues
- Guides Spectre library installation
- Tests build environment
- Provides alternative solutions

### Option 3: Legacy Installers
```bash
DevProjectRunner-Installer-Fixed.bat  # Original with better error handling
InstallAndRun.bat                      # Simple installation
```

## ❌ Common Issues & Solutions

### MSB8040 Error (Spectre Libraries)
**Error:** "Spectre-mitigated libraries are required"
**Fix:** Run `WindowsEnvFix.bat` → Auto-fix → Install Spectre libraries

### node-pty Build Failures  
**Error:** npm install fails during native compilation
**Fix:** Use Lite installation or fix build environment

### Installation Keeps Failing
**Fix:** Try this order:
1. Run as Administrator
2. Use Enhanced Installer  
3. Choose Smart Install
4. Follow recommendations (usually Lite install)

### More Solutions
See `TROUBLESHOOTING.md` for comprehensive troubleshooting guide.

## 📁 Project Structure

```
DevProjectRunner/
├── main.js                     # Main Electron process
├── package.json                # Dependencies
├── renderer/                   # Frontend UI
│   ├── index.html
│   ├── styles.css
│   └── app.js
├── assets/                     # Icons and images
└── Launch Dev Project Runner.bat
```

## 🔍 Supported Project Types

- **React** (Create React App, custom setups)
- **Next.js** 
- **Vue.js**
- **Angular**
- **Svelte**
- **Node.js** projects
- Any project with **package.json**

## 🎛️ Usage

1. **Launch:** Double-click the launcher bat file
2. **Browse:** Select project folders  
3. **Detect:** App automatically detects project type
4. **Run:** Choose npm scripts to execute
5. **Monitor:** File changes trigger auto-reload

## 🧰 Advanced Configuration

### npm Configuration
```bash
# Set Visual Studio version
npm config set msvs_version 2022

# Configure proxy (corporate networks)
npm config set proxy http://proxy:port
npm config set https-proxy http://proxy:port

# Legacy peer deps (compatibility)
npm config set legacy-peer-deps true
```

### Environment Variables
```bash
# Custom installation directory
set INSTALL_DIR=C:\MyApps\DevRunner

# Skip build tools check  
set SKIP_BUILD_CHECK=1
```

## 🔄 Updates & Maintenance

### Update Application
```bash
# From DevProjectRunner directory
npm update
```

### Clear Cache (if issues)
```bash
npm cache clean --force
npm install
```

### Reinstall Dependencies
```bash
# Delete node_modules
rmdir /s node_modules
npm install
```

## 🐛 Troubleshooting

### Quick Diagnostics
```bash
# Check environment
WindowsEnvFix.bat

# Verify installation  
cd DevProjectRunner
npm start
```

### Common Commands
```bash
# Test Node.js
node --version

# Test npm
npm --version

# Test Visual Studio
where msbuild

# Test Python
python --version
```

### Log Files
- `DevProjectRunner\install.log` - Installation details
- `%TEMP%\npm-debug.log` - npm errors
- Console output - Runtime errors

## 📞 Support

### Documentation
- `TROUBLESHOOTING.md` - Comprehensive troubleshooting
- `DEPLOYMENT_GUIDE.md` - Advanced deployment options
- Install logs - Check for specific error messages

### Environment Check Tools
- `WindowsEnvFix.bat` - Complete environment analysis
- `DevProjectRunner-Installer-Enhanced.bat` - Smart installer
- System Info option in installers

## 🔒 Security Notes

- App uses Node.js integration (required for file system access)
- Only processes local files and npm commands
- No external network requests except npm registry
- Safe for corporate environments (with proper proxy config)

## 📊 Installation Size

| Type | Download | Installed | Features |
|------|----------|-----------|----------|
| Lite | ~50MB | ~300MB | Basic (no terminal) |
| Standard | ~100MB | ~500MB | Full (with terminal) |
| With Node.js | +50MB | +50MB | If Node.js not installed |

## 🏗️ Development

This app is built with:
- **Electron** - Desktop framework
- **Node.js** - Runtime environment  
- **Chokidar** - File watching
- **node-pty** - Terminal integration (standard only)
- **Portfinder** - Port management

## 📄 License

MIT License - See LICENSE file for details

---

**Note:** This application is designed to work offline after initial setup. Internet is only required for downloading dependencies during installation.
