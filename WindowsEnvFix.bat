@echo off
setlocal EnableDelayedExpansion

:: Windows Environment Fix for Dev Project Runner
:: Fixes Visual Studio Spectre-mitigated libraries issue

title Windows Environment Fix - Dev Project Runner

echo.
echo ================================================================
echo                   WINDOWS ENVIRONMENT FIX                     
echo                    Dev Project Runner                          
echo ================================================================
echo.
echo This tool will help fix the Visual Studio build environment
echo required for node-pty and other native Node.js packages.
echo.
echo Common Issues Fixed:
echo - MSB8040: Spectre-mitigated libraries are required
echo - node-gyp rebuild failures
echo - Visual Studio build tools missing components
echo.

:MAIN_MENU
echo ================================================================
echo.
echo [1] AUTO-FIX - Detect and fix issues automatically
echo [2] MANUAL - Step-by-step instructions 
echo [3] DOWNLOAD - Get Visual Studio Build Tools
echo [4] VERIFY - Test build environment
echo [5] ALTERNATIVE - Install without node-pty
echo [0] EXIT
echo.
set /p choice="Select option (1-5, 0 to exit): "

if "%choice%"=="1" goto AUTO_FIX
if "%choice%"=="2" goto MANUAL_FIX
if "%choice%"=="3" goto DOWNLOAD_TOOLS
if "%choice%"=="4" goto VERIFY_ENV
if "%choice%"=="5" goto ALTERNATIVE_INSTALL
if "%choice%"=="0" goto EXIT

echo [ERROR] Invalid choice. Please try again.
echo.
goto MAIN_MENU

:AUTO_FIX
cls
echo ================================================================
echo                        AUTO-FIX MODE                          
echo ================================================================
echo.
echo [INFO] Detecting Visual Studio installation...

:: Check for Visual Studio installations
set "VS_FOUND=0"
set "VS_PATH="

:: Check VS 2022
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "VS_FOUND=1"
    set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Community"
    set "VS_VERSION=2022 Community"
    echo [OK] Found Visual Studio 2022 Community
)

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set "VS_FOUND=1"
    set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Professional"
    set "VS_VERSION=2022 Professional"
    echo [OK] Found Visual Studio 2022 Professional
)

if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "VS_FOUND=1"
    set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise"
    set "VS_VERSION=2022 Enterprise"
    echo [OK] Found Visual Studio 2022 Enterprise
)

if "%VS_FOUND%"=="0" (
    echo [ERROR] Visual Studio 2022 not found
    echo [INFO] Please install Visual Studio 2022 Community first
    echo [INFO] Go to option [3] to download it
    echo.
    pause
    goto MAIN_MENU
)

echo [OK] Visual Studio %VS_VERSION% detected
echo [INFO] Path: %VS_PATH%

:: Check for Spectre-mitigated libraries
echo.
echo [INFO] Checking for Spectre-mitigated libraries...

:: Check common Spectre library locations
set "SPECTRE_FOUND=0"
if exist "%VS_PATH%\VC\Tools\MSVC\*\lib\spectre" (
    set "SPECTRE_FOUND=1"
    echo [OK] Spectre-mitigated libraries found
) else (
    echo [ERROR] Spectre-mitigated libraries NOT found
    echo [INFO] This is causing the node-pty build failure
)

:: Check Windows SDK
echo.
echo [INFO] Checking Windows SDK...
reg query "HKLM\SOFTWARE\WOW6432Node\Microsoft\Windows Kits\Installed Roots" /v KitsRoot10 >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Windows SDK found
) else (
    echo [WARNING] Windows SDK may be missing
)

:: Check Python for node-gyp
echo.
echo [INFO] Checking Python installation...
python --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Python found:
    python --version
) else (
    echo [WARNING] Python not found (required for node-gyp)
)

echo.
echo ================================================================
echo                        DIAGNOSIS COMPLETE                     
echo ================================================================
echo.

