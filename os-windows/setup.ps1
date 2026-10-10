param(
    # skip installing packages with winget (GitHub-hosted Windows runners do not have winget)
    [switch]$SkipPackages
)

Write-Host "Setup for Windows..." -ForegroundColor Cyan
$packages = Get-Content (Join-Path $PSScriptRoot "winget-packages.txt") |
    ForEach-Object { $_.Trim() } |
    Where-Object { $_ -and -not $_.StartsWith("#") }
if ($SkipPackages) {
    Write-Host "Skip installing packages: $($packages -join ', ')" -ForegroundColor Yellow
} else {
    foreach ($package in $packages) {
        # run without prompts (agreements, installer UI)
        winget install --id $package -e --silent --disable-interactivity --accept-package-agreements --accept-source-agreements
    }
}

if (!(Test-Path -Path $PROFILE.CurrentUserAllHosts)) {
    Write-Host "Installing powershell profile if not exists" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $PROFILE.CurrentUserAllHosts) | Out-Null
    Copy-Item (Join-Path $PSScriptRoot "profile.ps1") -Force -Destination $PROFILE.CurrentUserAllHosts
}

Write-Host "Setup completed" -ForegroundColor Cyan
