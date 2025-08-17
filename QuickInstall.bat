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

cd /d "%~dp0"
if not exist "DevProjectRunner" mkdir DevProjectRunner
cd DevProjectRunner

echo Installing Dev Project Runner...
echo [████████████████████████████████████████] 0%%

:: Download Node.js portable
powershell -Command "Invoke-WebRequest -Uri 'https://nodejs.org/dist/v18.19.0/node-v18.19.0-win-x64.zip' -OutFile 'node.zip' -UseBasicParsing; Expand-Archive -Path 'node.zip' -Force; Move-Item 'node-v18.19.0-win-x64\*' '.\' -Force; Remove-Item 'node-v18.19.0-win-x64', 'node.zip' -Recurse -Force" >nul 2>&1
echo [████████                                ] 20%%

:: Create package.json with all dependencies
echo {"name":"dev-runner","version":"1.0.0","main":"main.js","scripts":{"start":"electron . --no-sandbox"},"dependencies":{"electron":"^28.0.0","chokidar":"^3.5.3","tree-kill":"^1.2.2","portfinder":"^1.0.32","extract-zip":"^2.0.1","node-pty":"^1.0.0","ws":"^8.14.2"}} > package.json
echo [████████████████                        ] 40%%

:: Install dependencies silently
call npm install --silent --no-progress >nul 2>&1
echo [████████████████████████████████        ] 80%%

:: Download app files from GitHub (replace URL with your repo)
powershell -Command "
try {
    New-Item -ItemType Directory -Force -Path 'renderer' >null
    # Add your GitHub raw URLs here
    # Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/YOUR_REPO/main/main.js' -OutFile 'main.js'
    # Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/YOUR_REPO/main/renderer/index.html' -OutFile 'renderer/index.html'
} catch { }
" >nul 2>&1

:: Create launcher
echo @echo off > "Launch.bat"
echo cd /d "%%~dp0" >> "Launch.bat"
echo call npm start >> "Launch.bat"

echo [████████████████████████████████████████] 100%%
echo.
echo ✅ Installation complete! 
echo 📁 Location: %CD%
echo 🚀 Run: Launch.bat
echo.
pause