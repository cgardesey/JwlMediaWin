@echo off
setlocal

:: Toggles JW Library's internet access on/off (does not affect Zoom or anything else).
:: Run this file any time before/during a meeting to switch it on or off.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Administrator rights are required - requesting elevation...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0ToggleJwlInternet.ps1"

echo.
pause
