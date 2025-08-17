@echo off
setlocal EnableDelayedExpansion

:: Debug mode - keep window open on errors
if "%1"=="--debug" (
    set "DEBUG_MODE=1"
    echo [DEBUG] Debug mode enabled
    pause
)

:: Check for admin privileges with better error handling
echo [INFO] Checking administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Administrator privileges required
    echo [INFO] Attempting to restart with admin rights...
    powershell -Command "try { Start-Process '%~f0' -Verb RunAs -ArgumentList '--debug' } catch { Write-Host 'Failed to elevate privileges'; pause }"
    if not "%DEBUG_MODE%"=="1" exit /b
    echo [ERROR] Failed to get admin rights - continuing anyway
    pause
)

:: Set working directory with error check
echo [INFO] Setting working directory...
cd /d "%~dp0"
if %errorLevel% neq 0 (
    echo [ERROR] Failed to change directory
    pause
    exit /b 1
)

echo [OK] Working directory: %CD%

:MAIN_MENU
cls
echo.
echo ================================================================
echo                     DEV PROJECT RUNNER                        
echo                   Standalone Installer v1.0 (Debug)
echo ================================================================
echo.
echo  Select installation type:
echo.
echo  [1] RECOMMENDED - Full Installation
echo      * Detailed progress and logs
echo      * Error handling and recovery
echo      * Creates shortcuts and launchers
echo      * Time: 10-15 minutes
echo.
echo  [2] QUICK - Silent Installation
echo      * Minimal output, faster setup
echo      * Progress bar only
echo      * Essential components only
echo      * Time: 5-8 minutes
echo.
echo  [3] CUSTOM - Advanced Options
echo      * Choose components to install
echo      * Specify installation directory
echo      * Configure settings
echo.
echo  [4] SYSTEM INFO - Check Requirements
echo.
echo  [5] DEBUG - Test Functions Only
echo.
echo  [0] EXIT
echo.
echo ================================================================
echo.
echo Installation Directory: %CD%\DevProjectRunner
echo Required Space: ~500MB
echo Internet Required: Yes (first time only)
echo.
set /p choice="Select option (1/2/3/4/5/0): "

echo [DEBUG] User selected: %choice%

if "%choice%"=="1" goto FULL_INSTALL
if "%choice%"=="2" goto QUICK_INSTALL
if "%choice%"=="3" goto CUSTOM_INSTALL
if "%choice%"=="4" goto SYSTEM_INFO
if "%choice%"=="5" goto DEBUG_TEST
if "%choice%"=="0" goto EXIT
echo [ERROR] Invalid choice: %choice%
echo Press any key to try again...
pause >nul
goto MAIN_MENU

:DEBUG_TEST
cls
echo ================================================================
echo                        DEBUG TEST                             
echo ================================================================
echo.
echo Testing critical functions...
echo.

echo [TEST 1] Directory creation...
if not exist "TEST_DIR" (
    mkdir "TEST_DIR"
    if %errorLevel% == 0 (
        echo [OK] Directory creation works
        rmdir "TEST_DIR"
    ) else (
        echo [ERROR] Cannot create directories
    )
) else (
    echo [OK] Directory already exists
)

echo.
echo [TEST 2] PowerShell access...
powershell -Command "Write-Host '[OK] PowerShell is accessible'" 2>nul
if %errorLevel% neq 0 (
    echo [ERROR] PowerShell not accessible
)

echo.
echo [TEST 3] Internet connectivity...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Internet connection available
) else (
    echo [WARNING] No internet connection
)

echo.
echo [TEST 4] Node.js check...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js already installed:
    node --version
) else (
    echo [INFO] Node.js not installed (will be downloaded)
)

echo.
echo [TEST 5] npm check...
npm --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] npm available:
    npm --version
) else (
    echo [INFO] npm not available (will be installed with Node.js)
)

echo.
echo ================================================================
echo                    DEBUG TEST COMPLETE                        
echo ================================================================
echo.
pause
goto MAIN_MENU

