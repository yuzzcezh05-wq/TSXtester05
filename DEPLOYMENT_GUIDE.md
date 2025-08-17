# 🚀 Dev Project Runner - Deployment Guide

## Overview
**Dev Project Runner** is a standalone Electron desktop application that allows users to browse Windows Explorer folders, detect development projects (React, Vue, Svelte, etc.), and run them without needing localhost setup or internet connection.

## ✨ Key Features

### 🎯 **Core Functionality**
- **File System Browser**: Navigate project directories like Windows Explorer
- **Automatic Project Detection**: Detects React, Next.js, Vue, Svelte, and other frameworks
- **One-Click Project Running**: Start development servers instantly
- **Dependency Management**: Auto-install npm/yarn/pnpm packages
- **Multi-Project Support**: Run multiple projects simultaneously with auto-port assignment
- **Real-time Console**: Monitor build outputs and logs
- **Fully Offline**: Works without internet (once packaged)

### 🖥️ **Interface Design**
- **Left Panel**: File Explorer with project badges
- **Center Panel**: Project Dashboard with status indicators
- **Right Panel**: Quick actions and running projects list
- **Bottom Panel**: Terminal/Console output
- **Modern Dark Theme**: Developer-friendly interface

### 📦 **Bundled Tools**
- Node.js runtime (v18+)
- Package managers: npm, yarn, pnpm
- Build tools: Vite, Webpack, Parcel, Rollup
- Framework support: React, Vue, Svelte, Next.js
- Project templates and boilerplates

## 🏗️ Build Process

### Prerequisites
- Node.js 18+ installed
- Git for version control
- Windows/macOS/Linux for cross-platform builds

### Step 1: Install Dependencies
```bash
cd /app
npm install
```

### Step 2: Build Electron Application
```bash
# Build for current platform
npm run build

# Build for all platforms
npm run dist

# Build standalone package
npm run build-standalone
```

### Step 3: Package Structure
After building, you'll get:
```
dist/
├── Dev Project Runner.exe        # Windows executable
├── Dev Project Runner.app/       # macOS application bundle
├── Dev Project Runner.AppImage   # Linux AppImage
└── resources/                    # Bundled resources
    ├── templates/               # Project templates
    ├── tools/                   # Build tools
    └── node_modules/            # Embedded packages
```

## 📥 Distribution Options

### Option 1: Direct Download Package
Create a `.zip` file containing:
```
DevProjectRunner/
├── DevProjectRunner.html        # Double-click launcher
├── Dev Project Runner.exe       # Main executable
├── Launch.bat                   # Windows batch launcher
├── launch.sh                    # Unix shell launcher
├── README.md                    # User instructions
└── resources/                   # All bundled files
```

### Option 2: Installer Package
Use electron-builder to create installers:
```bash
# Windows NSIS installer
npm run build -- --win nsis

# macOS DMG
npm run build -- --mac dmg

# Linux AppImage
npm run build -- --linux AppImage
```

### Option 3: Portable Package
Create a portable folder that users can:
- Download and extract
- Move anywhere on their system
- Run without installation
- Use offline completely

## 🔧 Configuration Files

### package.json Build Config
```json
{
  "build": {
    "appId": "com.devrunner.app",
    "productName": "Dev Project Runner",
    "directories": {
      "output": "dist"
    },
    "extraResources": [
      {
        "from": "templates",
        "to": "templates"
      }
    ],
    "win": {
      "target": "nsis",
      "icon": "assets/icon.ico"
    }
  }
}
```

### main.js IPC Handlers
- `browse-folder`: Open folder selection dialog
- `read-directory`: List directory contents
- `detect-project`: Analyze project type
- `run-project`: Start development server
- `stop-project`: Kill running processes
- `install-dependencies`: Run package installation

## 📋 User Instructions

### For Windows Users:
1. Extract the downloaded package
2. Double-click `DevProjectRunner.html` for guided launch
3. Or directly run `Dev Project Runner.exe`
4. Or use `Launch.bat` for batch execution

### For macOS Users:
1. Extract the package
2. Run `Dev Project Runner.app`
3. Or use `./launch.sh` from terminal

### For Linux Users:
1. Extract the package
2. Make executable: `chmod +x "Dev Project Runner"`
3. Run: `./Dev Project Runner`
4. Or use `./launch.sh`

## 🎯 Usage Workflow

1. **Launch**: Start the application using any method above
2. **Browse**: Click "Browse Folder" to select project directory
3. **Detect**: App automatically scans for projects with package.json
4. **Install**: Click "Install" on any project to install dependencies
5. **Run**: Click "Run" to start the development server
6. **Monitor**: Watch real-time logs in the console panel
7. **Stop**: Use "Stop" button or "Stop All" for cleanup

## 🔧 Technical Architecture

### Main Process (main.js)
- Handles file system operations
- Manages child processes for running projects
- Provides IPC communication with renderer
- Handles window management and lifecycle

### Renderer Process (renderer/)
- Modern UI with dark theme
- Real-time project status updates
- File tree visualization
- Console output display
- Interactive project management

### Project Detection Logic
```javascript
// Detects framework based on package.json dependencies
if (dependencies.react) {
  if (dependencies.next) return 'nextjs';
  if (dependencies['react-scripts']) return 'cra';
  return 'react';
}
```

### Process Management
- Uses `child_process.spawn()` for running projects
- `tree-kill` for proper process cleanup
- `portfinder` for automatic port assignment
- `chokidar` for file watching capabilities

## 📈 Performance Considerations

### Bundle Size Optimization
- Selective package inclusion
- Tree-shaking for unused code
- Compressed assets and resources
- Lazy loading of heavy components

### Memory Management
- Process cleanup on app exit
- File watcher disposal
- Limited directory recursion depth
- Efficient DOM updates

### Security Features
- No remote code execution
- Sandboxed renderer processes
- Local file system access only
- No network requests (offline)

## 🚀 Distribution Strategy

### Target Audience
- Frontend developers
- Students learning web development
- Teams needing portable dev environments
- Developers working offline/air-gapped systems

### Platform Support
- **Windows 10/11**: Full support with `.exe` and installer
- **macOS 10.15+**: Native app bundle with notarization
- **Linux**: AppImage for universal compatibility

### Download Size
- **Compressed**: ~150-200MB
- **Extracted**: ~400-500MB
- **Runtime**: Includes full Node.js ecosystem

## 🔒 Security & Licensing

### Security Considerations
- No network access required after download
- Local file system operations only
- No telemetry or data collection
- Open source codebase for transparency

### License
MIT License - Free for personal and commercial use

## 📞 Support & Maintenance

### User Support
- Comprehensive README with troubleshooting
- Built-in help tooltips and status indicators
- Error messages with actionable suggestions
- Community support through GitHub issues

### Updates
- Self-contained updates through new releases
- Backward compatibility with existing projects
- Progressive enhancement of features
- Long-term support for stable versions

---

## 🎉 Success Metrics

- **Zero Setup Time**: Users can start developing immediately
- **Offline Capability**: Works completely without internet
- **Universal Compatibility**: Supports all major frameworks
- **Intuitive Interface**: No learning curve for developers
- **Portable**: Move between machines effortlessly

This deployment guide ensures users can successfully download, install, and use the Dev Project Runner application on any supported platform with minimal technical knowledge required.