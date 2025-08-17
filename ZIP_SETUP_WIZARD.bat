@echo off
title Dev Project Runner - ZIP Installation Wizard
color 0A

:START
cls
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                 DEV PROJECT RUNNER SETUP                    ║
echo ║                   ZIP Installation Wizard                   ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.
echo 🎯 This wizard will set up Dev Project Runner from ZIP download
echo.
echo Current Status:
echo ├─ 📁 Folder: %CD%
echo ├─ 🖥️  System: Windows %OS%
echo └─ 👤 User: %USERNAME%
echo.

:CHECK_PREREQUISITES
echo ══════════════════════════════════════════════════════════════
echo 🔍 STEP 1: Checking Prerequisites
echo ══════════════════════════════════════════════════════════════
echo.

echo [1/3] Checking Node.js installation...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Node.js found: 
    node --version
    set "NODE_OK=1"
) else (
    echo ❌ Node.js not found
    set "NODE_OK=0"
)

echo.
echo [2/3] Checking npm availability...
npm --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ npm found: 
    npm --version
    set "NPM_OK=1"
) else (
    echo ❌ npm not found
    set "NPM_OK=0"
)

echo.
echo [3/3] Checking project files...
if exist "main.js" (
    if exist "package.json" (
        echo ✅ Project files found
        set "FILES_OK=1"
    ) else (
        echo ❌ package.json missing
        set "FILES_OK=0"
    )
) else (
    echo ❌ main.js missing
    set "FILES_OK=0"
)

echo.
if "%NODE_OK%"=="1" if "%NPM_OK%"=="1" if "%FILES_OK%"=="1" (
    echo 🎉 Prerequisites check passed!
    goto INSTALL_DEPENDENCIES
) else (
    echo ⚠️  Prerequisites check failed!
    goto HANDLE_PREREQUISITES
)

:HANDLE_PREREQUISITES
echo.
echo ══════════════════════════════════════════════════════════════
echo 🛠️  FIXING PREREQUISITES
echo ══════════════════════════════════════════════════════════════
echo.

if "%NODE_OK%"=="0" (
    echo ❌ Node.js is required but not installed
    echo.
    echo 📥 To install Node.js:
    echo 1. Go to: https://nodejs.org
    echo 2. Download LTS version
    echo 3. Run installer with default settings
    echo 4. Restart computer
    echo 5. Run this script again
    echo.
    set /p continue="Press any key to open Node.js website..."
    start https://nodejs.org
    goto END
)

if "%FILES_OK%"=="0" (
    echo ❌ Project files missing or corrupted
    echo.
    echo 📁 Make sure you:
    echo 1. Downloaded the complete ZIP file
    echo 2. Extracted all files properly
    echo 3. Are running this script from the project folder
    echo.
    echo Current folder contents:
    dir /b
    echo.
    goto END
)

:INSTALL_DEPENDENCIES
echo.
echo ══════════════════════════════════════════════════════════════
echo 📦 STEP 2: Installing Dependencies
echo ══════════════════════════════════════════════════════════════
echo.

if exist "node_modules" (
    echo 🔍 node_modules folder exists, checking if complete...
    if exist "node_modules\electron" (
        echo ✅ Dependencies appear to be installed
        goto LAUNCH_APP
    ) else (
        echo ⚠️  Dependencies incomplete, reinstalling...
    )
) else (
    echo 📦 Installing dependencies for the first time...
)

echo.
echo ⏳ This may take 2-5 minutes depending on your internet speed...
echo 🔄 Installing npm packages...
echo.

call npm install
if %errorLevel% == 0 (
    echo.
    echo ✅ Dependencies installed successfully!
    goto LAUNCH_APP
) else (
    echo.
    echo ❌ Dependencies installation failed!
    goto HANDLE_BUILD_ERRORS
)

:HANDLE_BUILD_ERRORS
echo.
echo ══════════════════════════════════════════════════════════════
echo 🚨 BUILD ERROR DETECTED
echo ══════════════════════════════════════════════════════════════
echo.
echo This usually happens due to Windows build environment issues.
echo.
echo Available solutions:
echo [1] Try Lite Installation (recommended - no terminal features)
echo [2] Fix Windows Build Environment (advanced)
echo [3] Skip and try to run anyway
echo [4] Exit and install manually
echo.
set /p build_choice="Choose option (1-4): "

if "%build_choice%"=="1" goto LITE_INSTALL
if "%build_choice%"=="2" goto BUILD_ENV_FIX
if "%build_choice%"=="3" goto LAUNCH_APP
if "%build_choice%"=="4" goto MANUAL_INSTRUCTIONS
goto HANDLE_BUILD_ERRORS

