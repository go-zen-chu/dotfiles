Write-Host "Setup for Windows..." -ForegroundColor Cyan 
$packages = @(  
    "Microsoft.PowerToys",
    "Google.Chrome",
    "Google.Drive",
    "Amazon.Kindle",
    "Synology.DriveClient",
    # communication tools
    "Zoom.Zoom",
    "LINE.LINE",
    "SlackTechnologies.Slack",
    # development tools
    "Microsoft.VisualStudioCode",
    "tailscale.tailscale",
    "Git.Git",
    "Unity.UnityHub"
)
foreach ($package in $packages) {
    winget install $package -e
}

if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    Write-Host "Installing powershell profile if not exists" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path "$PROFILE.CurrentUserAllHosts\.."
    Copy-Item "os-windows\profile.ps1" -Force -Destination "$PROFILE.CurrentUserAllHosts\.."
}

Write-Host "Setup completed" -ForegroundColor Cyan 
