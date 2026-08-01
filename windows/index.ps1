# index.ps1
# Docker Command Aliases - main entry point.
#
# Add the following line to your PowerShell profile to load the toolkit:
#   . "$HOME\.config\alias\docker-commandes\windows\index.ps1"

$ModuleDir = $PSScriptRoot

$Files = @(
    "docker-helpers.ps1",
    "docker-system.ps1",
    "docker-images.ps1",
    "docker-containers.ps1",
    "docker-compose.ps1",
    "docker-volumes.ps1",
    "docker-networks.ps1",
    "docker-swarm.ps1",
    "docker-docs.ps1",
    "docker-aliases.ps1"
)

foreach ($File in $Files) {
    $Path = Join-Path $ModuleDir $File
    if (Test-Path $Path) {
        . $Path
    } else {
        Write-Warning "Docker alias module not found: $Path"
    }
}
