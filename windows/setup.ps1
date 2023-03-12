Write-Host -ForgroundColor Cyan 'Setup for Windows...'
# install basic tools
winget install Google.Chrome
winget install Google.Drive
winget install Microsoft.PowerToys
# communication tools
winget install Zoom.Zoom
winget install LINE.LINE
winget install Mozilla.Thunderbird
# other tools
winget install Wondershare.Filmora
winget install Doist.Todoist
# get dnssd.dll not found error because of lack of Bonjour
#winget install Apple.iTunes

# development tools
winget install Microsoft.VisualStudioCode

Write-Host -ForgroundColor Cyan 'Setup completed'
