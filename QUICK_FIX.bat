@echo off
echo.
echo ===============================================
echo   🚨 QUICK FIX: File Browser Button Issue
echo ===============================================
echo.
echo PROBLEM: You're seeing the launcher, not the main app!
echo SOLUTION: Run the actual Electron application
echo.
echo ⚡ STEP 1: Install Dependencies (if needed)
echo -------------------------------------------
npm install

echo.
echo ⚡ STEP 2: Launch the Main Application  
echo -------------------------------------------
echo Starting Dev Project Runner Electron App...
echo.

npm start

if %errorLevel% neq 0 (
    echo.
    echo ❌ Failed to start! Try these solutions:
    echo.
    echo 1. Install Node.js if not installed
    echo 2. Run: WindowsEnvFix.bat (for build issues)
    echo 3. Run: DevProjectRunner-Installer-Enhanced.bat
    echo.
    pause
) else (
    echo.
    echo ✅ Application started successfully!
    echo 📱 You should now see the main interface with File Browser
    echo.
)