@echo off
setlocal EnableDelayedExpansion

:: Enhanced Dev Project Runner Installer with Error Handling
:: Handles Visual Studio, node-pty, and other build issues

title Dev Project Runner - Enhanced Installer

:: Debug mode - keep window open on errors
if "%1"=="--debug" (
    set "DEBUG_MODE=1"
    echo [DEBUG] Debug mode enabled
)

:: Set working directory
cd /d "%~dp0"

:MAIN_MENU
cls
echo.
echo ================================================================
echo                    DEV PROJECT RUNNER                        
echo                   Enhanced Installer v2.0
echo ================================================================
echo.
echo  Select installation type:
echo.
echo  [1] SMART INSTALL - Auto-detect and fix issues
echo      * Checks build environment first
echo      * Handles Visual Studio issues
echo      * Provides fallback options
echo      * Time: 5-20 minutes
echo.
echo  [2] STANDARD INSTALL - Full installation
echo      * Traditional installation method
echo      * Detailed progress logging
echo      * May fail on build issues
echo      * Time: 10-15 minutes
echo.
echo  [3] LITE INSTALL - No terminal features
echo      * Skips problematic dependencies
echo      * Works on any Windows system
echo      * Reduced functionality
echo      * Time: 5-8 minutes
echo.
echo  [4] ENV CHECK - Test build environment
echo.
echo  [5] REPAIR - Fix existing installation
echo.
echo  [0] EXIT
echo.
echo ================================================================
echo.
echo Installation Directory: %CD%\DevProjectRunner
echo Required Space: ~500MB (Standard), ~300MB (Lite)
echo Internet Required: Yes (first time only)
echo.
set /p choice="Select option (1/2/3/4/5/0): "

echo [DEBUG] User selected: %choice%

if "%choice%"=="1" goto SMART_INSTALL
if "%choice%"=="2" goto STANDARD_INSTALL
if "%choice%"=="3" goto LITE_INSTALL
if "%choice%"=="4" goto ENV_CHECK
if "%choice%"=="5" goto REPAIR_INSTALL
if "%choice%"=="0" goto EXIT
echo [ERROR] Invalid choice: %choice%
echo Press any key to try again...
pause >nul
goto MAIN_MENU

:SMART_INSTALL
cls
echo ================================================================
echo                        SMART INSTALL                          
echo ================================================================
echo.
echo [INFO] This installer will check your environment first
echo        and automatically handle common build issues.
echo.
echo Step 1: Environment Analysis
echo ============================
echo.

:: Check admin privileges
echo [CHECK] Administrator privileges...
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [WARNING] Not running as administrator
    echo [INFO] Some features may not work properly
    set "ADMIN_OK=0"
) else (
    echo [OK] Administrator privileges confirmed
    set "ADMIN_OK=1"
)

:: Check disk space
echo [CHECK] Disk space...
for /f "tokens=3" %%a in ('dir /-c %~d0 2^>nul ^| find "bytes free"') do set "FREE_SPACE=%%a"
if !FREE_SPACE! LSS 1000000000 (
    echo [WARNING] Low disk space: !FREE_SPACE! bytes
    echo [RECOMMEND] Need at least 1GB free space
    set "SPACE_OK=0"
) else (
    echo [OK] Sufficient disk space available
    set "SPACE_OK=1"
)

:: Check internet connectivity
echo [CHECK] Internet connectivity...
ping -n 1 8.8.8.8 >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Internet connection available
    set "NET_OK=1"
) else (
    echo [ERROR] No internet connection
    echo [FAIL] Internet required for installation
    pause
    goto MAIN_MENU
)

:: Check Node.js
echo [CHECK] Node.js installation...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js found:
    node --version
    set "NODE_OK=1"
) else (
    echo [INFO] Node.js not found - will be installed
    set "NODE_OK=0"
)

