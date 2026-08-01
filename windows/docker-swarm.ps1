# docker-swarm.ps1
# Swarm cluster and service management: init, join, leave, nodes, services,
# scaling, logs, and stacks.

function dInitSwarm {
    <#
    .SYNOPSIS
    Initializes a Docker Swarm cluster on the current machine.
    .EXAMPLE
    dInitSwarm
    dInitSwarm -AdvertiseAddr "192.168.1.10"
    #>
    param(
        [string]$AdvertiseAddr
    )

    if (-not (Assert-DockerCLI)) { return }

    $cmd = @("swarm", "init")
    if ($AdvertiseAddr) { $cmd += "--advertise-addr"; $cmd += $AdvertiseAddr }

    Write-Host "🚀 Initializing Docker Swarm cluster..." -ForegroundColor Cyan

    docker @cmd
    Show-DockerResult -Success "✅ Docker Swarm initialized successfully!" -Failure "❌ Failed to initialize Docker Swarm."
}

function dJoinSwarm {
    <#
    .SYNOPSIS
    Joins an existing Swarm cluster as a worker or manager node.
    .EXAMPLE
    dJoinSwarm -JoinToken "<token>" -ManagerIP "192.168.1.10:2377"
    #>
    param(
        [string]$JoinToken,
        [string]$ManagerIP
    )

    if (-not (Assert-DockerCLI)) { return }

    $JoinToken = Read-Value "Enter the join token for the Swarm cluster" $JoinToken
    $ManagerIP = Read-Value "Enter the manager IP:Port (e.g., 192.168.1.10:2377)" $ManagerIP

    if ([string]::IsNullOrWhiteSpace($JoinToken) -or [string]::IsNullOrWhiteSpace($ManagerIP)) {
        Write-Host "❌ Missing join token or manager address." -ForegroundColor Red
        return
    }

    Write-Host "🌐 Joining Docker Swarm cluster..." -ForegroundColor Cyan

    docker swarm join --token $JoinToken $ManagerIP
    Show-DockerResult -Success "✅ Successfully joined Docker Swarm cluster!" -Failure "❌ Failed to join Docker Swarm cluster."
}

function dLeaveSwarm {
    <#
    .SYNOPSIS
    Leaves the Docker Swarm cluster. Use -Force to leave even as a manager.
    #>
    param(
        [switch]$Force
    )

    if (-not (Assert-DockerCLI)) { return }

    if (-not (Confirm-Action "Leave the Docker Swarm cluster?")) { return }

    $cmd = @("swarm", "leave")
    if ($Force) { $cmd += "--force" }

    docker @cmd
    Show-DockerResult -Success "✅ Left the Docker Swarm cluster." -Failure "❌ Failed to leave the Docker Swarm cluster."
}

function dSwarmToken {
    <#
    .SYNOPSIS
    Shows the join token for workers or managers (default: manager).
    .EXAMPLE
    dSwarmToken
    dSwarmToken -Role "worker"
    #>
    param(
        [ValidateSet("manager", "worker")]
        [string]$Role = "manager"
    )

    if (-not (Assert-DockerCLI)) { return }

    Write-Host "🔑 Swarm $Role join token:" -ForegroundColor Cyan

    docker swarm join-token $Role
}

function dNodes {
    <#
    .SYNOPSIS
    Lists all nodes in the Docker Swarm cluster.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker node ls
}

function dServices {
    <#
    .SYNOPSIS
    Lists all Docker Swarm services.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker service ls
}

function dCreateService {
    <#
    .SYNOPSIS
    Creates a new Docker Swarm service.
    .EXAMPLE
    dCreateService -ServiceName "web" -Image "nginx:latest" -Replicas 3 -Port "8080:80"
    #>
    param(
        [string]$ServiceName,
        [string]$Image = "nginx",
        [int]$Replicas,
        [string]$Port
    )

    if (-not (Assert-DockerCLI)) { return }

    $ServiceName = Read-Value "Enter the service name" $ServiceName
    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "❌ Service name is required." -ForegroundColor Red
        return
    }

    $cmd = @("service", "create", "--name", $ServiceName)
    if ($Replicas -gt 0) { $cmd += "--replicas"; $cmd += "$Replicas" }
    if ($Port) { $cmd += "-p"; $cmd += $Port }
    $cmd += $Image

    Write-Host "🚀 Creating Swarm service '$ServiceName' using image '$Image'..." -ForegroundColor Cyan

    docker @cmd
    Show-DockerResult -Success "✅ Service '$ServiceName' created successfully!" -Failure "❌ Failed to create service '$ServiceName'."
}

