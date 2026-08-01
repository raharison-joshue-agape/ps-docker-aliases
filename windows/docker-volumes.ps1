# docker-volumes.ps1
# Persistent storage management: list, create, inspect, remove, and prune volumes.

function dVolumes {
    <#
    .SYNOPSIS
    Lists all Docker volumes.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker volume ls
}

function dCreateVolume {
    <#
    .SYNOPSIS
    Creates a new Docker volume.
    .EXAMPLE
    dCreateVolume -VolumeName "my-volume"
    #>
    param(
        [string]$VolumeName
    )

    if (-not (Assert-DockerCLI)) { return }

    $VolumeName = Read-Value "Enter the name for the new Docker volume" $VolumeName
    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "❌ No volume name provided." -ForegroundColor Red
        return
    }

    Write-Host "📦 Creating volume '$VolumeName'..." -ForegroundColor Cyan

    docker volume create $VolumeName
    Show-DockerResult -Success "✅ Volume '$VolumeName' created successfully!" -Failure "❌ Failed to create volume '$VolumeName'."
}

function dInspectVolume {
    <#
    .SYNOPSIS
    Shows detailed information about a Docker volume.
    .EXAMPLE
    dInspectVolume -VolumeName "my-volume"
    #>
    param(
        [string]$VolumeName
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "📦 Available volumes:" -ForegroundColor Cyan
        docker volume ls
        Write-Host ""
        $VolumeName = Read-Host "Enter the name of the volume to inspect"
    }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "❌ No volume name provided." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting volume '$VolumeName'..." -ForegroundColor Cyan

    docker volume inspect $VolumeName
}

function dRemoveVolume {
    <#
    .SYNOPSIS
    Removes a Docker volume. Use -Force to skip confirmation.
    .EXAMPLE
    dRemoveVolume -VolumeName "my-volume" -Force
    #>
    param(
        [string]$VolumeName,
        [switch]$Force
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "📦 Available volumes:" -ForegroundColor Cyan
        docker volume ls
        Write-Host ""
        $VolumeName = Read-Host "Enter the name of the volume to remove"
    }

    if ([string]::IsNullOrWhiteSpace($VolumeName)) {
        Write-Host "❌ No volume name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-VolumeExists $VolumeName)) {
        Write-Host "❌ Volume '$VolumeName' not found." -ForegroundColor Red
        return
    }

    if (-not $Force -and -not (Confirm-Action "You are about to remove volume '$VolumeName'. Continue?")) {
        return
    }

    Write-Host "🗑️ Removing volume '$VolumeName'..." -ForegroundColor Yellow

    docker volume rm $VolumeName
    Show-DockerResult -Success "✅ Volume removed successfully!" -Failure "❌ Failed to remove volume '$VolumeName'."
}

function dPruneVolume {
    <#
    .SYNOPSIS
    Removes all unused Docker volumes. Use -Force to skip confirmation.
    #>
    param(
        [switch]$Force
    )

    if (-not (Assert-DockerCLI)) { return }

    if (-not $Force -and -not (Confirm-Action "This will remove all unused Docker volumes. Continue?")) { return }

    Write-Host "🧹 Removing unused Docker volumes..." -ForegroundColor Cyan

    docker volume prune -f
    Show-DockerResult -Success "✅ Unused Docker volumes removed successfully!" -Failure "❌ Failed to prune Docker volumes."
}

function dVolumeDocs {
    <#
    .SYNOPSIS
    Shows a reference table of all volume-related commands.
    #>
    $commands = @(
        @{Command="dVolumes"; Description="List all Docker volumes"},
        @{Command="dCreateVolume [name]"; Description="Create a new Docker volume"},
        @{Command="dInspectVolume [name]"; Description="Inspect a Docker volume"},
        @{Command="dRemoveVolume [name] [-Force]"; Description="Remove a Docker volume"},
        @{Command="dPruneVolume [-Force]"; Description="Remove all unused Docker volumes"}
    )

    Show-DocTable -Commands $commands -Title "🐳 Docker Volume Commands"
}
