# Dev Project Runner Enhanced 🚀

> **Zero-config development tool with automatic TSX/TypeScript support**

An enhanced Electron desktop application that automatically detects and runs development projects, with special focus on **seamless TSX support**. Just drop TSX files in any folder and run them instantly - no configuration needed!

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

## 🎬 Quick Start

### 1. **Clone & Setup** (30 seconds)
```bash
git clone <your-repo-url>
cd dev-project-runner-enhanced
SETUP.bat          # Windows - One-click setup
# or
npm install && npm start    # Manual setup
```

### 2. **Use TSX Support** (Instant)
```bash
# Create a folder with TSX files
mkdir my-tsx-project
cd my-tsx-project

# Drop any .tsx file (App.tsx, index.tsx, etc.)
# Open Dev Project Runner → Browse to folder
# Project auto-detected → Click "Setup & Run"
# Dependencies auto-installed → App launches!
```

## 📁 Project Structure

```
dev-project-runner-enhanced/
├── main-enhanced.js           # Enhanced Electron main process
├── renderer/
│   ├── app-enhanced.js        # Enhanced UI with TSX support
│   ├── styles-enhanced.css    # Enhanced styling
│   └── index.html             # Main UI
├── scripts/
│   └── setup.js              # Auto-setup & template creation
├── templates/                 # Built-in project templates
│   └── react-tsx/            # React + TSX template
├── SETUP.bat                 # One-click Windows installer
├── package-clean.json        # Optimized dependencies
└── README-ENHANCED.md        # This file
```

## 🎯 TSX Project Detection

The app automatically recognizes TSX projects through:

### **File Detection**
- `.tsx` files in any directory
- `.ts` files with JSX syntax
- TypeScript config files (`tsconfig.json`)

### **Auto-Configuration**
When TSX files are found without `package.json`:
```json
{
  "name": "auto-tsx-project",
  "scripts": {
    "dev": "vite",
    "start": "vite", 
    "build": "vite build"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  },
  "devDependencies": {
    "@types/react": "^18.2.0",
    "@vitejs/plugin-react": "^4.0.0",
    "typescript": "^5.0.0",
    "vite": "^4.4.0"
  }
}
```

### **Smart Build Tool Selection**
- **Vite**: Default for new TSX projects (fastest)
- **Create React App**: If `react-scripts` detected
- **Next.js**: If `next` dependency found
- **Custom**: Respects existing build configuration

## 🛠️ Installation Options

### **Option 1: One-Click Setup** (Recommended)
```bash
# Download/clone repository
# Run the setup script
SETUP.bat           # Windows
# or 
./setup.sh          # Mac/Linux (coming soon)
```

### **Option 2: Manual Setup**
```bash
npm install         # Install dependencies
npm start          # Launch application
```

### **Option 3: Clean Install**
```bash
npm run clean-install    # Production-only dependencies
npm start               # Launch with minimal footprint
```

## 🎨 Enhanced UI Features

### **TSX Visual Indicators**
- **TSX Badge**: Files with `.tsx` extension show special indicators
- **Project Highlighting**: TSX projects have distinctive styling
- **Auto-Gen Badge**: Auto-configured projects show "AUTO-CONFIGURED" label
- **Progress Tracking**: Real-time setup progress with detailed logging

### **Smart Project Cards**
```
┌─────────────────────────────────────┐
│ 🚀 my-tsx-project [AUTO-CONFIGURED] │
│ ⚛️ Vite + React + TypeScript         │  
│ 📝 3 TSX files                      │
│ [Setup & Run] [Stop] [Setup]        │
└─────────────────────────────────────┘
```

### **Enhanced Console**
- **Color-coded output**: Success (green), errors (red), info (blue)
- **TSX-specific messages**: Setup progress, compilation status
- **Real-time updates**: Hot reload notifications, port assignments

## 🔧 Advanced Features

