# How to Run Dev Project Runner

## 🚨 **IMPORTANT: You're seeing the launcher, not the main app!**

The screenshot shows the **launcher screen** (`DevProjectRunner.html`), but the actual application with the File Browser functionality is the **Electron app**.

## ✅ **Correct Way to Launch:**

### Option 1: Using npm (Recommended)
```bash
# Make sure you have Node.js installed
npm install
npm start
```

### Option 2: Using the Batch File
```bash
# Double-click this file:
LaunchDevProjectRunner.bat
```

### Option 3: If Not Installed Yet
```bash
# Run the enhanced installer first:
DevProjectRunner-Installer-Enhanced.bat
```

## 🔍 **What Each File Does:**

| File | Purpose |
|------|---------|
| `DevProjectRunner.html` | 🌐 **Launcher/Splash Screen** (what you're seeing) |
| `renderer/index.html` | 📱 **Main Application** (has File Browser) |
| `main.js` | ⚡ **Electron Main Process** |
| `LaunchDevProjectRunner.bat` | 🚀 **Proper Launcher Script** |

## 🛠️ **Troubleshooting:**

### If npm start fails:
1. **Check Node.js:** `node --version`
2. **Install dependencies:** `npm install`
3. **Fix environment:** Run `WindowsEnvFix.bat`

### If you see "File Browser" button not working:
- You're viewing the wrong file (launcher instead of main app)
- Use `npm start` or `LaunchDevProjectRunner.bat` instead

## 🎯 **Expected Result:**

When launched correctly, you should see:
- **Left Panel:** File Explorer
- **Center Panel:** Project Dashboard  
- **Right Panel:** Quick Actions (with working "Open Explorer" button)
- **Bottom Panel:** Console Output

The "Open Explorer" functionality works perfectly in the main Electron app!