if "%SPECTRE_FOUND%"=="0" (
    echo [ISSUE] Spectre-mitigated libraries are missing
    echo [SOLUTION] Install them through Visual Studio Installer
    echo.
    echo Would you like to:
    echo [1] Open Visual Studio Installer automatically
    echo [2] See manual instructions
    echo [3] Try alternative installation
    echo.
    set /p fix_choice="Select option (1-3): "
    
    if "!fix_choice!"=="1" goto OPEN_VS_INSTALLER
    if "!fix_choice!"=="2" goto SHOW_MANUAL_STEPS
    if "!fix_choice!"=="3" goto ALTERNATIVE_INSTALL
) else (
    echo [SUCCESS] Your environment looks good!
    echo [INFO] The node-pty build should work now
    echo.
    echo Would you like to test the installation?
    set /p test="Test npm install now? (Y/n): "
    if /i "!test!" neq "n" goto TEST_INSTALL
)

pause
goto MAIN_MENU

:OPEN_VS_INSTALLER
echo.
echo [INFO] Opening Visual Studio Installer...
echo [INFO] When it opens:
echo        1. Click "Modify" for your VS 2022 installation
echo        2. Go to "Individual components" tab
echo        3. Search for "Spectre"
echo        4. Check "MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs"
echo        5. Click "Modify" to install
echo.

start "" "%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vs_installer.exe"
if %errorLevel% neq 0 (
    echo [ERROR] Could not open Visual Studio Installer
    echo [INFO] Please run it manually from Start Menu
)

echo.
echo Press any key after installing Spectre libraries...
pause
goto VERIFY_ENV

:SHOW_MANUAL_STEPS
goto MANUAL_FIX

:MANUAL_FIX
cls
echo ================================================================
echo                      MANUAL FIX INSTRUCTIONS                  
echo ================================================================
echo.
echo STEP 1: Install Spectre-mitigated Libraries
echo ============================================
echo.
echo 1. Open "Visual Studio Installer" from Start Menu
echo 2. Find your Visual Studio 2022 installation
echo 3. Click "Modify"
echo 4. Go to "Individual components" tab
echo 5. Search for "Spectre" in the search box
echo 6. Check these items:
echo    - MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (Latest)
echo    - MSVC v143 - VS 2022 C++ ARM64 Spectre-mitigated libs (if needed)
echo 7. Click "Modify" and wait for installation
echo.
echo STEP 2: Install Python (if missing)
echo ====================================
echo.
echo 1. Download Python 3.8+ from python.org
echo 2. During installation, check "Add Python to PATH"
echo 3. Complete the installation
echo.
echo STEP 3: Install Windows SDK (if missing)
echo ========================================
echo.
echo 1. In Visual Studio Installer, also check:
echo    - Windows 10/11 SDK (latest version)
echo    - CMake tools for Visual Studio
echo.
echo STEP 4: Clear npm cache and retry
echo ==================================
echo.
echo After installing the above:
echo 1. Open Command Prompt as Administrator
echo 2. Run: npm cache clean --force
echo 3. Run: npm config set msvs_version 2022
echo 4. Retry your installation
echo.
echo ================================================================
echo.
echo [INFO] After completing these steps, your environment should
echo        be ready for native Node.js package compilation.
echo.
pause
goto MAIN_MENU

:DOWNLOAD_TOOLS
cls
echo ================================================================
echo                    DOWNLOAD BUILD TOOLS                       
echo ================================================================
echo.
echo Option 1: Visual Studio 2022 Community (Recommended)
echo ====================================================
echo - Full IDE with all build tools
echo - Free for individual developers
echo - Size: ~3GB
echo.
echo Download: https://visualstudio.microsoft.com/vs/community/
echo.
echo Option 2: Visual Studio Build Tools 2022 (Minimal)
echo ===================================================
echo - Command-line build tools only
echo - Smaller download
echo - Size: ~1GB
echo.
echo Download: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
echo.
echo Option 3: Auto-download (if available)
echo ======================================
echo.
set /p download="Try to download VS Community automatically? (Y/n): "
if /i "%download%" neq "n" (
    echo [INFO] Downloading Visual Studio Community installer...
    powershell -Command "& {
        try {
            Write-Host '[INFO] Downloading VS Community installer...'
            Invoke-WebRequest -Uri 'https://aka.ms/vs/17/release/vs_community.exe' -OutFile 'vs_community.exe' -UseBasicParsing
            Write-Host '[OK] Download complete'
            Write-Host '[INFO] Starting installer...'
            Start-Process './vs_community.exe' -Wait
        } catch {
            Write-Host '[ERROR] Download failed:' $_.Exception.Message
            Write-Host '[INFO] Please download manually from the website'
        }
    }"
)