:FULL_INSTALL
cls
echo ================================================================
echo                     FULL INSTALLATION                         
echo ================================================================
echo.
echo This will install all components with detailed progress:
echo * Node.js Runtime (~50MB)
echo * NPM Dependencies (~200MB)  
echo * Electron Framework (~150MB)
echo * Build Tools (~100MB)
echo * Application Files (~10MB)
echo.
echo Total Download: ~510MB
echo Installation Time: 10-15 minutes
echo.
echo [WARNING] Make sure you have stable internet connection
echo [WARNING] Do not close this window during installation
echo.
set /p confirm="Continue with full installation? (Y/n): "
if /i "%confirm%"=="n" goto MAIN_MENU

echo.
echo [INFO] Starting Full Installation...
echo ===============================================================

:: Create installation directory with error checking
echo.
echo [STEP 1/6] Creating installation directory...
if not exist "DevProjectRunner" (
    mkdir "DevProjectRunner"
    if %errorLevel% neq 0 (
        echo [ERROR] Failed to create DevProjectRunner directory
        echo [ERROR] Check if you have write permissions in: %CD%
        pause
        goto MAIN_MENU
    )
    echo [OK] Directory created: %CD%\DevProjectRunner
) else (
    echo [INFO] Directory already exists: %CD%\DevProjectRunner
)

cd DevProjectRunner
if %errorLevel% neq 0 (
    echo [ERROR] Failed to enter DevProjectRunner directory
    pause
    goto MAIN_MENU
)

echo [OK] Working in: %CD%

:: Step 2: Node.js installation with better error handling
echo.
echo [STEP 2/6] Checking Node.js installation...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js already installed: 
    node --version
    set "PATH=%CD%;%CD%\npm;%PATH%"
) else (
    echo [INFO] Node.js not found - downloading...
    call :INSTALL_NODEJS
    if %errorLevel% neq 0 (
        echo [ERROR] Node.js installation failed
        pause
        goto MAIN_MENU
    )
)

:: Step 3: Create package.json with error checking
echo.
echo [STEP 3/6] Creating package configuration...
call :CREATE_PACKAGE_JSON
if %errorLevel% neq 0 (
    echo [ERROR] Failed to create package.json
    pause
    goto MAIN_MENU
)
echo [OK] Package configuration created

:: Step 4: Install dependencies with better error handling
echo.
echo [STEP 4/6] Installing dependencies (~300MB)...
echo [INFO] This will take 5-10 minutes depending on your connection...
echo [INFO] Please be patient, downloading from npm registry...
echo [INFO] Do not close this window!
echo.

call npm install
if %errorLevel% neq 0 (
    echo [ERROR] Failed to install dependencies
    echo [ERROR] This could be due to:
    echo         - No internet connection
    echo         - Firewall blocking npm
    echo         - Insufficient disk space
    echo         - npm registry unavailable
    echo.
    echo [INFO] You can try again later or check your connection
    pause
    goto MAIN_MENU
)
echo [OK] All dependencies installed successfully

:: Step 5: Download application files
echo.
echo [STEP 5/6] Downloading application files...
call :DOWNLOAD_APP_FILES
if %errorLevel% neq 0 (
    echo [WARNING] Some application files may be missing
    echo [INFO] Creating minimal templates instead...
    call :CREATE_MINIMAL_FILES
)
echo [OK] Application files ready

:: Step 6: Create launchers
echo.
echo [STEP 6/6] Creating launchers and shortcuts...
call :CREATE_LAUNCHERS
if %errorLevel% neq 0 (
    echo [ERROR] Failed to create launchers
    pause
    goto MAIN_MENU
)
echo [OK] Launchers created

echo.
echo [SUCCESS] FULL INSTALLATION COMPLETED SUCCESSFULLY!
echo.
goto INSTALL_COMPLETE