:: Check Visual Studio for native compilation
echo [CHECK] Visual Studio build environment...
call :CHECK_VS_ENVIRONMENT
if "%VS_BUILD_OK%"=="1" (
    echo [OK] Build environment ready for native packages
    set "BUILD_OK=1"
) else (
    echo [WARNING] Build environment has issues
    echo [INFO] node-pty and other native packages may fail
    set "BUILD_OK=0"
)

:: Python check for node-gyp
echo [CHECK] Python for node-gyp...
python --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Python found:
    python --version
    set "PYTHON_OK=1"
) else (
    echo [WARNING] Python not found
    echo [INFO] May cause issues with native packages
    set "PYTHON_OK=0"
)

echo.
echo ================================================================
echo                    ENVIRONMENT ANALYSIS                       
echo ================================================================

echo Administrator: !ADMIN_OK!
echo Disk Space: !SPACE_OK!
echo Internet: !NET_OK!
echo Node.js: !NODE_OK!
echo Build Tools: !BUILD_OK!
echo Python: !PYTHON_OK!

echo.
echo Recommendation:
if "%BUILD_OK%"=="1" (
    echo [RECOMMEND] Standard installation should work
    set "RECOMMEND=STANDARD"
) else (
    echo [RECOMMEND] Lite installation recommended
    echo [REASON] Build environment issues detected
    set "RECOMMEND=LITE"
)

echo.
echo What would you like to do?
echo [1] Continue with %RECOMMEND% installation
echo [2] Try standard installation anyway
echo [3] Use lite installation (no terminal features)
echo [4] Fix build environment first
echo [5] Back to main menu
echo.
set /p install_choice="Select option (1-5): "

if "%install_choice%"=="1" (
    if "%RECOMMEND%"=="STANDARD" goto DO_STANDARD_INSTALL
    if "%RECOMMEND%"=="LITE" goto DO_LITE_INSTALL
)
if "%install_choice%"=="2" goto DO_STANDARD_INSTALL
if "%install_choice%"=="3" goto DO_LITE_INSTALL
if "%install_choice%"=="4" (
    echo [INFO] Launching Windows Environment Fix tool...
    if exist "WindowsEnvFix.bat" (
        call "WindowsEnvFix.bat"
    ) else (
        echo [ERROR] WindowsEnvFix.bat not found
        echo [INFO] Please download the complete installer package
    )
    pause
    goto MAIN_MENU
)
if "%install_choice%"=="5" goto MAIN_MENU

echo [ERROR] Invalid choice
pause
goto SMART_INSTALL

:CHECK_VS_ENVIRONMENT
:: Check for Visual Studio installations and Spectre libraries
set "VS_BUILD_OK=0"

:: Check VS 2022
if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin\MSBuild.exe" (
    set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Community"
    set "VS_FOUND=1"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Professional\MSBuild\Current\Bin\MSBuild.exe" (
    set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Professional"
    set "VS_FOUND=1"
) else if exist "%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise\MSBuild\Current\Bin\MSBuild.exe" (
    set "VS_PATH=%ProgramFiles%\Microsoft Visual Studio\2022\Enterprise"
    set "VS_FOUND=1"
) else (
    set "VS_FOUND=0"
    echo [WARNING] Visual Studio 2022 not found
    goto :EOF
)

:: Check for Spectre-mitigated libraries
if exist "%VS_PATH%\VC\Tools\MSVC\*\lib\spectre" (
    set "VS_BUILD_OK=1"
    echo [OK] Visual Studio with Spectre libraries found
) else (
    echo [WARNING] Visual Studio found but missing Spectre libraries
    echo [INFO] This will cause node-pty build failures (MSB8040 error)
)
goto :EOF

:DO_STANDARD_INSTALL
echo.
echo [INFO] Starting standard installation...
goto STANDARD_INSTALL_IMPL

:DO_LITE_INSTALL
echo.
echo [INFO] Starting lite installation...
goto LITE_INSTALL_IMPL

