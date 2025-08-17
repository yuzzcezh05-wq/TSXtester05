# Troubleshooting Guide - Dev Project Runner

## Quick Solutions

### ❌ Problem: MSB8040 Error (Spectre-mitigated libraries required)

**Error Message:**
```
error MSB8040: Spectre-mitigated libraries are required for this project. 
Install them from the Visual Studio installer
```

**Solution:**
1. **Automatic Fix:** Run `WindowsEnvFix.bat` → Option 1 (Auto-fix)
2. **Manual Fix:**
   - Open Visual Studio Installer from Start Menu
   - Find Visual Studio 2022, click "Modify"
   - Go to "Individual components" tab
   - Search for "Spectre"
   - Check: **MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (Latest)**
   - Click "Modify" and wait for installation
3. **Alternative:** Use Lite installation (no terminal features)

---

### ❌ Problem: node-pty Build Failures

**Symptoms:**
- `npm install` fails during node-pty compilation
- Visual Studio build errors
- gyp ERR! build error

**Solutions:**
1. **Fix Build Environment:** Run `WindowsEnvFix.bat`
2. **Install Prerequisites:**
   - Visual Studio 2022 with C++ workload
   - Windows SDK (latest)
   - Python 3.8+ (added to PATH)
3. **Use Alternative:** Switch to Lite installation
4. **Manual Commands:**
   ```cmd
   npm config set msvs_version 2022
   npm cache clean --force
   npm install
   ```

---

### ❌ Problem: Installation Keeps Failing

**Try This Order:**
1. Run as Administrator
2. Use Enhanced Installer: `DevProjectRunner-Installer-Enhanced.bat`
3. Choose "Smart Install" option
4. If recommended, use "Lite Install"
5. Check environment with WindowsEnvFix.bat

---

### ❌ Problem: No Internet Connection Error

**Solutions:**
- Check your internet connection
- Configure proxy settings if behind corporate firewall:
  ```cmd
  npm config set proxy http://proxy-server:port
  npm config set https-proxy http://proxy-server:port
  ```
- Try mobile hotspot as temporary solution

---

## Detailed Troubleshooting

### Build Environment Issues

#### Visual Studio 2022 Not Found
**Problem:** Installer can't find Visual Studio
**Solution:** 
1. Install Visual Studio 2022 Community (free)
2. During installation, select "Desktop development with C++" workload
3. Or use Build Tools only: Download from Microsoft

#### Python Issues
**Problem:** Python not found for node-gyp
**Solution:**
1. Install Python 3.8+ from python.org
2. During installation, check "Add Python to PATH"
3. Verify: `python --version` should work in Command Prompt

#### Windows SDK Missing
**Problem:** Windows SDK required for compilation
**Solution:**
1. In Visual Studio Installer, add "Windows 10/11 SDK (latest)"
2. Or download standalone from Microsoft

### npm and Node.js Issues

#### npm Cache Corruption
**Symptoms:** Random installation failures
**Solution:**
```cmd
npm cache clean --force
npm cache verify
```

#### Permission Errors
**Symptoms:** EPERM errors during installation
**Solution:**
1. Run Command Prompt as Administrator
2. Or change npm global directory:
   ```cmd
   npm config set prefix %APPDATA%\npm
   ```

#### Version Conflicts
**Symptoms:** Package version errors
**Solution:**
```cmd
npm config set legacy-peer-deps true
npm install
```

### Installation Specific Issues

#### Disk Space Problems
**Problem:** Not enough space for installation
**Requirements:**
- Standard Install: ~500MB
- Lite Install: ~300MB
- Temp space: Additional 200MB during installation

**Solution:**
1. Free up disk space
2. Use Lite installation for smaller footprint
3. Install to different drive

#### Antivirus Interference
**Problem:** Antivirus blocking installation
**Solution:**
1. Temporarily disable real-time protection
2. Add installation directory to exclusions
3. Add npm cache directory to exclusions

### Runtime Issues

#### App Won't Start
**Problem:** "Failed to start application"
**Solutions:**
1. Check if launcher exists and is correct
2. Verify Node.js installation: `node --version`
3. Check for missing dependencies:
   ```cmd
   cd DevProjectRunner
   npm install
   ```
4. Run manually to see errors:
   ```cmd
   cd DevProjectRunner
   npm start
   ```

#### Electron Security Warnings
**Problem:** Electron security warnings in console
**Solution:** These are normal for development. App should still work.

#### Port Already in Use
**Problem:** "Port 3000 already in use"
**Solution:** The app automatically finds available ports. Close other development servers if needed.

## Installation Options Comparison

| Feature | Standard Install | Lite Install |
|---------|------------------|--------------|
| Project browsing | ✅ | ✅ |
| Running npm scripts | ✅ | ✅ |
| File watching | ✅ | ✅ |
| Port management | ✅ | ✅ |
| Integrated terminal | ✅ | ❌ |
| Build requirements | High | Low |
| Installation size | ~500MB | ~300MB |
| Reliability | Medium | High |

## Advanced Solutions

### Clean Reinstall
If all else fails:
1. Delete `DevProjectRunner` folder completely
2. Clear npm cache: `npm cache clean --force`
3. Restart computer
4. Run Enhanced Installer as Administrator
5. Choose Smart Install → Lite Install

### Manual Installation
For experts only:
1. Install Node.js manually
2. Create project directory
3. Copy package.json (lite version)
4. Run `npm install`
5. Copy application files
6. Create launcher script

### Corporate/Restricted Environments
If you're in a corporate environment:
1. Use Lite installation (fewer dependencies)
2. Configure npm proxy settings
3. Ask IT to whitelist npm registry
4. Consider portable Node.js installation

## Getting Help

### Information to Provide
When asking for help, include:
1. Windows version
2. Node.js version (`node --version`)
3. Visual Studio version (if installed)
4. Complete error message
5. Which installer you used
6. Installation option chosen

### Log Files
Check these files for detailed error information:
- `DevProjectRunner\install.log` - Installation log
- `%TEMP%\npm-debug.log` - npm debug log
- Console output from installer

### Tools for Diagnosis
1. **WindowsEnvFix.bat** - Comprehensive environment check
2. **Enhanced Installer** - Smart detection and fixing
3. **System Info option** - Quick environment overview

## Prevention

### Best Practices
1. Always run installers as Administrator
2. Keep Visual Studio updated
3. Don't install in OneDrive/cloud-synced folders
4. Ensure stable internet during installation
5. Close unnecessary programs during installation

### Maintenance
1. Update Node.js periodically
2. Clear npm cache monthly: `npm cache clean --force`
3. Keep Visual Studio build tools updated
4. Monitor disk space

---

*This guide covers the most common issues. For additional help, check the project documentation or create an issue report.*