<#
    Read-only check: reports whether JW Library's internet access is currently
    BLOCKED or ENABLED. Does not change anything. No elevation required.
#>

Import-Module "$PSScriptRoot\JwlFirewall.psm1" -Force

try {
    $blocked = Test-JwlInternetBlocked
}
catch {
    Write-Host "Could not read firewall rules (try running as Administrator)." -ForegroundColor Yellow
    exit 1
}

if ($blocked) {
    $Host.UI.RawUI.WindowTitle = "JW Library Internet: BLOCKED"
    Write-Host "================================================" -ForegroundColor Red
    Write-Host " CURRENT STATE: JW Library internet BLOCKED" -ForegroundColor Red
    Write-Host "================================================" -ForegroundColor Red
}
else {
    $Host.UI.RawUI.WindowTitle = "JW Library Internet: ENABLED"
    Write-Host "================================================" -ForegroundColor Green
    Write-Host " CURRENT STATE: JW Library internet ENABLED (normal)" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Green
}