### **Template System**
Built-in templates for instant project creation:
- `react-tsx`: React + TypeScript + Vite
- `nextjs-ts`: Next.js + TypeScript  
- `vue-ts`: Vue 3 + TypeScript
- Custom templates can be added in `/templates`

### **Auto-Dependency Management**
- **Smart Detection**: Analyzes existing dependencies
- **Minimal Install**: Only installs what's needed
- **Version Optimization**: Uses latest stable versions
- **Fallback System**: Lite mode if build tools unavailable

### **Multi-Project Workflow**
- **Simultaneous Running**: Multiple projects on different ports
- **Port Management**: Automatic port assignment (3000, 3001, etc.)
- **Resource Monitoring**: Track running processes and memory usage
- **Bulk Operations**: Start/stop all projects at once

## 📦 GitHub Deployment Ready

This version is optimized for GitHub deployment:

### **Clean Repository Structure**
- ✅ Proper `.gitignore` (excludes `node_modules`, builds)
- ✅ Production `package.json` with minimal dependencies
- ✅ Setup scripts for easy contributor onboarding
- ✅ Comprehensive documentation

### **Contributor Friendly**
```bash
# New contributor workflow:
git clone <repo>
cd dev-project-runner-enhanced
npm install     # Install dependencies
npm start      # Launch application

# Ready to develop in 30 seconds!
```

### **CI/CD Ready**
- **Automated Testing**: Test scripts included
- **Build Optimization**: Electron-builder configuration
- **Cross-Platform**: Windows, macOS, Linux support

## 🔍 Troubleshooting

### **TSX Files Not Detected?**
- Ensure files have `.tsx` extension
- Check folder permissions
- Try refreshing folder view
- Look for console error messages

### **Auto-Setup Fails?**
- Check internet connection (downloads dependencies)
- Verify Node.js version (16+ required)
- Try manual installation: `npm install`
- Check available disk space

### **Build Errors?**
- Run `SETUP.bat` for automatic environment fixing
- Try lite installation mode (excludes problematic dependencies)
- Verify Visual Studio build tools (Windows)

## 🤝 Contributing

### **Development Setup**
```bash
git clone <repo>
cd dev-project-runner-enhanced
npm install
npm run dev        # Development mode with hot reload
```

### **Adding TSX Support for New Frameworks**
1. Edit `main-enhanced.js` → `detectTsxProject()` method
2. Add framework detection logic
3. Update UI in `renderer/app-enhanced.js`
4. Add template in `/templates` folder

### **Creating New Templates**
```bash
# Add template in /templates/your-template/
templates/
└── your-template/
    ├── package.json
    ├── tsconfig.json
    ├── vite.config.ts
    └── src/
        ├── App.tsx
        └── main.tsx
```

## 📊 Performance

### **Optimized Dependencies**
- **Electron**: 28.0.0 (latest stable)
- **No Native Modules**: Removed `node-pty` for reliability  
- **Minimal Bundle**: Only essential dependencies included
- **Fast Startup**: ~2-3 second launch time

### **Resource Usage**
- **Memory**: ~150-200MB typical usage
- **CPU**: Low usage when idle, moderate during builds
- **Disk**: ~500MB installed size

## 🔐 Security

- **Local Only**: No external API calls (except npm registry)
- **Sandboxed**: Electron security best practices
- **File Permissions**: Only accesses selected folders
- **No Telemetry**: Completely offline after setup

## 📄 License

MIT License - Feel free to use, modify, and distribute.

---

## 🎉 What Makes This Special?

1. **Zero Configuration**: Drop TSX files anywhere → instant project
2. **Auto-Detection**: Smart framework and build tool recognition  
3. **One-Click Setup**: Dependencies installed automatically
4. **Visual Excellence**: Enhanced UI with TSX-specific indicators
5. **GitHub Ready**: Clean structure, proper documentation, contributor-friendly

**Perfect for**: React developers, TypeScript enthusiasts, rapid prototyping, learning projects, and team collaboration.

---

*Built with ❤️ for the developer community. Contributions welcome!*