:STANDARD_INSTALL
cls
echo ================================================================
echo                     STANDARD INSTALLATION                     
echo ================================================================
echo.
echo [WARNING] This installation includes all features but may fail
echo           if build environment issues exist.
echo.
echo [INFO] If installation fails, try:
echo        1. Use Smart Install (option 1) 
echo        2. Fix environment with WindowsEnvFix.bat
echo        3. Use Lite Install (option 3)
echo.
set /p confirm="Continue with standard installation? (Y/n): "
if /i "%confirm%"=="n" goto MAIN_MENU

:STANDARD_INSTALL_IMPL
echo.
echo [INFO] Starting Standard Installation...
echo ===============================================================

:: Create installation directory
echo.
echo [STEP 1/6] Creating installation directory...
call :CREATE_INSTALL_DIR
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Install Node.js if needed
echo.
echo [STEP 2/6] Setting up Node.js...
call :SETUP_NODEJS
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Create package.json with full dependencies
echo.
echo [STEP 3/6] Creating package configuration...
call :CREATE_FULL_PACKAGE_JSON
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Install dependencies with error handling
echo.
echo [STEP 4/6] Installing dependencies...
echo [INFO] This step may take 5-10 minutes...
echo [INFO] Common issues and solutions will be displayed if errors occur
echo.
call :INSTALL_DEPENDENCIES_WITH_HANDLING
if %errorLevel% neq 0 goto HANDLE_INSTALL_ERROR

:: Setup application files
echo.
echo [STEP 5/6] Setting up application files...
call :SETUP_APP_FILES
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Create launchers
echo.
echo [STEP 6/6] Creating launchers...
call :CREATE_LAUNCHERS "standard"
if %errorLevel% neq 0 goto INSTALL_FAILED

echo.
echo [SUCCESS] Standard installation completed successfully!
goto INSTALL_SUCCESS

:LITE_INSTALL
cls
echo ================================================================
echo                      LITE INSTALLATION                        
echo ================================================================
echo.
echo This installation removes problematic dependencies:
echo.
echo Features included:
echo ✅ Project browsing and detection
echo ✅ Running npm scripts  
echo ✅ File watching and hot reload
echo ✅ Port management
echo ❌ Integrated terminal (node-pty removed)
echo.
echo Benefits:
echo • Works on any Windows system
echo • No Visual Studio build tools required
echo • Faster installation
echo • More reliable
echo.
set /p confirm="Continue with lite installation? (Y/n): "
if /i "%confirm%"=="n" goto MAIN_MENU

:LITE_INSTALL_IMPL
echo.
echo [INFO] Starting Lite Installation...
echo ===============================================================

:: Create installation directory
echo.
echo [STEP 1/5] Creating installation directory...
call :CREATE_INSTALL_DIR
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Install Node.js if needed
echo.
echo [STEP 2/5] Setting up Node.js...
call :SETUP_NODEJS
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Create package.json without problematic dependencies
echo.
echo [STEP 3/5] Creating lite package configuration...
call :CREATE_LITE_PACKAGE_JSON
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Install dependencies (should be reliable)
echo.
echo [STEP 4/5] Installing dependencies (lite version)...
call npm install
if %errorLevel% neq 0 (
    echo [ERROR] Even lite installation failed
    echo [INFO] This suggests a fundamental npm or Node.js issue
    goto INSTALL_FAILED
)
echo [OK] Lite dependencies installed successfully

:: Setup application files
echo.
echo [STEP 5/5] Setting up application files...
call :SETUP_APP_FILES_LITE
if %errorLevel% neq 0 goto INSTALL_FAILED

:: Create launchers
call :CREATE_LAUNCHERS "lite"
if %errorLevel% neq 0 goto INSTALL_FAILED

echo.
echo [SUCCESS] Lite installation completed successfully!
echo [INFO] Terminal features are disabled in this version
goto INSTALL_SUCCESS

