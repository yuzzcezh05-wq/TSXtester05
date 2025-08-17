# 📦 Dev Project Runner - ZIP Installation Guide

## 🎯 **From GitHub ZIP to Working App - Complete Guide**

### 📋 **Prerequisites**
- Windows 10/11 (64-bit)
- Internet connection
- Administrator privileges (recommended)

---

## 🔽 **STEP 1: Download & Extract**

### 1.1 Download ZIP
```
1. Go to GitHub repository
2. Click "Code" button (green)
3. Select "Download ZIP"
4. Save to your desired location (e.g., C:\DevTools\)
```

### 1.2 Extract ZIP
```
1. Right-click the downloaded ZIP file
2. Select "Extract All..."
3. Choose destination folder (e.g., C:\DevTools\dev-project-runner\)
4. Click "Extract"
```

**Result:** You should have a folder with these files:
```
dev-project-runner/
├── main.js
├── package.json
├── renderer/
├── assets/
├── DevProjectRunner.html
├── QUICK_FIX.bat
├── WindowsEnvFix.bat
└── [other files...]
```

---

## ⚡ **STEP 2: Quick Setup (Recommended)**

### 2.1 Easy Installation
```
1. Open the extracted folder
2. Double-click: QUICK_FIX.bat
3. Wait for installation to complete
4. App should launch automatically
```

**If QUICK_FIX.bat works:** ✅ **You're done! Skip to Step 5.**

**If it fails:** Continue to Step 3 for manual setup.

---

## 🛠️ **STEP 3: Manual Setup (If Quick Fix Failed)**

### 3.1 Install Node.js (if not installed)
```
1. Go to: https://nodejs.org
2. Download "LTS" version (recommended)
3. Run installer with default settings
4. Restart computer after installation
```

### 3.2 Check Installation
```
1. Press Win + R
2. Type: cmd
3. Press Enter
4. Type: node --version
5. Should show version like: v18.x.x or v20.x.x
```

### 3.3 Install Dependencies
```
1. Open Command Prompt as Administrator
2. Navigate to extracted folder:
   cd C:\DevTools\dev-project-runner
3. Install dependencies:
   npm install
```

**Expected output:**
```
added 200+ packages in 30s
✅ Dependencies installed successfully
```

---

## 🚨 **STEP 4: Handle Build Issues (If npm install fails)**

### 4.1 Windows Build Environment Fix
If you see errors like:
- "MSB8040: Spectre-mitigated libraries are required"
- "node-gyp rebuild failed"
- "Visual Studio not found"

**Solution:**
```
1. In your project folder, double-click: WindowsEnvFix.bat
2. Choose Option 1: "Auto-fix"
3. Follow the guided instructions
4. When fixed, retry: npm install
```

### 4.2 Alternative: Use Lite Installation
If build issues persist:
```
1. Double-click: DevProjectRunner-Installer-Enhanced.bat
2. Choose Option 3: "Lite Install"
3. This skips problematic dependencies
```

---

## 🚀 **STEP 5: Launch Application**

### 5.1 Start the App
Choose one method:

**Method A - NPM Command:**
```
1. Open Command Prompt in project folder
2. Run: npm start
```

**Method B - Batch File:**
```
1. Double-click: LaunchDevProjectRunner.bat
```

**Method C - Quick Fix:**
```
1. Double-click: QUICK_FIX.bat
```

### 5.2 Verify Success
You should see the **Electron application window** with:
- ✅ Left Panel: File Explorer
- ✅ Center Panel: Project Dashboard
- ✅ Right Panel: Quick Actions (with working "Open Explorer" button)
- ✅ Bottom Panel: Console Output

**NOT the purple launcher screen!**

---

## 🔧 **STEP 6: Test File Browser**

### 6.1 Test the Functionality
```
1. In the main app window, click "Browse Folder" 
2. Select a folder with projects
3. Click "Open Explorer" in the right panel
4. Should open Windows File Explorer ✅
```

---

## 🚨 **Troubleshooting Common Issues**

### Issue 1: "npm not found"
**Solution:**
```
1. Install Node.js from nodejs.org
2. Restart computer
3. Retry npm install
```

### Issue 2: "Permission denied" errors
**Solution:**
```
1. Run Command Prompt as Administrator
2. Retry installation commands
```

### Issue 3: Build/compilation errors
**Solution:**
```
1. Run: WindowsEnvFix.bat
2. Or use Lite installation (no terminal features)
```

### Issue 4: See purple launcher instead of main app
**Solution:**
```
❌ Don't open: DevProjectRunner.html in browser
✅ Use: npm start or LaunchDevProjectRunner.bat
```

### Issue 5: "electron not found"
**Solution:**
```
1. Delete node_modules folder
2. Run: npm install
3. Run: npm start
```

---

## 📁 **File Reference**

| File | Purpose | When to Use |
|------|---------|-------------|
| `QUICK_FIX.bat` | 🚀 **One-click setup** | First try this |
| `LaunchDevProjectRunner.bat` | 🎯 **Start app** | After setup |
| `WindowsEnvFix.bat` | 🔧 **Fix build issues** | If npm install fails |
| `DevProjectRunner-Installer-Enhanced.bat` | 📦 **Advanced installer** | For complex setups |
| `npm start` | ⚡ **Direct launch** | Command line method |

---

## ✅ **Success Checklist**

- [ ] ZIP downloaded and extracted
- [ ] Node.js installed (check: `node --version`)
- [ ] Dependencies installed (check: `node_modules` folder exists)
- [ ] App launches with `npm start` or batch file
- [ ] See main Electron window (not purple launcher)
- [ ] File Browser button works in right panel
- [ ] Can browse and open folders

---

## 🆘 **Still Having Issues?**

1. **Check logs:** Look for error messages in Command Prompt
2. **Try Lite version:** Use WindowsEnvFix.bat → Alternative Installation
3. **Verify environment:** Run WindowsEnvFix.bat → Verify Environment
4. **Clean install:** Delete folder, re-extract ZIP, start over

---

## 🎯 **Expected Final Result**

When successful, you'll have:
- ✅ Working Electron desktop application
- ✅ File browser that opens Windows Explorer
- ✅ Project detection and management
- ✅ Real-time console output
- ✅ All features from the purple launcher screen actually working!

**Time required:** 5-15 minutes (depending on internet speed and build environment)