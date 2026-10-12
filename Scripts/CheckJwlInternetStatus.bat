@echo off
:: Read-only: shows whether JW Library's internet access is currently
:: BLOCKED or ENABLED. Does not change anything, no admin prompt needed.

powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0CheckJwlInternetStatus.ps1"

echo.
pause