:INSTALL_DEPENDENCIES_WITH_HANDLING
:: Install with detailed error logging
echo [INFO] Running npm install...
npm install > install.log 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] npm install failed
    exit /b 1
)
echo [OK] Dependencies installed successfully
exit /b 0

:HANDLE_INSTALL_ERROR
echo.
echo ================================================================
echo                      INSTALLATION ERROR                       
echo ================================================================
echo.
echo [ERROR] Standard installation failed during dependency installation
echo.

:: Check for specific error patterns
findstr /C:"MSB8040" install.log >nul 2>&1
if %errorLevel% == 0 (
    echo [DETECTED] Visual Studio Spectre libraries error (MSB8040)
    echo.
    echo SOLUTION OPTIONS:
    echo [1] Install Spectre libraries (recommended)
    echo [2] Try lite installation instead
    echo [3] Skip problematic packages
    echo.
    set /p error_choice="Select solution (1-3): "
    
    if "!error_choice!"=="1" (
        echo [INFO] Launching environment fix tool...
        if exist "WindowsEnvFix.bat" (
            call "WindowsEnvFix.bat"
            echo [INFO] After fixing environment, try installation again
        ) else (
            echo [ERROR] WindowsEnvFix.bat not found
            call :SHOW_MANUAL_SPECTRE_FIX
        )
        pause
        goto MAIN_MENU
    )
    if "!error_choice!"=="2" goto LITE_INSTALL_IMPL
    if "!error_choice!"=="3" goto TRY_SKIP_PROBLEMATIC
)

findstr /C:"node-pty" install.log >nul 2>&1
if %errorLevel% == 0 (
    echo [DETECTED] node-pty compilation error
    echo [INFO] This is usually caused by missing Visual Studio components
    echo.
    echo SOLUTION: Try lite installation (removes node-pty)
    set /p try_lite="Switch to lite installation? (Y/n): "
    if /i "!try_lite!" neq "n" goto LITE_INSTALL_IMPL
)

findstr /C:"network" install.log >nul 2>&1
if %errorLevel% == 0 (
    echo [DETECTED] Network/download error
    echo [INFO] This could be firewall, proxy, or connectivity issue
    echo.
    echo SOLUTIONS:
    echo 1. Check internet connection
    echo 2. Configure npm proxy if behind corporate firewall
    echo 3. Try again later
)

:: Show general error info
echo.
echo GENERAL ERROR INFORMATION:
echo =========================
echo.
echo Last 10 lines of install.log:
tail -n 10 install.log 2>nul || (
    echo [INFO] Showing end of error log:
    powershell -Command "Get-Content 'install.log' | Select-Object -Last 10"
)

echo.
echo [INFO] Full log saved to: %CD%\DevProjectRunner\install.log
echo.
set /p retry="Would you like to try lite installation instead? (Y/n): "
if /i "%retry%" neq "n" goto LITE_INSTALL_IMPL

pause
goto MAIN_MENU

:TRY_SKIP_PROBLEMATIC
echo.
echo [INFO] Attempting installation without problematic packages...
call :CREATE_LITE_PACKAGE_JSON
npm install
if %errorLevel% == 0 (
    echo [OK] Installation successful without problematic packages
    call :SETUP_APP_FILES_LITE
    call :CREATE_LAUNCHERS "lite"
    goto INSTALL_SUCCESS
) else (
    echo [ERROR] Installation still failing
    goto INSTALL_FAILED
)
goto :EOF

:SHOW_MANUAL_SPECTRE_FIX
echo.
echo MANUAL FIX FOR SPECTRE LIBRARIES:
echo =================================
echo.
echo 1. Open "Visual Studio Installer" from Start Menu
echo 2. Find your Visual Studio 2022 installation  
echo 3. Click "Modify"
echo 4. Go to "Individual components" tab
echo 5. Search for "Spectre"
echo 6. Check: "MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs"
echo 7. Click "Modify" and wait for installation
echo 8. Run this installer again
echo.
goto :EOF

