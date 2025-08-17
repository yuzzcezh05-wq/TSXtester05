# 🚀 Complete Setup Guide - From GitHub to Running App

## ⚡ **Quick Start (30 Seconds)**

### **Windows:**
```bash
# 1. Download ZIP from GitHub
# 2. Extract to any folder
# 3. Run setup
SETUP.bat
```

### **macOS/Linux:**
```bash
# 1. Download ZIP from GitHub  
# 2. Extract to any folder
# 3. Open terminal in the folder
npm install
npm start
```

---

## 📥 **Detailed Setup Instructions**

### **Step 1: Download from GitHub**

#### **Option A: Download ZIP (Recommended)**
1. Go to the GitHub repository
2. Click the green **"Code"** button
3. Select **"Download ZIP"**
4. Extract to your desired location (e.g., `C:\DevTools\dev-project-runner\`)

#### **Option B: Git Clone**
```bash
git clone https://github.com/yourusername/dev-project-runner-enhanced.git
cd dev-project-runner-enhanced
```

### **Step 2: Install Prerequisites**

#### **Node.js (Required)**
- Download from: https://nodejs.org
- Install **LTS version** (16.x or higher)
- Verify installation: `node --version`

### **Step 3: Run Setup**

#### **Windows (Automated):**
```bash
# Double-click or run in CMD:
SETUP.bat
```

#### **macOS/Linux (Manual):**
```bash
# Open terminal in the extracted folder
npm install
npm start
```

#### **Alternative (All Platforms):**
```bash
# Manual setup for any platform
npm cache clean --force    # Clear any cache issues
npm install                 # Install dependencies  
npm start                   # Launch the application
```

---

## 🎯 **What You'll See When Working**

### **✅ Correct - Electron Desktop App:**
- **Left Panel**: File explorer with project browser
- **Center Panel**: Project dashboard with detected projects
- **Right Panel**: Quick actions and running projects panel
- **Bottom Panel**: Console output with colored logs
- **TSX Support**: Blue badges for .tsx files, auto-setup buttons

### **❌ Incorrect - Not This:**
- Browser window with purple launcher screen
- Command-line interface only
- Error messages about missing files

---

## 🔧 **Troubleshooting**

### **Common Issues & Quick Fixes:**

| **Problem** | **Solution** |
|-------------|--------------|
| **"Node.js not found"** | Install Node.js from nodejs.org (LTS version) |
| **"npm install fails"** | Run `npm cache clean --force` then `npm install` |
| **"App doesn't start"** | Check Node.js version: `node --version` (need 16+) |
| **"No projects detected"** | Browse to a folder with .tsx files or package.json |
| **"Permission denied"** | Run as Administrator (Windows) or with sudo (macOS/Linux) |
| **"Network error during install"** | Check internet connection, try `npm install --offline` |

### **Advanced Troubleshooting:**

#### **Clear All Cache & Reinstall:**
```bash
# Windows
rmdir /s node_modules
npm cache clean --force
npm install

# macOS/Linux  
rm -rf node_modules
npm cache clean --force
npm install
```

#### **Debug Mode:**
```bash
# Run with debug information
npm start --verbose

# Check installation
npm ls --depth=0
```

#### **Network Issues:**
```bash
# Corporate firewall/proxy
npm config set proxy http://proxy-server:port
npm config set https-proxy http://proxy-server:port

# Use different registry
npm config set registry https://registry.npmjs.org/
```

---

## 🎬 **First Time Usage Demo**

### **1. Launch App (after setup):**
```bash
npm start
# Electron window opens with enhanced UI
```

### **2. Test TSX Support:**
```bash
# Create test folder anywhere
mkdir test-tsx-project
cd test-tsx-project

# Create a simple TSX file
echo "import React from 'react'; export default () => <h1>Hello TSX!</h1>;" > App.tsx

# In Dev Project Runner:
# 1. Click "Browse Folder" 
# 2. Select test-tsx-project folder
# 3. Project auto-detected with "AUTO-CONFIGURED" badge
# 4. Click "Setup & Run"  
# 5. Dependencies install automatically
# 6. Project launches on localhost:3000
```

### **3. Regular Projects:**
```bash
# Works with any existing project
# 1. Browse to any folder with package.json
# 2. Project type auto-detected (React, Vue, Angular, etc.)
# 3. Click "Run" to start development server
# 4. Multiple projects can run simultaneously
```

---

## 📁 **Project Structure After Setup**

```
dev-project-runner-enhanced/
├── main.js                    # ✅ Enhanced Electron main process
├── package.json               # ✅ Clean dependencies (v2.0.0)
├── SETUP.bat                  # ✅ One-click installer (Windows)
├── README.md                  # ✅ Comprehensive documentation
├── SETUP_GUIDE.md            # ✅ This setup guide
├── renderer/
│   ├── index.html             # ✅ Main UI
│   ├── app.js                 # ✅ Enhanced frontend with TSX support
│   └── styles.css             # ✅ Modern responsive styling
├── templates/                 # ✅ Project templates
│   └── react-basic/           # ✅ React starter
├── scripts/
│   └── setup.js              # ✅ Setup automation
├── assets/
│   └── icon.png              # ✅ App icon
├── test_result.md            # ✅ Testing data (keep for reference)
└── node_modules/             # ✅ Installed dependencies
```

### **Files Removed in Cleanup:**
- ❌ `main-enhanced.js` (merged into main.js)
- ❌ `app-enhanced.js` (merged into app.js)  
- ❌ `styles-enhanced.js` (merged into styles.css)
- ❌ Multiple redundant README files
- ❌ Duplicate setup/installer scripts
- ❌ Test files (backend_test.js, ipc_test.js)
- ❌ Backup files (package-clean.json)

---

## 🔄 **Update & Maintenance**

### **Update Application:**
```bash
# Pull latest from GitHub
git pull origin main

# Reinstall dependencies
npm install

# Launch updated version
npm start
```

### **Reset to Clean State:**
```bash
# Complete reset
rm -rf node_modules
npm cache clean --force
npm install
npm start
```

### **Backup Settings:**
- No manual backup needed
- All project settings stored locally
- Templates and assets included in repository

---

## 🌍 **Cross-Platform Notes**

### **Windows:**
- ✅ One-click `SETUP.bat` installer
- ✅ Works on Windows 10/11
- ✅ No additional tools required
- ⚠️ May need "Run as Administrator" for some installations

### **macOS:**
- ✅ Native support for macOS 10.14+
- ✅ No additional tools required  
- ✅ Works with both Intel and Apple Silicon
- ⚠️ May need `sudo` for global npm permissions

### **Linux:**
- ✅ Tested on Ubuntu 18.04+, Fedora, CentOS
- ✅ Works with most distributions
- ✅ No additional packages required
- ⚠️ Some distributions may need `build-essential`

---

## 🎉 **Success Indicators**

### **✅ Setup Completed Successfully When You See:**
1. **Electron window opens** (not browser)
2. **Three-panel interface** (file browser, projects, actions)
3. **Status indicator shows "Ready"** in header
4. **Browse Folder button works** and opens file dialog
5. **Console shows welcome message** with TSX support info

### **🎯 TSX Support Working When:**
1. **Drop .tsx files in folder** → Project auto-detected  
2. **Blue ⚛️ icons appear** for .tsx files
3. **"AUTO-CONFIGURED" badge** shows for TSX projects
4. **"Setup & Run" button available** for auto-generated projects
5. **Dependencies install automatically** when clicked

---

## 📞 **Getting Help**

### **If Setup Fails:**
1. **Check Node.js**: `node --version` (should be 16+)
2. **Clear cache**: `npm cache clean --force`
3. **Try manual**: `npm install && npm start`
4. **Check permissions**: Run as admin/sudo if needed
5. **Check internet**: Required for first-time dependency download

### **If App Doesn't Work as Expected:**
1. **Restart setup**: Run `SETUP.bat` again
2. **Check console**: Look for error messages in terminal
3. **Try different folder**: Test with a simple project
4. **Update Node.js**: Download latest LTS from nodejs.org
5. **Fresh install**: Delete `node_modules`, run setup again

### **For Development Issues:**
- All functionality is tested and working per `test_result.md`
- TSX support is fully functional
- Enhanced UI with visual indicators  
- Auto-setup and dependency management working
- Multi-project support operational

---

**🚀 Total setup time: 2-5 minutes on most systems**  
**📱 Ready for development immediately after setup**  
**⚡ Enhanced with zero-config TSX support**

---

*This guide covers everything from GitHub download to running development projects. Keep this file for reference and share with team members for consistent setup across different machines.*