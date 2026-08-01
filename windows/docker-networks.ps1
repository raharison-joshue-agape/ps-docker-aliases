# docker-networks.ps1
# Container networking: list, create, inspect, connect, disconnect, remove, and prune networks.

function dNetworks {
    <#
    .SYNOPSIS
    Lists all Docker networks.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker network ls
}

function dCreateNetwork {
    <#
    .SYNOPSIS
    Creates a new Docker network.
    .EXAMPLE
    dCreateNetwork -NetworkName "my-network" -Driver "bridge" -Subnet "172.20.0.0/16"
    #>
    param(
        [string]$NetworkName,
        [string]$Driver,
        [string]$Subnet
    )

    if (-not (Assert-DockerCLI)) { return }

    $NetworkName = Read-Value "Enter the name for the new Docker network" $NetworkName
    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "❌ No network name provided." -ForegroundColor Red
        return
    }

    $cmd = @("network", "create")
    if ($Driver) { $cmd += "--driver"; $cmd += $Driver }
    if ($Subnet) { $cmd += "--subnet"; $cmd += $Subnet }
    $cmd += $NetworkName

    Write-Host "🌐 Creating network '$NetworkName'..." -ForegroundColor Cyan

    docker @cmd
    Show-DockerResult -Success "✅ Network '$NetworkName' created successfully!" -Failure "❌ Failed to create network '$NetworkName'."
}

function dInspectNetwork {
    <#
    .SYNOPSIS
    Shows detailed information about a Docker network.
    #>
    param(
        [string]$NetworkName
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the name of the network to inspect"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "❌ No network name provided." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting network '$NetworkName'..." -ForegroundColor Cyan

    docker network inspect $NetworkName
}

function dConnectNetwork {
    <#
    .SYNOPSIS
    Connects a running container to a Docker network.
    .EXAMPLE
    dConnectNetwork -NetworkName "my-net" -ContainerName "api"
    #>
    param(
        [string]$NetworkName,
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the network name to connect"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Running containers:" -ForegroundColor Cyan
        docker ps --format "table {{.Names}}\t{{.Status}}"
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to connect"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName) -or [string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ Network or container name is missing." -ForegroundColor Red
        return
    }

    if (-not (Test-NetworkExists $NetworkName)) {
        Write-Host "❌ Network '$NetworkName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🔗 Connecting '$ContainerName' to network '$NetworkName'..." -ForegroundColor Cyan

    docker network connect $NetworkName $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' connected to '$NetworkName'." -Failure "❌ Failed to connect container '$ContainerName' to '$NetworkName'."
}

function dDisconnectNetwork {
    <#
    .SYNOPSIS
    Disconnects a container from a Docker network.
    .EXAMPLE
    dDisconnectNetwork -NetworkName "my-net" -ContainerName "api"
    #>
    param(
        [string]$NetworkName,
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the network name to disconnect"
    }

    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "📦 Connected containers:" -ForegroundColor Cyan
        docker network inspect $NetworkName --format '{{range .Containers}}{{.Name}} {{end}}' 2>$null
        Write-Host ""
        $ContainerName = Read-Host "Enter the container name or ID to disconnect"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName) -or [string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ Network or container name is missing." -ForegroundColor Red
        return
    }

    if (-not (Test-NetworkExists $NetworkName)) {
        Write-Host "❌ Network '$NetworkName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🔌 Disconnecting '$ContainerName' from '$NetworkName'..." -ForegroundColor Yellow

    docker network disconnect $NetworkName $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' disconnected from '$NetworkName'." -Failure "❌ Failed to disconnect container '$ContainerName'."
}

function dRemoveNetwork {
    <#
    .SYNOPSIS
    Removes a Docker network.
    .EXAMPLE
    dRemoveNetwork -NetworkName "my-net"
    #>
    param(
        [string]$NetworkName
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "📦 Available networks:" -ForegroundColor Cyan
        docker network ls
        Write-Host ""
        $NetworkName = Read-Host "Enter the network name to remove"
    }

    if ([string]::IsNullOrWhiteSpace($NetworkName)) {
        Write-Host "❌ No network name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-NetworkExists $NetworkName)) {
        Write-Host "❌ Network '$NetworkName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🗑️ Removing network '$NetworkName'..." -ForegroundColor Yellow

    docker network rm $NetworkName
    Show-DockerResult -Success "✅ Network '$NetworkName' removed successfully!" -Failure "❌ Failed to remove network '$NetworkName'."
}

function dPruneNetwork {
    <#
    .SYNOPSIS
    Removes all unused Docker networks. Use -Force to skip confirmation.
    #>
    param(
        [switch]$Force
    )

    if (-not (Assert-DockerCLI)) { return }

    if (-not $Force -and -not (Confirm-Action "This will remove all unused Docker networks. Continue?")) { return }

    Write-Host "🧹 Pruning unused Docker networks..." -ForegroundColor Cyan

    docker network prune -f
    Show-DockerResult -Success "✅ Unused Docker networks removed successfully!" -Failure "❌ Failed to prune Docker networks."
}

function dNetworkDocs {
    <#
    .SYNOPSIS
    Shows a reference table of all network-related commands.
    #>
    $commands = @(
        @{Command="dNetworks"; Description="List all Docker networks"},
        @{Command="dCreateNetwork [name] [driver] [subnet]"; Description="Create a new Docker network"},
        @{Command="dInspectNetwork [name]"; Description="Inspect a Docker network"},
        @{Command="dConnectNetwork [network] [container]"; Description="Connect a container to a network"},
        @{Command="dDisconnectNetwork [network] [container]"; Description="Disconnect a container from a network"},
        @{Command="dRemoveNetwork [name]"; Description="Remove a Docker network"},
        @{Command="dPruneNetwork [-Force]"; Description="Remove all unused Docker networks"}
    )

    Show-DocTable -Commands $commands -Title "🐳 Docker Network Commands"
}
