@echo off
title Dev Project Runner Enhanced - One-Click Setup
color 0A

:START
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║              DEV PROJECT RUNNER ENHANCED                    ║
echo ║                   One-Click Setup                           ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🚀 Enhanced version with automatic TSX support!
echo ✨ Drop TSX files anywhere and run instantly
echo 📦 Zero-configuration setup
echo.

:CHECK_NODE
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
echo Please install Node.js LTS and restart this script
echo.
start https://nodejs.org
pause
exit

:INSTALL_DEPS
echo.
echo ══════════════════════════════════════════════════════════════
echo 📦 Installing Dependencies
echo ══════════════════════════════════════════════════════════════
echo.

echo Installing optimized dependencies...
echo This may take 2-3 minutes...
echo.

:: Use the clean package.json
if exist package-clean.json (
    copy package-clean.json package.json >nul
    echo ✅ Using optimized package configuration
)

:: Install with clean cache
npm cache clean --force >nul 2>&1
npm install --no-optional --production=false

if %errorLevel% == 0 (
    echo ✅ Dependencies installed successfully!
    goto POST_INSTALL
) else (
    echo ❌ Installation failed, trying alternative approach...
    goto FALLBACK_INSTALL
)

:FALLBACK_INSTALL
echo.
echo 🔧 Trying lite installation (without problematic dependencies)...
echo.

:: Create lite version
(
echo {
echo   "name": "dev-project-runner-enhanced",
echo   "version": "2.0.0",
echo   "main": "main-enhanced.js",
echo   "scripts": {
echo     "start": "electron . --no-sandbox"
echo   },
echo   "dependencies": {
echo     "electron": "^28.0.0",
echo     "chokidar": "^3.5.3",
echo     "tree-kill": "^1.2.2",
echo     "portfinder": "^1.0.32",
echo     "extract-zip": "^2.0.1"
echo   }
echo }
) > package-lite.json

copy package-lite.json package.json >nul

npm install
if %errorLevel% == 0 (
    echo ✅ Lite installation successful!
    goto POST_INSTALL
) else (
    echo ❌ Installation failed completely
    goto MANUAL_HELP
)

:POST_INSTALL
echo.
echo ══════════════════════════════════════════════════════════════
echo 🔧 Post-Installation Setup
echo ══════════════════════════════════════════════════════════════
echo.

:: Run setup scripts
if exist scripts\setup.js (
    echo Running enhanced setup...
    node scripts\setup.js
)

:: Use enhanced files
if exist main-enhanced.js (
    echo ✅ Using enhanced main process
    copy main-enhanced.js main.js >nul
)

if exist renderer\app-enhanced.js (
    echo ✅ Using enhanced renderer
    copy renderer\app-enhanced.js renderer\app.js >nul
)

if exist renderer\styles-enhanced.css (
    echo ✅ Using enhanced styles
    copy renderer\styles-enhanced.css renderer\styles.css >nul
)

echo.
echo ✅ Setup completed successfully!
goto LAUNCH

:LAUNCH
echo.
echo ══════════════════════════════════════════════════════════════
echo 🚀 Launching Application
echo ══════════════════════════════════════════════════════════════
echo.

echo Starting Dev Project Runner Enhanced...
echo.
echo 🎯 New features in this version:
echo ├─ ⚛️  Automatic TSX detection and setup
echo ├─ 📦 Zero-config TypeScript projects
echo ├─ 🔧 Auto-dependency installation
echo ├─ 🎨 Enhanced UI with TSX indicators
echo └─ 🚀 One-click project creation
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
echo ✅ Dev Project Runner Enhanced is now running!
echo.
echo 🎯 What's new:
echo ├─ Drop any folder with .tsx files → Auto-detected as project
echo ├─ No package.json needed → Auto-generated with Vite + React + TS
echo ├─ One-click setup → Dependencies installed automatically  
echo ├─ Enhanced UI → TSX files highlighted with special indicators
echo └─ Create new TSX projects → Built-in project generator
echo.
echo 🚀 To run again: npm start
echo 📝 Files are ready for GitHub deployment
echo.
goto END

:TROUBLESHOOT
echo.
echo ══════════════════════════════════════════════════════════════
echo 🔧 Troubleshooting
echo ══════════════════════════════════════════════════════════════
echo.
echo If the app didn't start:
echo.
echo 1. ✅ Check that Node.js is installed: node --version
echo 2. 🔄 Try running: npm start
echo 3. 📋 Check for error messages above
echo 4. 🆘 If still issues, try: npm install --force
echo.
goto MANUAL_HELP

:MANUAL_HELP
echo.
echo ══════════════════════════════════════════════════════════════
echo 📋 Manual Setup Instructions
echo ══════════════════════════════════════════════════════════════
echo.
echo If automatic setup failed:
echo.
echo 1. INSTALL NODE.JS: https://nodejs.org (LTS version)
echo 2. OPEN TERMINAL: Right-click → "Open in Terminal" 
echo 3. RUN COMMANDS:
echo    npm install
echo    npm start
echo.
echo 🔧 For GitHub deployment:
echo    - All files are ready to commit
echo    - Dependencies will auto-install with: npm install
echo    - TSX support works out of the box
echo.

:END
echo.
echo Press any key to exit...
pause >nul
exit /b