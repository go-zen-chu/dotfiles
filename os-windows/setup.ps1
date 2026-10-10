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
    # run without prompts (agreements, installer UI)
    winget install --id $package -e --silent --disable-interactivity --accept-package-agreements --accept-source-agreements
}

if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    Write-Host "Installing powershell profile if not exists" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PROFILE.CurrentUserAllHosts) | Out-Null
    Copy-Item "os-windows\profile.ps1" -Force -Destination $PROFILE.CurrentUserAllHosts
}

Write-Host "Setup completed" -ForegroundColor Cyan 