:LITE_INSTALL
echo.
echo 🔧 Setting up Lite Installation (without node-pty)...
echo.
echo Creating lite package.json...
(
echo {
echo   "name": "dev-project-runner-lite",
echo   "version": "1.0.0",
echo   "main": "main.js",
echo   "scripts": {
echo     "start": "electron . --no-sandbox"
echo   },
echo   "dependencies": {
echo     "electron": "^28.0.0",
echo     "chokidar": "^3.5.3",
echo     "tree-kill": "^1.2.2",
echo     "portfinder": "^1.0.32",
echo     "extract-zip": "^2.0.1",
echo     "ws": "^8.14.2"
echo   }
echo }
) > package-lite.json

echo Backing up original package.json...
copy package.json package-original.json >nul
copy package-lite.json package.json >nul

echo Installing lite dependencies...
call npm install
if %errorLevel% == 0 (
    echo ✅ Lite installation successful!
    echo ℹ️  Note: Terminal features are disabled in this version
    goto LAUNCH_APP
) else (
    echo ❌ Even lite installation failed
    copy package-original.json package.json >nul
    goto MANUAL_INSTRUCTIONS
)

:BUILD_ENV_FIX
echo.
echo 🔧 Launching Windows Environment Fix tool...
echo.
if exist "WindowsEnvFix.bat" (
    call "WindowsEnvFix.bat"
    echo.
    echo Press any key to retry installation after fixing environment...
    pause >nul
    goto INSTALL_DEPENDENCIES
) else (
    echo ❌ WindowsEnvFix.bat not found
    echo Please run the complete installer package
    goto MANUAL_INSTRUCTIONS
)

:LAUNCH_APP
echo.
echo ══════════════════════════════════════════════════════════════
echo 🚀 STEP 3: Launching Application
echo ══════════════════════════════════════════════════════════════
echo.

echo 🎯 Starting Dev Project Runner...
echo.
echo ⚡ This will open the main Electron application window
echo 📱 You should see: File Explorer, Project Dashboard, Quick Actions
echo ❌ NOT the purple launcher screen!
echo.

echo Starting application...
call npm start

if %errorLevel% neq 0 (
    echo.
    echo ❌ Application failed to start
    echo 🔧 Troubleshooting suggestions:
    echo 1. Try running again
    echo 2. Check error messages above
    echo 3. Use WindowsEnvFix.bat if build-related errors
    echo.
    goto MANUAL_INSTRUCTIONS
) else (
    echo.
    echo ✅ Application launched successfully!
    echo 🎉 Setup complete!
)

goto SUCCESS

:SUCCESS
echo.
echo ══════════════════════════════════════════════════════════════
echo 🎉 INSTALLATION SUCCESSFUL!
echo ══════════════════════════════════════════════════════════════
echo.
echo ✅ Dev Project Runner is now ready to use!
echo.
echo 🎯 What you should see:
echo ├─ Electron application window (not browser)
echo ├─ Left Panel: File Explorer with Browse button
echo ├─ Center Panel: Project Dashboard
echo ├─ Right Panel: Quick Actions with "Open Explorer" button
echo └─ Bottom Panel: Console Output
echo.
echo 🚀 To run again: npm start or LaunchDevProjectRunner.bat
echo.
echo 📝 Features available:
echo ├─ ✅ Browse and detect projects (React, Vue, etc.)
echo ├─ ✅ One-click project running
echo ├─ ✅ File Explorer integration
echo ├─ ✅ Package management
echo └─ ✅ Real-time console output
echo.
goto END

:MANUAL_INSTRUCTIONS
echo.
echo ══════════════════════════════════════════════════════════════
echo 📋 MANUAL SETUP INSTRUCTIONS
echo ══════════════════════════════════════════════════════════════
echo.
echo If automated setup failed, follow these manual steps:
echo.
echo 1. INSTALL NODE.JS:
echo    https://nodejs.org (download LTS version)
echo.
echo 2. OPEN COMMAND PROMPT AS ADMINISTRATOR:
echo    Right-click Start → "Command Prompt (Admin)"
echo.
echo 3. NAVIGATE TO PROJECT FOLDER:
echo    cd "%CD%"
echo.
echo 4. INSTALL DEPENDENCIES:
echo    npm install
echo.
echo 5. START APPLICATION:
echo    npm start
echo.
echo 🔧 For build issues:
echo    - Run WindowsEnvFix.bat
echo    - Or use DevProjectRunner-Installer-Enhanced.bat
echo.
goto END

:END
echo.
echo Press any key to exit...
pause >nul
exit /b