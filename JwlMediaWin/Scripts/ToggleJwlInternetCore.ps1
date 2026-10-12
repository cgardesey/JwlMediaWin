<#
    Entry point invoked by JwlMediaWin's InternetBlocker.cs.
    -Action Status : prints "Blocked" or "Enabled" to stdout (non-elevated, read-only).
    -Action Block  : adds the firewall rules (requires elevation). Exit code 0 = success.
    -Action Enable : removes the firewall rules (requires elevation). Exit code 0 = success.
#>

param(
    [ValidateSet('Status', 'Block', 'Enable')]
    [string]$Action = 'Status'
)

$ErrorActionPreference = 'Stop'
Import-Module "$PSScriptRoot\JwlFirewall.psm1" -Force

switch ($Action) {
    'Status' {
        if (Test-JwlInternetBlocked) { Write-Output 'Blocked' } else { Write-Output 'Enabled' }
    }
    'Block' {
        try {
            Block-JwlInternet
            exit 0
        }
        catch {
            Write-Error $_
            exit 1
        }
    }
    'Enable' {
        try {
            Enable-JwlInternet
            exit 0
        }
        catch {
            Write-Error $_
            exit 1
        }
    }
}