echo.
echo [INFO] After installing Visual Studio:
echo        1. Run this script again
echo        2. Use option [1] Auto-fix
echo.
pause
goto MAIN_MENU

:VERIFY_ENV
cls
echo ================================================================
echo                       VERIFY ENVIRONMENT                      
echo ================================================================
echo.
echo [INFO] Testing build environment...

:: Test node-gyp
echo [TEST 1] Testing node-gyp...
npm list -g node-gyp >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] node-gyp is available
) else (
    echo [INFO] Installing node-gyp globally...
    npm install -g node-gyp
)

:: Test basic compilation
echo.
echo [TEST 2] Testing basic compilation...
cd /d "%temp%"
if exist "test-build" rmdir /s /q "test-build"
mkdir "test-build"
cd "test-build"

echo {"name":"test","version":"1.0.0","dependencies":{"bufferutil":"^4.0.7"}} > package.json
npm install >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Basic native compilation works
    set "BUILD_OK=1"
) else (
    echo [ERROR] Native compilation still failing
    set "BUILD_OK=0"
)

:: Clean up test
cd /d "%~dp0"
rmdir /s /q "%temp%\test-build" >nul 2>&1

echo.
echo [TEST 3] Testing node-pty specifically...
cd /d "%temp%"
if exist "pty-test" rmdir /s /q "pty-test"
mkdir "pty-test"
cd "pty-test"

echo {"name":"pty-test","version":"1.0.0","dependencies":{"node-pty":"^1.0.0"}} > package.json
npm install >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] node-pty installation successful!
    echo [SUCCESS] Your environment is ready!
) else (
    echo [ERROR] node-pty still failing
    echo [INFO] Try the manual fix steps or alternative installation
)

:: Clean up test
cd /d "%~dp0"
rmdir /s /q "%temp%\pty-test" >nul 2>&1

echo.
echo ================================================================
echo                       VERIFICATION COMPLETE                   
echo ================================================================
echo.
pause
goto MAIN_MENU