function dRemoveService {
    <#
    .SYNOPSIS
    Removes a Docker Swarm service from the cluster.
    #>
    param(
        [string]$ServiceName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ServiceName = Resolve-ServiceName $ServiceName
    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "❌ Service name is required." -ForegroundColor Red
        return
    }

    if (-not (Test-ServiceExists $ServiceName)) {
        Write-Host "❌ Service '$ServiceName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🗑️ Removing service '$ServiceName'..." -ForegroundColor Yellow

    docker service rm $ServiceName
    Show-DockerResult -Success "✅ Service '$ServiceName' removed successfully!" -Failure "❌ Failed to remove service '$ServiceName'."
}

function dScaleService {
    <#
    .SYNOPSIS
    Scales a Swarm service to a given number of replicas.
    .EXAMPLE
    dScaleService -ServiceName "web" -Replicas 5
    #>
    param(
        [string]$ServiceName,
        [int]$Replicas = 1
    )

    if (-not (Assert-DockerCLI)) { return }

    $ServiceName = Resolve-ServiceName $ServiceName
    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "❌ Service name is required." -ForegroundColor Red
        return
    }

    if (-not (Test-ServiceExists $ServiceName)) {
        Write-Host "❌ Service '$ServiceName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🔢 Scaling service '$ServiceName' to $Replicas replicas..." -ForegroundColor Cyan

    docker service scale "$ServiceName=$Replicas"
    Show-DockerResult -Success "✅ Service '$ServiceName' scaled to $Replicas replicas!" -Failure "❌ Failed to scale service '$ServiceName'."
}

function dServiceLogs {
    <#
    .SYNOPSIS
    Shows the logs of a Swarm service. Use -Follow to stream.
    .EXAMPLE
    dServiceLogs -ServiceName "web" -Follow
    #>
    param(
        [string]$ServiceName,
        [switch]$Follow
    )

    if (-not (Assert-DockerCLI)) { return }

    $ServiceName = Resolve-ServiceName $ServiceName
    if ([string]::IsNullOrWhiteSpace($ServiceName)) {
        Write-Host "❌ Service name is required." -ForegroundColor Red
        return
    }

    Write-Host "📝 Showing logs for service '$ServiceName'..." -ForegroundColor Cyan

    $cmd = @("service", "logs")
    if ($Follow) { $cmd += "-f" }
    $cmd += $ServiceName

    docker @cmd
}

function dStackDeploy {
    <#
    .SYNOPSIS
    Deploys a Docker stack from a compose file in Swarm mode.
    .EXAMPLE
    dStackDeploy -StackName "mystack" -ComposeFile "docker-compose.yml"
    #>
    param(
        [string]$StackName,
        [string]$ComposeFile = "docker-compose.yml"
    )

    if (-not (Assert-DockerCLI)) { return }

    $StackName = Read-Value "Enter the stack name" $StackName
    if ([string]::IsNullOrWhiteSpace($StackName)) {
        Write-Host "❌ Stack name is required." -ForegroundColor Red
        return
    }

    if (-not (Test-Path $ComposeFile -PathType Leaf)) {
        Write-Host "❌ Compose file '$ComposeFile' not found." -ForegroundColor Red
        return
    }

    Write-Host "🚀 Deploying stack '$StackName' using '$ComposeFile'..." -ForegroundColor Cyan

    docker stack deploy -c $ComposeFile $StackName
    Show-DockerResult -Success "✅ Stack '$StackName' deployed successfully!" -Failure "❌ Failed to deploy stack '$StackName'."
}

function dStacks {
    <#
    .SYNOPSIS
    Lists all deployed Docker stacks.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker stack ls
}

function dStackRemove {
    <#
    .SYNOPSIS
    Removes a deployed Docker stack.
    #>
    param(
        [string]$StackName
    )

    if (-not (Assert-DockerCLI)) { return }

    $StackName = Read-Value "Enter the stack name to remove" $StackName
    if ([string]::IsNullOrWhiteSpace($StackName)) {
        Write-Host "❌ Stack name is required." -ForegroundColor Red
        return
    }

    Write-Host "🗑️ Removing stack '$StackName'..." -ForegroundColor Yellow

    docker stack rm $StackName
    Show-DockerResult -Success "✅ Stack '$StackName' removed successfully!" -Failure "❌ Failed to remove stack '$StackName'."
}

function dSwarmDocs {
    <#
    .SYNOPSIS
    Shows a reference table of all Swarm-related commands.
    #>
    $commands = @(
        @{Command="dInitSwarm [advertiseAddr]"; Description="Initialize a Docker Swarm cluster"},
        @{Command="dJoinSwarm [token] [managerIP]"; Description="Join a Swarm cluster"},
        @{Command="dLeaveSwarm [-Force]"; Description="Leave the Swarm cluster"},
        @{Command="dSwarmToken [role]"; Description="Show the manager/worker join token"},
        @{Command="dNodes"; Description="List all Swarm nodes"},
        @{Command="dServices"; Description="List all Swarm services"},
        @{Command="dCreateService [name] [image]"; Description="Create a Swarm service"},
        @{Command="dRemoveService [name]"; Description="Remove a Swarm service"},
        @{Command="dScaleService [name] [replicas]"; Description="Scale a Swarm service"},
        @{Command="dServiceLogs [name] [-Follow]"; Description="Show a service's logs"},
        @{Command="dStackDeploy [stackName] [composeFile]"; Description="Deploy a stack from a compose file"},
        @{Command="dStacks"; Description="List all deployed stacks"},
        @{Command="dStackRemove [stackName]"; Description="Remove a deployed stack"}
    )

    Show-DocTable -Commands $commands -Title "🐳 Docker Swarm Commands"
}
