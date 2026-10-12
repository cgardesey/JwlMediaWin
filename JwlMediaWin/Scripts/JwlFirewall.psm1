<#
    Shared helper functions for blocking/checking JW Library's internet access
    via a dedicated set of Windows Firewall rules. Bundled with JwlMediaWin and
    invoked by it (see InternetBlocker.cs) to back the tray menu's internet toggle.
#>

$script:RuleBaseName = 'Block JW Library Internet'

function Get-JwlPackages {
    # Get-AppxPackage without -AllUsers often returns nothing when run elevated,
    # since the admin token resolves to a different per-user package context.
    Get-AppxPackage -AllUsers | Where-Object {
        $_.Name -like '*JWLibrary*' -or $_.Name -like '*JW.Library*' -or $_.Name -like '*Watchtower*' -or $_.Name -like '*WatchTower*'
    }
}

function Test-JwlInternetBlocked {
    [bool](Get-NetFirewallRule -DisplayName "$script:RuleBaseName*" -ErrorAction SilentlyContinue)
}

function Enable-JwlInternet {
    Get-NetFirewallRule -DisplayName "$script:RuleBaseName*" -ErrorAction SilentlyContinue | Remove-NetFirewallRule
}

function Block-JwlInternet {
    $packages = Get-JwlPackages

    if (-not $packages) {
        $allNames = (Get-AppxPackage -AllUsers | Sort-Object Name | Select-Object -ExpandProperty Name) -join "`n"
        throw "No JW Library package found. Installed packages:`n$allNames"
    }

    foreach ($pkg in $packages) {
        $ruleName = "$script:RuleBaseName - $($pkg.Name)"
        New-NetFirewallRule -DisplayName "$ruleName (Out)" -Direction Outbound -Action Block -Package $pkg.PackageFamilyName | Out-Null
        New-NetFirewallRule -DisplayName "$ruleName (In)" -Direction Inbound -Action Block -Package $pkg.PackageFamilyName | Out-Null
    }
}

Export-ModuleMember -Function Get-JwlPackages, Test-JwlInternetBlocked, Enable-JwlInternet, Block-JwlInternet
