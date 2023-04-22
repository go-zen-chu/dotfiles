Write-Host "Setup for Windows..." -ForegroundColor Cyan 
$packages = @(  
    # install basic tools
    "Google.Chrome",
    "Google.Drive",
    "Microsoft.PowerToys",
    # communication tools
    "Zoom.Zoom",
    "LINE.LINE",
    "Mozilla.Thunderbird",
    "SlackTechnologies.Slack",
    # other tools
    "Synology.DriveClient",
    "Wondershare.Filmora",
    "Doist.Todoist",
    # get dnssd.dll not found error because of lack of Bonjour
    #"Apple.iTunes",
    # development tools
    "Microsoft.VisualStudioCode"
)
foreach ($package in $packages) {
    winget install $package -e
}

Write-Host "Setup completed" -ForegroundColor Cyan 
