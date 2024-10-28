Write-Host "Setup for Windows..." -ForegroundColor Cyan 
$packages = @(  
    # install basic tools
    "Google.Drive",
    # input system
    "Google.JapaneseIME",
    "AutoHotkey.AutoHotkey",
    "Microsoft.PowerToys",
    # communication tools
    "Zoom.Zoom",
    "LINE.LINE",
    "SlackTechnologies.Slack",
    # other tools
    "Synology.DriveClient",
    # get dnssd.dll not found error because of lack of Bonjour
    #"Apple.iTunes",
    # development tools
    "Microsoft.VisualStudioCode",
    "tailscale.tailscale",
    "PostgreSQL.pgAdmin"
)
foreach ($package in $packages) {
    winget install $package -e
}

if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    Write-Host "Installing powershell profile if not exists" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$PROFILE.CurrentUserAllHosts\.."
    Copy-Item "os-windows\profile.ps1" -Force -Destination "$PROFILE.CurrentUserAllHosts\.."
}

$UserProperty = $(Get-ItemProperty 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\User Shell Folders')
if (Test-Path -Path $UserProperty.Startup) {
    Write-Host "Installing autohotkey script to startup" -ForegroundColor Cyan 
    Copy-Item "os-windows\keybind.ahk" -Force -Destination $UserProperty.Startup
}

Write-Host "Setup completed" -ForegroundColor Cyan 
