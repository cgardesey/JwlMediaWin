<#
    System tray icon for toggling JW Library's internet access on/off.
    Green icon = internet ENABLED (normal). Red icon = BLOCKED (cached media plays instantly).
    Left double-click the icon, or use the right-click menu, to toggle.
    Self-elevates on launch since firewall rules require admin rights.
    Intended to be started via JwlInternetTray.vbs (silent, no console window).
#>

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
if (-not $isAdmin) {
    Start-Process -FilePath 'powershell.exe' -ArgumentList @(
        '-NoProfile', '-WindowStyle', 'Hidden', '-ExecutionPolicy', 'Bypass', '-File', "`"$PSCommandPath`""
    ) -Verb RunAs
    exit
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Import-Module "$PSScriptRoot\JwlFirewall.psm1" -Force

function New-StatusIcon([System.Drawing.Color]$color) {
    $bmp = New-Object System.Drawing.Bitmap 32, 32
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.Clear([System.Drawing.Color]::Transparent)
    $brush = New-Object System.Drawing.SolidBrush $color
    $g.FillEllipse($brush, 2, 2, 28, 28)
    $pen = New-Object System.Drawing.Pen ([System.Drawing.Color]::Black), 2
    $g.DrawEllipse($pen, 2, 2, 28, 28)
    $g.Dispose()
    [System.Drawing.Icon]::FromHandle($bmp.GetHicon())
}

$greenIcon = New-StatusIcon ([System.Drawing.Color]::LimeGreen)
$redIcon = New-StatusIcon ([System.Drawing.Color]::Red)

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Visible = $true

$menu = New-Object System.Windows.Forms.ContextMenuStrip
$statusItem = $menu.Items.Add('Status: checking...')
$statusItem.Enabled = $false
[void]$menu.Items.Add('-')
$toggleItem = $menu.Items.Add('Toggle')
[void]$menu.Items.Add('-')
$exitItem = $menu.Items.Add('Exit')
$notifyIcon.ContextMenuStrip = $menu

function Update-TrayState {
    try {
        $blocked = Test-JwlInternetBlocked
    }
    catch {
        $notifyIcon.Text = 'JW Library Internet: unknown'
        $statusItem.Text = 'Status: error reading firewall'
        return
    }

    if ($blocked) {
        $notifyIcon.Icon = $redIcon
        $notifyIcon.Text = 'JW Library Internet: BLOCKED'
        $statusItem.Text = 'Status: BLOCKED'
        $toggleItem.Text = 'Enable Internet'
    }
    else {
        $notifyIcon.Icon = $greenIcon
        $notifyIcon.Text = 'JW Library Internet: ENABLED'
        $statusItem.Text = 'Status: ENABLED (normal)'
        $toggleItem.Text = 'Block Internet'
    }
}

$toggleItem.Add_Click({
    try {
        if (Test-JwlInternetBlocked) {
            Enable-JwlInternet
            $notifyIcon.ShowBalloonTip(3000, 'JW Library Internet', 'Internet access ENABLED.', [System.Windows.Forms.ToolTipIcon]::Info)
        }
        else {
            Block-JwlInternet
            $notifyIcon.ShowBalloonTip(3000, 'JW Library Internet', 'Internet access BLOCKED. Zoom and other apps are unaffected.', [System.Windows.Forms.ToolTipIcon]::Info)
        }
    }
    catch {
        $notifyIcon.ShowBalloonTip(5000, 'JW Library Internet', "Error: $($_.Exception.Message)", [System.Windows.Forms.ToolTipIcon]::Error)
    }
    Update-TrayState
})

$notifyIcon.Add_MouseDoubleClick({
    param($s, $e)
    if ($e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
        $toggleItem.PerformClick()
    }
})

$exitItem.Add_Click({
    $notifyIcon.Visible = $false
    [System.Windows.Forms.Application]::Exit()
})

# keeps the tray in sync if ToggleJwlInternet.bat is also used while the tray is running
$timer = New-Object System.Windows.Forms.Timer
$timer.Interval = 5000
$timer.Add_Tick({ Update-TrayState })
$timer.Start()

Update-TrayState

[System.Windows.Forms.Application]::Run()
