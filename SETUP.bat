@echo off
title Dev Project Runner Enhanced - Setup & Launch
color 0A

cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              DEV PROJECT RUNNER ENHANCED v2.0               ║
echo ║                   One-Click Setup & Launch                  ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🚀 Enhanced with automatic TSX/TypeScript support!
echo ✨ Zero-config setup for React + TypeScript projects
echo 📦 One-click installation and launch
echo.

:CHECK_PREREQUISITES
echo ══════════════════════════════════════════════════════════════
echo 🔍 Checking Prerequisites
echo ══════════════════════════════════════════════════════════════
echo.

echo [1/2] Checking Node.js...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Node.js found: 
    node --version
    echo ✅ npm found:
    npm --version
    goto INSTALL_DEPS
) else (
    echo ❌ Node.js not found
    goto INSTALL_NODE
)

:INSTALL_NODE
echo.
echo 📥 Node.js is required but not installed
echo.
echo Opening Node.js download page...
echo Please install Node.js LTS (16.x or higher) and restart this script
echo.
start https://nodejs.org
echo Press any key after installing Node.js...
pause >nul
goto CHECK_PREREQUISITES

:INSTALL_DEPS
echo.
echo ══════════════════════════════════════════════════════════════
echo 📦 Installing Dependencies
echo ══════════════════════════════════════════════════════════════
echo.

echo Installing enhanced dependencies...
echo This may take 2-3 minutes on first run...
echo.

npm install --no-optional

if %errorLevel% == 0 (
    echo ✅ Dependencies installed successfully!
    goto LAUNCH_APP
) else (
    echo ❌ Installation failed, trying alternative approach...
    goto FALLBACK_INSTALL
)

:FALLBACK_INSTALL
echo.
echo 🔧 Trying lite installation (without problematic dependencies)...
echo.

echo Installing with legacy settings...
npm install --legacy-peer-deps --no-optional

if %errorLevel% == 0 (
    echo ✅ Lite installation successful!
    goto LAUNCH_APP
) else (
    echo ❌ Installation failed completely
    goto MANUAL_HELP
)

:LAUNCH_APP
echo.
echo ══════════════════════════════════════════════════════════════
echo 🚀 Launching Application
echo ══════════════════════════════════════════════════════════════
echo.

echo Starting Dev Project Runner Enhanced...
echo.
echo 🎯 New features in v2.0:
echo ├─ ⚛️  Automatic TSX detection and setup
echo ├─ 📦 Zero-config TypeScript projects  
echo ├─ 🔧 Auto-dependency installation
echo ├─ 🎨 Enhanced UI with TSX indicators
echo ├─ 🚀 One-click project creation
echo └─ 📱 Clean project structure
echo.

npm start

if %errorLevel% neq 0 (
    echo ❌ Failed to start application
    goto TROUBLESHOOT
)

goto SUCCESS

:SUCCESS
echo.
echo ══════════════════════════════════════════════════════════════
echo 🎉 SUCCESS!
echo ══════════════════════════════════════════════════════════════
echo.
echo ✅ Dev Project Runner Enhanced is ready!
echo.
echo 🎯 What's new in v2.0:
echo ├─ Drop .tsx files in any folder → Auto-detected as React project
echo ├─ No package.json needed → Auto-generated with Vite + React + TS
echo ├─ One-click "Setup & Run" → Dependencies installed automatically  
echo ├─ Enhanced UI → TSX files highlighted with special indicators
echo ├─ Create new projects → Built-in TSX project generator
echo └─ GitHub ready → Clean structure for easy sharing
echo.
echo 🚀 To run again: npm start
echo 📝 Ready for development and GitHub deployment!
echo.
goto END

:TROUBLESHOOT
echo.
echo ══════════════════════════════════════════════════════════════
echo 🔧 Troubleshooting
echo ══════════════════════════════════════════════════════════════
echo.
echo If the app didn't start, try these solutions:
echo.
echo 1. ✅ Verify Node.js version: node --version (should be 16+)
echo 2. 🔄 Try running manually: npm start
echo 3. 📋 Check for error messages above
echo 4. 🆘 Clear cache and retry: npm cache clean --force
echo 5. 🔧 Reinstall: npm install --force
echo.
goto MANUAL_HELP

:MANUAL_HELP
echo.
echo ══════════════════════════════════════════════════════════════
echo 📋 Manual Setup Instructions
echo ══════════════════════════════════════════════════════════════
echo.
echo If automatic setup failed, follow these steps:
echo.
echo 1. VERIFY NODE.JS: https://nodejs.org (Download LTS version 16+)
echo 2. OPEN TERMINAL: Right-click in this folder → "Open in Terminal"
echo 3. RUN COMMANDS:
echo    npm cache clean --force
echo    npm install
echo    npm start
echo.
echo 🔧 For GitHub users:
echo    - All files are ready to commit and push
echo    - Other users can run: npm install ^&^& npm start
echo    - TSX support works out of the box
echo.
echo 💡 Still having issues?
echo    - Ensure you have sufficient disk space (500MB+)
echo    - Check your internet connection
echo    - Try running as Administrator
echo.

:END
echo.
echo Press any key to exit...
pause >nul
exit /b