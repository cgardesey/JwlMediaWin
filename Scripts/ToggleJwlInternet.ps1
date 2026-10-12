<#
    Toggles outbound/inbound internet access for the JW Library app(s) via Windows Firewall.
    Leaves all other apps (Zoom, browsers, etc.) completely unaffected.
    Run via ToggleJwlInternet.bat, which handles elevation.
#>

$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot\JwlFirewall.psm1" -Force

if (Test-JwlInternetBlocked) {
    Write-Host "Currently BLOCKED. Removing firewall rule(s)..." -ForegroundColor Cyan
    Enable-JwlInternet
    $Host.UI.RawUI.WindowTitle = "JW Library Internet: ENABLED"
    Write-Host "================================================" -ForegroundColor Green
    Write-Host " NEW STATE: JW Library internet ENABLED (normal)" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
}
else {
    Write-Host "Currently ENABLED. Adding firewall rule(s)..." -ForegroundColor Cyan
    try {
        Block-JwlInternet
    }
    catch {
        Write-Host $_.Exception.Message -ForegroundColor Yellow
        exit 1
    }
    $Host.UI.RawUI.WindowTitle = "JW Library Internet: BLOCKED"
    Write-Host "================================================" -ForegroundColor Red
    Write-Host " NEW STATE: JW Library internet BLOCKED" -ForegroundColor Red
    Write-Host " (Zoom and other apps are unaffected)" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
}
