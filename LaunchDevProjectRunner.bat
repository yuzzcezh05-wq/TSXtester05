@echo off
title Dev Project Runner
cd /d "%~dp0"

echo.
echo ⚡ Starting Dev Project Runner...
echo 📁 Working directory: %CD%
echo.

:: Check if this is a development environment
if exist "main.js" (
    echo [INFO] Development environment detected
    echo [INFO] Starting Electron application...
    
    :: Check if Node.js and npm are available
    node --version >nul 2>&1
    if %errorLevel% neq 0 (
        echo [ERROR] Node.js not found in PATH
        echo [INFO] Please install Node.js or run the installer first
        pause
        exit /b 1
    )
    
    :: Check if node_modules exists
    if not exist "node_modules" (
        echo [WARNING] Dependencies not installed
        echo [INFO] Installing dependencies first...
        call npm install
        if %errorLevel% neq 0 (
            echo [ERROR] Failed to install dependencies
            pause
            exit /b 1
        )
    )
    
    :: Start the Electron application
    echo [INFO] Launching application...
    call npm start
    
) else if exist "DevProjectRunner\main.js" (
    echo [INFO] Installed environment detected
    cd DevProjectRunner
    echo [INFO] Starting from: %CD%
    
    :: Try to start with local Node.js first
    if exist "node.exe" (
        echo [INFO] Using local Node.js...
        call npm start
    ) else (
        echo [INFO] Using system Node.js...
        call npm start
    )
    
) else (
    echo [ERROR] Dev Project Runner not found
    echo [INFO] Please run the installer first:
    echo        - DevProjectRunner-Installer-Enhanced.bat
    echo        - WindowsEnvFix.bat (if build issues)
    echo.
    pause
    exit /b 1
)

:: Check if the application started successfully
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] Application failed to start
    echo [TROUBLESHOOTING]
    echo 1. Check if all dependencies are installed
    echo 2. Try running: npm install
    echo 3. Check for error messages above
    echo 4. Run WindowsEnvFix.bat if build errors occur
    echo.
    pause
) else (
    echo.
    echo [INFO] Application closed normally
)