:INSTALL_NODEJS
echo [INFO] Downloading Node.js v18.19.0...
powershell -Command "& {
    try {
        Write-Host '[INFO] Downloading from nodejs.org...' -ForegroundColor Yellow
        Invoke-WebRequest -Uri 'https://nodejs.org/dist/v18.19.0/node-v18.19.0-win-x64.zip' -OutFile 'node.zip' -UseBasicParsing
        Write-Host '[INFO] Extracting Node.js...' -ForegroundColor Yellow
        Expand-Archive -Path 'node.zip' -DestinationPath 'node-temp' -Force
        Move-Item 'node-temp\node-v18.19.0-win-x64\*' '.\' -Force
        Remove-Item 'node-temp' -Recurse -Force
        Remove-Item 'node.zip' -Force
        Write-Host '[OK] Node.js installed successfully' -ForegroundColor Green
        exit 0
    } catch {
        Write-Host '[ERROR] Failed to download/extract Node.js' -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
        exit 1
    }
}"

if %errorLevel% neq 0 (
    echo [ERROR] Node.js installation failed
    exit /b 1
)

:: Update PATH
set "PATH=%CD%;%CD%\npm;%PATH%"

:: Verify installation
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Node.js installation verification failed
    exit /b 1
)

echo [OK] Node.js installed and verified
exit /b 0

:CREATE_PACKAGE_JSON
(
echo {
echo   "name": "dev-project-runner-standalone",
echo   "version": "1.0.0",
echo   "description": "Standalone Dev Project Runner",
echo   "main": "main.js",
echo   "scripts": {
echo     "start": "electron . --no-sandbox",
echo     "postinstall": "electron-builder install-app-deps"
echo   },
echo   "dependencies": {
echo     "electron": "^28.0.0",
echo     "chokidar": "^3.5.3",
echo     "tree-kill": "^1.2.2",
echo     "portfinder": "^1.0.32",
echo     "extract-zip": "^2.0.1",
echo     "node-pty": "^1.0.0",
echo     "ws": "^8.14.2"
echo   },
echo   "devDependencies": {
echo     "electron-builder": "^24.6.4"
echo   }
echo }
) > package.json 2>nul

if not exist package.json (
    exit /b 1
)
exit /b 0

:CREATE_MINIMAL_FILES
echo [INFO] Creating minimal application files...

:: Create directories
if not exist "renderer" mkdir "renderer"
if not exist "assets" mkdir "assets"

:: Create minimal main.js
(
echo const { app, BrowserWindow } = require('electron'^);
echo.
echo function createWindow(^) {
echo   const mainWindow = new BrowserWindow({
echo     width: 1200,
echo     height: 800,
echo     webPreferences: {
echo       nodeIntegration: true,
echo       contextIsolation: false
echo     }
echo   }^);
echo.
echo   mainWindow.loadFile('renderer/index.html'^);
echo }
echo.
echo app.whenReady(^).then(createWindow^);
echo.
echo app.on('window-all-closed', (^) =^> {
echo   if (process.platform !== 'darwin'^) {
echo     app.quit(^);
echo   }
echo }^);
) > main.js

:: Create minimal HTML
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<title^>Dev Project Runner^</title^>
echo ^</head^>
echo ^<body^>
echo   ^<h1^>Dev Project Runner^</h1^>
echo   ^<p^>Minimal installation complete!^</p^>
echo ^</body^>
echo ^</html^>
) > renderer/index.html

echo [OK] Minimal files created
exit /b 0

:DOWNLOAD_APP_FILES
echo [INFO] Attempting to download application files from GitHub...
powershell -Command "& {
    try {
        New-Item -ItemType Directory -Force -Path 'renderer', 'assets' >null
        
        # Note: Replace with your actual GitHub URLs
        $baseUrl = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main'
        
        $files = @{
            'main.js' = '$baseUrl/main.js'
            'renderer/index.html' = '$baseUrl/renderer/index.html'
            'renderer/styles.css' = '$baseUrl/renderer/styles.css'
            'renderer/app.js' = '$baseUrl/renderer/app.js'
        }
        
        $success = $true
        foreach ($file in $files.GetEnumerator()) {
            try {
                Write-Host '[INFO] Downloading:' $file.Key
                Invoke-WebRequest -Uri $file.Value -OutFile $file.Key -UseBasicParsing -TimeoutSec 30
            } catch {
                Write-Host '[WARNING] Failed to download' $file.Key
                $success = $false
            }
        }
        
        if ($success) {
            Write-Host '[OK] All application files downloaded'
            exit 0
        } else {
            Write-Host '[WARNING] Some files failed to download'
            exit 1
        }
    } catch {
        Write-Host '[ERROR] Download process failed:' $_.Exception.Message
        exit 1
    }
}"
exit /b %errorLevel%

