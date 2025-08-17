@echo off
echo.
echo ⚠️  DEPRECATED: This file has been replaced
echo.
echo 🎯 Please use: DevProjectRunner-Installer.bat
echo    (New unified installer with GUI options)
echo.
echo 🚀 Would you like to launch the new installer?
set /p choice="(Y/n): "
if /i "%choice%" neq "n" (
    start "" "DevProjectRunner-Installer.bat"
)
pause
exit /b

:: Set working directory to bat file location
cd /d "%~dp0"
echo 🎯 Working directory: %CD%

:: Create app directory structure
if not exist "DevProjectRunner" mkdir DevProjectRunner
cd DevProjectRunner

:: Display banner
echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    DEV PROJECT RUNNER                        ║
echo ║                  Standalone Installer                        ║
echo ║                                                              ║
echo ║  This will download and setup all required components:      ║
echo ║  • Node.js Runtime (~50MB)                                  ║
echo ║  • NPM Dependencies (~200MB)                                ║
echo ║  • Electron Framework (~150MB)                              ║
echo ║  • Build Tools (~100MB)                                     ║
echo ║                                                              ║
echo ║  Total Download: ~500MB                                     ║
echo ║  Internet connection required for first-time setup          ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

pause

:: Step 1: Download and install Node.js (if not present)
echo 🔄 Step 1/5: Checking Node.js installation...
node --version >nul 2>&1
if %errorLevel% == 0 (
    echo ✅ Node.js already installed
    node --version
) else (
    echo 📥 Downloading Node.js LTS (64-bit)...
    
    :: Download Node.js
    powershell -Command "& {
        $url = 'https://nodejs.org/dist/v18.19.0/node-v18.19.0-win-x64.zip'
        $output = 'node.zip'
        Write-Host 'Downloading Node.js...'
        Invoke-WebRequest -Uri $url -OutFile $output -UseBasicParsing
        Write-Host 'Extracting Node.js...'
        Expand-Archive -Path $output -DestinationPath 'node-temp' -Force
        Move-Item 'node-temp\node-v18.19.0-win-x64\*' '.\' -Force
        Remove-Item 'node-temp' -Recurse -Force
        Remove-Item $output -Force
        Write-Host '✅ Node.js installed successfully'
    }"
    
    :: Add to PATH temporarily
    set "PATH=%CD%;%CD%\npm;%PATH%"
)

:: Step 2: Create package.json
echo 🔄 Step 2/5: Creating package.json...
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
) > package.json

:: Step 3: Download application source files
echo 🔄 Step 3/5: Downloading application files...
powershell -Command "& {
    # Create directories
    New-Item -ItemType Directory -Force -Path 'renderer'
    New-Item -ItemType Directory -Force -Path 'assets'
    New-Item -ItemType Directory -Force -Path 'templates\react-basic\src'
    New-Item -ItemType Directory -Force -Path 'templates\react-basic\public'
    
    # Download from GitHub raw files (replace with your repo)
    $baseUrl = 'https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main'
    
    $files = @{
        'main.js' = '$baseUrl/main.js'
        'renderer/index.html' = '$baseUrl/renderer/index.html'
        'renderer/styles.css' = '$baseUrl/renderer/styles.css'
        'renderer/app.js' = '$baseUrl/renderer/app.js'
        'DevProjectRunner.html' = '$baseUrl/DevProjectRunner.html'
    }
    
    foreach ($file in $files.GetEnumerator()) {
        try {
            Write-Host 'Downloading:' $file.Key
            Invoke-WebRequest -Uri $file.Value -OutFile $file.Key -UseBasicParsing
        } catch {
            Write-Host '⚠️  Failed to download' $file.Key '- using local template'
        }
    }
    
    Write-Host '✅ Application files ready'
}"

:: Step 4: Install npm dependencies
echo 🔄 Step 4/5: Installing dependencies (~300MB)...
echo ⏳ This may take 5-10 minutes depending on your connection...

call npm install
if %errorLevel% neq 0 (
    echo ❌ Failed to install dependencies
    pause
    exit /b 1
)

echo ✅ Dependencies installed successfully

:: Step 5: Create launcher scripts
echo 🔄 Step 5/5: Creating launcher scripts...

:: Create main launcher
(
echo @echo off
echo cd /d "%%~dp0"
echo echo 🚀 Starting Dev Project Runner...
echo call npm start
echo if %%errorLevel%% neq 0 ^(
echo     echo ❌ Failed to start application
echo     pause
echo ^)
) > "Launch Dev Project Runner.bat"

:: Create update script
(
echo @echo off
echo cd /d "%%~dp0"
echo echo 🔄 Updating Dev Project Runner...
echo call npm update
echo echo ✅ Update complete
echo pause
) > "Update.bat"

:: Create uninstall script
(
echo @echo off
echo cd /d "%%~dp0"
echo echo ⚠️  This will remove all Dev Project Runner files
echo set /p confirm="Are you sure? (y/N): "
echo if /i "%%confirm%%" == "y" ^(
echo     cd ..
echo     rmdir /s /q "DevProjectRunner"
echo     echo ✅ Dev Project Runner uninstalled
echo ^) else ^(
echo     echo ❌ Uninstall cancelled
echo ^)
echo pause
) > "Uninstall.bat"

:: Step 6: Final setup
echo ✅ Installation completed successfully!
echo.
echo 📁 Installation Directory: %CD%
echo 💾 Total Size: 
dir /s /-c | find "bytes"

echo.
echo ╔══════════════════════════════════════════════════════════════╗
echo ║                    INSTALLATION COMPLETE                     ║
echo ║                                                              ║
echo ║  🚀 Launch: "Launch Dev Project Runner.bat"                 ║
echo ║  🔄 Update: "Update.bat"                                     ║
echo ║  🗑️  Remove: "Uninstall.bat"                                 ║
echo ║                                                              ║
echo ║  The application is now ready to use offline!               ║
echo ╚══════════════════════════════════════════════════════════════╝
echo.

:: Ask to launch immediately
set /p launch="Launch Dev Project Runner now? (Y/n): "
if /i "%launch%" neq "n" (
    echo 🚀 Launching application...
    start "" "Launch Dev Project Runner.bat"
) else (
    echo 👍 You can launch it later using "Launch Dev Project Runner.bat"
)

echo.
echo ✅ Setup complete! Press any key to exit...
pause >nul