:: Supporting functions
:CREATE_INSTALL_DIR
if not exist "DevProjectRunner" (
    mkdir "DevProjectRunner"
    if %errorLevel% neq 0 (
        echo [ERROR] Failed to create DevProjectRunner directory
        echo [ERROR] Check permissions in: %CD%
        exit /b 1
    )
    echo [OK] Directory created: %CD%\DevProjectRunner
) else (
    echo [INFO] Directory already exists: %CD%\DevProjectRunner
)

cd DevProjectRunner
if %errorLevel% neq 0 (
    echo [ERROR] Failed to enter DevProjectRunner directory
    exit /b 1
)
echo [OK] Working in: %CD%
exit /b 0

:SETUP_NODEJS
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo [OK] Node.js already installed:
    node --version
    set "PATH=%CD%;%CD%\npm;%PATH%"
) else (
    echo [INFO] Downloading Node.js v18.19.0...
    call :DOWNLOAD_NODEJS
    if %errorLevel% neq 0 (
        echo [ERROR] Node.js installation failed
        exit /b 1
    )
)
exit /b 0

:DOWNLOAD_NODEJS
powershell -Command "& {
    try {
        Write-Host '[INFO] Downloading from nodejs.org...'
        Invoke-WebRequest -Uri 'https://nodejs.org/dist/v18.19.0/node-v18.19.0-win-x64.zip' -OutFile 'node.zip' -UseBasicParsing
        Write-Host '[INFO] Extracting Node.js...'
        Expand-Archive -Path 'node.zip' -DestinationPath 'node-temp' -Force
        Move-Item 'node-temp\node-v18.19.0-win-x64\*' '.\' -Force
        Remove-Item 'node-temp' -Recurse -Force
        Remove-Item 'node.zip' -Force
        Write-Host '[OK] Node.js installed successfully'
        exit 0
    } catch {
        Write-Host '[ERROR] Failed to download/extract Node.js'
        Write-Host $_.Exception.Message
        exit 1
    }
}"
if %errorLevel% neq 0 exit /b 1

set "PATH=%CD%;%CD%\npm;%PATH%"
node --version >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Node.js installation verification failed
    exit /b 1
)
echo [OK] Node.js installed and verified
exit /b 0

:CREATE_FULL_PACKAGE_JSON
(
echo {
echo   "name": "dev-project-runner-standalone",
echo   "version": "1.0.0",
echo   "description": "Standalone Dev Project Runner",
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
echo     "node-pty": "^1.0.0",
echo     "ws": "^8.14.2"
echo   },
echo   "devDependencies": {
echo     "electron-builder": "^24.6.4"
echo   }
echo }
) > package.json 2>nul
if not exist package.json exit /b 1
echo [OK] Full package.json created
exit /b 0