:CREATE_LAUNCHERS
:: Main launcher with error handling
(
echo @echo off
echo title Dev Project Runner
echo cd /d "%%~dp0"
echo echo [INFO] Starting Dev Project Runner...
echo echo [INFO] Working directory: %%CD%%
echo.
echo if not exist "main.js" ^(
echo     echo [ERROR] main.js not found
echo     echo [ERROR] Installation may be incomplete
echo     pause
echo     exit /b 1
echo ^)
echo.
echo if not exist "node_modules" ^(
echo     echo [ERROR] node_modules not found
echo     echo [ERROR] Please run the installer again
echo     pause
echo     exit /b 1
echo ^)
echo.
echo call npm start
echo if %%errorLevel%% neq 0 ^(
echo     echo [ERROR] Failed to start application
echo     echo [ERROR] Check the console for errors above
echo     echo.
echo     pause
echo ^) else ^(
echo     echo [INFO] Application closed normally
echo ^)
) > "Launch Dev Project Runner.bat"

if not exist "Launch Dev Project Runner.bat" (
    echo [ERROR] Failed to create launcher
    exit /b 1
)

echo [OK] Launcher created
exit /b 0

:QUICK_INSTALL
echo [INFO] Quick installation not implemented yet
echo [INFO] Please use Full Installation (Option 1)
pause
goto MAIN_MENU

:CUSTOM_INSTALL
echo [INFO] Custom installation not implemented yet
echo [INFO] Please use Full Installation (Option 1)
pause
goto MAIN_MENU

:SYSTEM_INFO
cls
echo ================================================================
echo                     SYSTEM INFORMATION                        
echo ================================================================
echo.
echo System Requirements Check:
echo.

echo Operating System:
systeminfo | findstr /C:"OS Name" 2>nul
systeminfo | findstr /C:"OS Version" 2>nul

echo.
echo Architecture:
systeminfo | findstr /C:"System Type" 2>nul

echo.
echo Available Disk Space:
dir /-c %~d0 2>nul | find "bytes free"

echo.
echo Current Directory: %CD%

echo.
echo Administrator Rights:
net session >nul 2>&1
if %errorLevel% == 0 (
    echo   Status: [OK] Administrator
) else (
    echo   Status: [WARNING] Not administrator
)

echo.
echo Internet Connectivity:
ping -n 1 8.8.8.8 >nul 2>&1
if %errorLevel% == 0 (
    echo   Status: [OK] Connected
) else (
    echo   Status: [ERROR] No internet connection
    echo   WARNING: Internet required for installation
)

echo.
echo Node.js Status:
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo   Installed: [OK] 
    node --version
) else (
    echo   Installed: [NO] Will be downloaded during installation
)

echo.
echo [OK] System check complete
echo.
pause
goto MAIN_MENU

:INSTALL_COMPLETE
echo.
echo ================================================================
echo                  INSTALLATION SUCCESSFUL!                     
echo ================================================================
echo.
echo  Launch App: "Launch Dev Project Runner.bat"             
echo  Update:     "Update.bat" (if created)
echo  Uninstall:  "Uninstall.bat" (if created)
echo.
echo  Location: %CD%                                          
echo  Size: ~500MB                                            
echo  Status: Ready for offline use!                          
echo ================================================================
echo.

set /p launch="Launch Dev Project Runner now? (Y/n): "
if /i "%launch%" neq "n" (
    if exist "Launch Dev Project Runner.bat" (
        echo [INFO] Starting application...
        start "" "Launch Dev Project Runner.bat"
        timeout /t 2 >nul
        exit /b
    ) else (
        echo [ERROR] Launcher not found - installation may be incomplete
        pause
    )
)

echo.
echo Installation complete! You can launch it anytime.
echo.
pause
exit /b

:EXIT
echo.
echo Installation cancelled by user.
echo.
pause
exit /b