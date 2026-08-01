# docker-system.ps1
# Docker engine information, disk usage, cleanup, and registry authentication.

function dVersion {
    <#
    .SYNOPSIS
    Displays the installed Docker version.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker --version
}

function dInfo {
    <#
    .SYNOPSIS
    Displays detailed Docker system information.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker info
}

function dDiskSystem {
    <#
    .SYNOPSIS
    Shows Docker disk usage (images, containers, volumes).
    #>
    if (-not (Assert-DockerCLI)) { return }
    Write-Host "📊 Docker disk usage:" -ForegroundColor Cyan
    docker system df
}

function dEvents {
    <#
    .SYNOPSIS
    Streams real-time Docker engine events (containers, images, volumes...).
    #>
    if (-not (Assert-DockerCLI)) { return }
    Write-Host "👀 Streaming Docker events (Press Ctrl + C to exit)..." -ForegroundColor Cyan
    docker system events
}

function dPruneSystem {
    <#
    .SYNOPSIS
    Removes unused Docker resources. Use -Volumes to also remove unused volumes.
    #>
    param(
        [switch]$Volumes
    )

    if (-not (Assert-DockerCLI)) { return }

    $what = "unused containers, images, networks"
    if ($Volumes) { $what += ", and volumes" }

    if (-not (Confirm-Action "This will remove $what. Continue?")) { return }

    Write-Host "🧹 Cleaning Docker system..." -ForegroundColor Cyan

    $cmd = @("system", "prune", "-a", "-f")
    if ($Volumes) { $cmd += "--volumes" }

    docker @cmd
    Show-DockerResult -Success "✅ Docker system cleaned successfully." -Failure "❌ Failed to clean Docker system."
}

function dLogin {
    <#
    .SYNOPSIS
    Authenticates to a Docker registry (default: docker.io).
    .EXAMPLE
    dLogin
    dLogin "ghcr.io"
    #>
    param(
        [string]$Registry = "docker.io"
    )

    if (-not (Assert-DockerCLI)) { return }

    $Registry = Read-Value "Enter the Docker registry (default: docker.io)" $Registry
    if ([string]::IsNullOrWhiteSpace($Registry)) { $Registry = "docker.io" }

    Write-Host "🔑 Logging in to registry '$Registry'..." -ForegroundColor Cyan

    docker login $Registry
    Show-DockerResult -Success "✅ Logged in successfully to '$Registry'." -Failure "❌ Failed to log in to '$Registry'."
}

function dLogout {
    <#
    .SYNOPSIS
    Logs out from a Docker registry (default: docker.io).
    .EXAMPLE
    dLogout
    dLogout "ghcr.io"
    #>
    param(
        [string]$Registry = "docker.io"
    )

    if (-not (Assert-DockerCLI)) { return }

    $Registry = Read-Value "Enter the Docker registry to log out from (default: docker.io)" $Registry
    if ([string]::IsNullOrWhiteSpace($Registry)) { $Registry = "docker.io" }

    Write-Host "🔓 Logging out from registry '$Registry'..." -ForegroundColor Cyan

    docker logout $Registry
    Show-DockerResult -Success "✅ Logged out successfully from '$Registry'." -Failure "❌ Failed to log out from '$Registry'."
}