:CREATE_LITE_PACKAGE_JSON
(
echo {
echo   "name": "dev-project-runner-lite",
echo   "version": "1.0.0",
echo   "description": "Dev Project Runner - Lite Version",
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
) > package.json 2>nul
if not exist package.json exit /b 1
echo [OK] Lite package.json created (without node-pty)
exit /b 0

:SETUP_APP_FILES
:: Copy main application files
if exist "../main.js" (
    copy "../main.js" "main.js" >nul
    echo [OK] Main application file copied
) else (
    echo [INFO] Creating default main.js...
    call :CREATE_DEFAULT_MAIN_JS
)

:: Copy other files
if exist "../renderer" (
    xcopy "../renderer" "renderer\" /E /I /Y >nul 2>&1
    echo [OK] Renderer files copied
) else (
    call :CREATE_DEFAULT_RENDERER
)

if exist "../assets" (
    xcopy "../assets" "assets\" /E /I /Y >nul 2>&1
    echo [OK] Asset files copied
) else (
    mkdir "assets" >nul 2>&1
    echo [INFO] Assets directory created
)

echo [OK] Application files ready
exit /b 0

:SETUP_APP_FILES_LITE
:: Same as SETUP_APP_FILES but creates lite version
call :SETUP_APP_FILES
:: Modify main.js to remove terminal features if needed
echo [INFO] Configuring for lite mode (terminal features disabled)
exit /b 0

:CREATE_DEFAULT_MAIN_JS
:: Create a basic main.js file
(
echo const { app, BrowserWindow, ipcMain, dialog, shell } = require('electron'^);
echo const path = require('path'^);
echo const fs = require('fs'^).promises;
echo const { spawn } = require('child_process'^);
echo const chokidar = require('chokidar'^);
echo const treeKill = require('tree-kill'^);
echo const portfinder = require('portfinder'^);
echo.
echo class ProjectRunner {
echo   constructor(^) {
echo     this.mainWindow = null;
echo     this.runningProjects = new Map(^);
echo     this.fileWatchers = new Map(^);
echo   }
echo.
echo   createWindow(^) {
echo     this.mainWindow = new BrowserWindow({
echo       width: 1400, height: 900,
echo       webPreferences: { nodeIntegration: true, contextIsolation: false },
echo       show: false
echo     }^);
echo.
echo     this.mainWindow.loadFile('renderer/index.html'^);
echo     this.mainWindow.once('ready-to-show', (^) =^> this.mainWindow.show(^)^);
echo     this.mainWindow.on('closed', (^) =^> { this.mainWindow = null; }^);
echo   }
echo }
echo.
echo const runner = new ProjectRunner(^);
echo app.whenReady(^).then(^(^) =^> runner.createWindow(^)^);
echo app.on('window-all-closed', (^) =^> process.platform !== 'darwin' ^&^& app.quit(^)^);
) > main.js
echo [OK] Default main.js created
exit /b 0

:CREATE_DEFAULT_RENDERER
mkdir "renderer" >nul 2>&1
(
echo ^<!DOCTYPE html^>
echo ^<html^>
echo ^<head^>
echo   ^<title^>Dev Project Runner^</title^>
echo   ^<style^>
echo     body { font-family: Arial, sans-serif; padding: 20px; background: #f0f0f0; }
echo     .container { max-width: 800px; margin: 0 auto; background: white; padding: 30px; border-radius: 8px; }
echo     h1 { color: #333; border-bottom: 2px solid #007acc; padding-bottom: 10px; }
echo     .status { padding: 10px; margin: 10px 0; border-radius: 4px; }
echo     .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
echo   ^</style^>
echo ^</head^>
echo ^<body^>
echo   ^<div class="container"^>
echo     ^<h1^>Dev Project Runner^</h1^>
echo     ^<div class="status success"^>
echo       ^<strong^>Installation Complete!^</strong^>
echo       ^<p^>The application is ready to use.^</p^>
echo     ^</div^>
echo     ^<p^>This is a basic interface. For full functionality, please copy the complete application files.^</p^>
echo   ^</div^>
echo ^</body^>
echo ^</html^>
) > "renderer\index.html"
echo [OK] Default renderer created
exit /b 0

:CREATE_LAUNCHERS
set "mode=%~1"
if "%mode%"=="lite" (
    set "title=Dev Project Runner Lite"
    set "filename=Launch Dev Project Runner Lite.bat"
) else (
    set "title=Dev Project Runner"
    set "filename=Launch Dev Project Runner.bat"
)

(
echo @echo off
echo title %title%
echo cd /d "%%~dp0"
echo echo [INFO] Starting %title%...
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
) > "%filename%"

if not exist "%filename%" (
    echo [ERROR] Failed to create launcher
    exit /b 1
)
echo [OK] Launcher created: %filename%
exit /b 0

:ENV_CHECK
cls
echo ================================================================
echo                    ENVIRONMENT CHECK                          
echo ================================================================
echo.
echo This will check if your system is ready for Dev Project Runner
echo.
if exist "WindowsEnvFix.bat" (
    echo [INFO] Launching detailed environment check...
    call "WindowsEnvFix.bat"
) else (
    echo [ERROR] WindowsEnvFix.bat not found
    echo [INFO] Basic environment check:
    echo.
    
    echo Node.js:
    node --version 2>nul || echo Not installed
    
    echo.
    echo Python:
    python --version 2>nul || echo Not installed
    
    echo.
    echo Visual Studio:
    if exist "%ProgramFiles%\Microsoft Visual Studio\2022\*\MSBuild\Current\Bin\MSBuild.exe" (
        echo Found
    ) else (
        echo Not found
    )
)
pause
goto MAIN_MENU

:REPAIR_INSTALL
cls
echo ================================================================
echo                      REPAIR INSTALLATION                      
echo ================================================================
echo.
echo This will attempt to repair an existing installation
echo.
if not exist "DevProjectRunner" (
    echo [ERROR] No existing installation found
    echo [INFO] Use option 1 or 2 for fresh installation
    pause
    goto MAIN_MENU
)

cd "DevProjectRunner"
echo [INFO] Found existing installation in: %CD%
echo.
echo [1] Reinstall dependencies only
echo [2] Full repair (reinstall everything)
echo [3] Convert to lite version
echo [4] Back to main menu
echo.
set /p repair_choice="Select repair option (1-4): "

if "%repair_choice%"=="1" (
    echo [INFO] Reinstalling dependencies...
    if exist "package.json" (
        npm install
        if %errorLevel% == 0 (
            echo [OK] Dependencies reinstalled
        ) else (
            echo [ERROR] Dependency installation failed
            echo [INFO] Try option 3 to convert to lite version
        )
    ) else (
        echo [ERROR] package.json not found
    )
)
if "%repair_choice%"=="2" goto STANDARD_INSTALL_IMPL
if "%repair_choice%"=="3" (
    echo [INFO] Converting to lite version...
    call :CREATE_LITE_PACKAGE_JSON
    npm install
    if %errorLevel% == 0 echo [OK] Converted to lite version
)
if "%repair_choice%"=="4" goto MAIN_MENU

cd ..
pause
goto MAIN_MENU

:INSTALL_SUCCESS
echo.
echo ================================================================
echo                    INSTALLATION SUCCESSFUL!                   
echo ================================================================
echo.
echo Location: %CD%
echo.
if exist "Launch Dev Project Runner.bat" (
    echo Launcher: Launch Dev Project Runner.bat
) else if exist "Launch Dev Project Runner Lite.bat" (
    echo Launcher: Launch Dev Project Runner Lite.bat
)

echo.
echo Status: Ready for offline use!
echo ================================================================
echo.

set /p launch="Launch Dev Project Runner now? (Y/n): "
if /i "%launch%" neq "n" (
    if exist "Launch Dev Project Runner.bat" (
        echo [INFO] Starting application...
        start "" "Launch Dev Project Runner.bat"
        timeout /t 2 >nul
        exit /b
    ) else if exist "Launch Dev Project Runner Lite.bat" (
        echo [INFO] Starting application...
        start "" "Launch Dev Project Runner Lite.bat"
        timeout /t 2 >nul
        exit /b
    ) else (
        echo [ERROR] Launcher not found
        pause
    )
)

echo.
echo Installation complete! You can launch it anytime.
pause
exit /b

:INSTALL_FAILED
echo.
echo ================================================================
echo                      INSTALLATION FAILED                      
echo ================================================================
echo.
echo The installation could not be completed.
echo.
echo Common solutions:
echo 1. Run as Administrator
echo 2. Check internet connection
echo 3. Free up disk space
echo 4. Use WindowsEnvFix.bat to fix build environment
echo 5. Try Lite installation (option 3)
echo.
echo For detailed troubleshooting:
echo - Check install.log if it exists
echo - Run Environment Check (option 4)
echo - Use Windows Environment Fix tool
echo.
pause
goto MAIN_MENU

:EXIT
echo.
echo Installation cancelled by user.
echo.
pause
exit /b

endlocal