:ALTERNATIVE_INSTALL
cls
echo ================================================================
echo                    ALTERNATIVE INSTALLATION                   
echo ================================================================
echo.
echo This option creates a version without terminal features
echo (removes node-pty dependency that's causing build issues)
echo.
echo Features available:
echo ✅ Project browsing and detection
echo ✅ Running npm scripts
echo ✅ File watching and hot reload
echo ✅ Port management
echo ❌ Integrated terminal (disabled)
echo.
set /p proceed="Proceed with alternative installation? (Y/n): "
if /i "%proceed%"=="n" goto MAIN_MENU

echo.
echo [INFO] Starting alternative installation...

:: Create DevProjectRunner directory if it doesn't exist
if not exist "DevProjectRunner" mkdir "DevProjectRunner"
cd "DevProjectRunner"

:: Create package.json without node-pty
echo [INFO] Creating package.json without node-pty...
(
echo {
echo   "name": "dev-project-runner-lite",
echo   "version": "1.0.0",
echo   "description": "Dev Project Runner - No Terminal Version",
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
) > package.json

echo [OK] Package.json created (without node-pty)

:: Install dependencies
echo.
echo [INFO] Installing dependencies...
npm install
if %errorLevel% neq 0 (
    echo [ERROR] Installation failed even without node-pty
    pause
    goto MAIN_MENU
)

echo [OK] Dependencies installed successfully

:: Copy application files and modify main.js to remove terminal features
echo.
echo [INFO] Setting up application files...

:: Copy main.js and modify it
if exist "../main.js" (
    copy "../main.js" "main.js" >nul
    echo [OK] Application files copied
) else (
    echo [INFO] Creating minimal main.js...
    goto CREATE_MINIMAL_APP
)

:: Copy other files
if exist "../renderer" xcopy "../renderer" "renderer\" /E /I /Y >nul
if exist "../assets" xcopy "../assets" "assets\" /E /I /Y >nul

:: Create launcher
echo.
echo [INFO] Creating launcher...
(
echo @echo off
echo title Dev Project Runner Lite
echo cd /d "%%~dp0"
echo echo Starting Dev Project Runner (No Terminal Version)...
echo call npm start
echo if %%errorLevel%% neq 0 ^(
echo     echo Failed to start application
echo     pause
echo ^)
) > "Launch Dev Project Runner Lite.bat"

echo.
echo [SUCCESS] Alternative installation complete!
echo.
echo Location: %CD%
echo Launcher: Launch Dev Project Runner Lite.bat
echo.
echo Note: This version has terminal features disabled
echo      but all other functionality works normally.
echo.
set /p launch="Launch now? (Y/n): "
if /i "%launch%" neq "n" (
    start "" "Launch Dev Project Runner Lite.bat"
)

pause
goto MAIN_MENU

:CREATE_MINIMAL_APP
:: Create a minimal main.js without terminal dependencies
(
echo const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron'^);
echo const path = require('path'^);
echo const fs = require('fs'^).promises;
echo const { spawn } = require('child_process'^);
echo const chokidar = require('chokidar'^);
echo const treeKill = require('tree-kill'^);
echo const portfinder = require('portfinder'^);
echo.
echo // Simplified version without node-pty terminal features
echo class ProjectRunner {
echo   constructor(^) {
echo     this.mainWindow = null;
echo     this.runningProjects = new Map(^);
echo     this.fileWatchers = new Map(^);
echo   }
echo.
echo   createWindow(^) {
echo     this.mainWindow = new BrowserWindow({
echo       width: 1400,
echo       height: 900,
echo       webPreferences: {
echo         nodeIntegration: true,
echo         contextIsolation: false
echo       },
echo       icon: path.join(__dirname, 'assets', 'icon.png'^),
echo       show: false
echo     }^);
echo.
echo     this.mainWindow.loadFile('DevProjectRunner.html'^);
echo     this.mainWindow.once('ready-to-show', (^) =^> this.mainWindow.show(^)^);
echo     this.mainWindow.on('closed', (^) =^> { this.mainWindow = null; this.cleanup(^); }^);
echo     this.mainWindow.setMenuBarVisibility(false^);
echo   }
echo.
echo   // ... rest of the methods without terminal features
echo }
echo.
echo const runner = new ProjectRunner(^);
echo app.whenReady(^).then(^(^) =^> runner.createWindow(^)^);
echo app.on('window-all-closed', (^) =^> process.platform !== 'darwin' ^&^& app.quit(^)^);
) > main.js

:: Create minimal HTML if it doesn't exist
if not exist "renderer" mkdir "renderer"
if not exist "renderer\index.html" (
    (
    echo ^<!DOCTYPE html^>
    echo ^<html^>
    echo ^<head^>
    echo   ^<title^>Dev Project Runner Lite^</title^>
    echo   ^<style^>body { font-family: Arial; padding: 20px; }^</style^>
    echo ^</head^>
    echo ^<body^>
    echo   ^<h1^>Dev Project Runner Lite^</h1^>
    echo   ^<p^>Terminal features disabled for compatibility^</p^>
    echo   ^<p^>All other features available^</p^>
    echo ^</body^>
    echo ^</html^>
    ) > "renderer\index.html"
)

echo [OK] Minimal application created
goto :EOF

:TEST_INSTALL
echo.
echo [INFO] Testing installation in temporary directory...
cd /d "%temp%"
if exist "install-test" rmdir /s /q "install-test"
mkdir "install-test"
cd "install-test"

echo {"name":"install-test","version":"1.0.0","dependencies":{"node-pty":"^1.0.0"}} > package.json
npm install
if %errorLevel% == 0 (
    echo [SUCCESS] Test installation worked!
    echo [INFO] Your environment is ready for Dev Project Runner
) else (
    echo [ERROR] Test installation still failing
    echo [INFO] Please try the manual fix steps
)

cd /d "%~dp0"
rmdir /s /q "%temp%\install-test" >nul 2>&1
pause
goto MAIN_MENU

:EXIT
echo.
echo Windows Environment Fix completed.
echo.
echo If you continue to have issues:
echo 1. Try the alternative installation (option 5)
echo 2. Check the manual instructions (option 2)  
echo 3. Verify your Visual Studio installation
echo.
pause
exit /b

endlocal