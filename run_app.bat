@echo off
setlocal
cd /d "%~dp0"

echo ==========================================
echo   Coinmoney Flutter App Launcher
echo ==========================================
echo.

where flutter >nul 2>nul
if %errorlevel%==0 (
    set "FLUTTER_CMD=flutter"
    goto :run
)

if exist "%USERPROFILE%\develop\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=%USERPROFILE%\develop\flutter\bin\flutter.bat"
    goto :run
)
if exist "C:\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=C:\flutter\bin\flutter.bat"
    goto :run
)
if exist "C:\src\flutter\bin\flutter.bat" (
    set "FLUTTER_CMD=C:\src\flutter\bin\flutter.bat"
    goto :run
)

echo [!] Flutter SDK not found in PATH or standard folders.
echo Install Flutter or add flutter\bin to PATH, then re-run this script.
pause
exit /b 1

:run
echo Using Flutter: %FLUTTER_CMD%
echo Running flutter pub get...
call "%FLUTTER_CMD%" pub get
if %errorlevel% neq 0 (
    echo [!] flutter pub get failed.
    pause
    exit /b 1
)

echo Starting Coinmoney in Chrome...
call "%FLUTTER_CMD%" run -d chrome
pause
