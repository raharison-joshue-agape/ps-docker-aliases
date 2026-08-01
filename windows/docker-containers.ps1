# docker-containers.ps1
# Container lifecycle management: create, run, start, stop, restart, kill,
# remove, logs, exec, attach, inspect, and file transfer between host/container.

function dContainers {
    <#
    .SYNOPSIS
    Lists Docker containers (running by default, all with -All).
    .EXAMPLE
    dContainers
    dContainers -All
    #>
    param(
        [switch]$All
    )

    if (-not (Assert-DockerCLI)) { return }

    $cmd = @("ps")
    if ($All) { $cmd += "-a" }

    docker @cmd
}

function dRunContainer {
    <#
    .SYNOPSIS
    Runs a Docker container from a specified image.
    .DESCRIPTION
    Supports detached mode (-Detach), auto-removal (-Remove), interactive mode
    (-Interactive), port mappings, volumes, environment variables, custom network,
    restart policy, and extra arguments. Use -Pull to fetch the image if missing.
    .EXAMPLE
    dRunContainer -ImageName "nginx" -Detach -Ports "8080:80" -ContainerName "web"
    #>
    param(
        [string]$ImageName,
        [string]$ContainerName,
        [switch]$Detach,
        [switch]$Remove,
        [switch]$Interactive,
        [string[]]$Ports,
        [string[]]$Volumes,
        [string[]]$Env,
        [string]$Network,
        [string]$Restart,
        [string]$ExtraArgs,
        [switch]$Pull
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        if ($Pull -or (Confirm-Action "Image '$ImageName' is not local. Pull it now?")) {
            docker pull $ImageName
            if ($LASTEXITCODE -ne 0) { return }
        } else {
            Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
            return
        }
    }

    $cmd = @("run")
    if ($Detach) { $cmd += "-d" }
    if ($Remove) { $cmd += "--rm" }
    if ($Interactive) { $cmd += "-it" }
    if ($ContainerName) { $cmd += "--name"; $cmd += $ContainerName }

    foreach ($p in $Ports) { $cmd += "-p"; $cmd += $p }
    foreach ($v in $Volumes) { $cmd += "-v"; $cmd += $v }
    foreach ($e in $Env) { $cmd += "-e"; $cmd += $e }

    if ($Network) { $cmd += "--network"; $cmd += $Network }
    if ($Restart) { $cmd += "--restart"; $cmd += $Restart }
    if ($ExtraArgs) { $cmd += ($ExtraArgs -split "\s+" | Where-Object { $_ }) }

    $cmd += $ImageName

    Write-Host ("🚀 Running: docker " + ($cmd -join " ")) -ForegroundColor Cyan

    docker @cmd
    Show-DockerResult -Success "✅ Container from '$ImageName' started successfully!" -Failure "❌ Failed to start container from '$ImageName'."
}

function dCreateContainer {
    <#
    .SYNOPSIS
    Creates a container from an image without starting it.
    .EXAMPLE
    dCreateContainer -ImageName "nginx" -ContainerName "web" -Ports "8080:80"
    #>
    param(
        [string]$ImageName,
        [string]$ContainerName,
        [string[]]$Ports,
        [string[]]$Volumes,
        [string[]]$Env,
        [string]$Network,
        [string]$ExtraArgs
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    $cmd = @("create")
    if ($ContainerName) { $cmd += "--name"; $cmd += $ContainerName }

    foreach ($p in $Ports) { $cmd += "-p"; $cmd += $p }
    foreach ($v in $Volumes) { $cmd += "-v"; $cmd += $v }
    foreach ($e in $Env) { $cmd += "-e"; $cmd += $e }

    if ($Network) { $cmd += "--network"; $cmd += $Network }
    if ($ExtraArgs) { $cmd += ($ExtraArgs -split "\s+" | Where-Object { $_ }) }

    $cmd += $ImageName

    Write-Host ("🛠 Creating: docker " + ($cmd -join " ")) -ForegroundColor Cyan

    docker @cmd
    Show-DockerResult -Success "✅ Container from '$ImageName' created successfully!" -Failure "❌ Failed to create container from '$ImageName'."
}

function dStartContainer {
    <#
    .SYNOPSIS
    Starts a stopped Docker container.
    .EXAMPLE
    dStartContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to start" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🚀 Starting container '$ContainerName'..." -ForegroundColor Cyan

    docker start $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' started successfully!" -Failure "❌ Failed to start container '$ContainerName'."
}

function dStopContainer {
    <#
    .SYNOPSIS
    Stops a running Docker container.
    .EXAMPLE
    dStopContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to stop"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running or does not exist." -ForegroundColor Red
        return
    }

    Write-Host "🛑 Stopping container '$ContainerName'..." -ForegroundColor Cyan

    docker stop $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' stopped successfully!" -Failure "❌ Failed to stop container '$ContainerName'."
}

function dRestartContainer {
    <#
    .SYNOPSIS
    Restarts a Docker container (stopped or running).
    .EXAMPLE
    dRestartContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to restart" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🔄 Restarting container '$ContainerName'..." -ForegroundColor Cyan

    docker restart $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' restarted successfully!" -Failure "❌ Failed to restart container '$ContainerName'."
}

function dKillContainer {
    <#
    .SYNOPSIS
    Forcefully kills a running container (SIGKILL).
    .EXAMPLE
    dKillContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to kill" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "💀 Killing container '$ContainerName'..." -ForegroundColor Cyan

    docker kill $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' killed successfully!" -Failure "❌ Failed to kill container '$ContainerName'."
}

function dRemoveContainer {
    <#
    .SYNOPSIS
    Removes a Docker container. Use -Force to skip confirmation and -Volumes to also remove its anonymous volumes.
    .EXAMPLE
    dRemoveContainer -ContainerName "my-container" -Force
    #>
    param(
        [string]$ContainerName,
        [switch]$Force,
        [switch]$Volumes
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to remove" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    if (-not $Force -and -not (Confirm-Action "You are about to remove container '$ContainerName'. Continue?")) {
        return
    }

    Write-Host "🗑️ Removing container '$ContainerName'..." -ForegroundColor Cyan

    $cmd = @("rm")
    if ($Force) { $cmd += "-f" }
    if ($Volumes) { $cmd += "-v" }
    $cmd += $ContainerName

    docker @cmd
    Show-DockerResult -Success "✅ Container '$ContainerName' removed successfully!" -Failure "❌ Failed to remove container '$ContainerName'."
}

function dLogsContainer {
    <#
    .SYNOPSIS
    Displays logs of a Docker container. Use -Follow to stream and -Tail to limit lines.
    .EXAMPLE
    dLogsContainer -ContainerName "my-container" -Follow
    #>
    param(
        [string]$ContainerName,
        [switch]$Follow,
        [int]$Tail
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to view logs" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "📝 Displaying logs for container '$ContainerName':" -ForegroundColor Cyan

    $cmd = @("logs")
    if ($Follow) { $cmd += "-f" }
    if ($Tail) { $cmd += "--tail"; $cmd += "$Tail" }
    $cmd += $ContainerName

    docker @cmd
}

function dExecContainer {
    <#
    .SYNOPSIS
    Executes a command inside a running container (default: interactive bash).
    .EXAMPLE
    dExecContainer -ContainerName "my-container" -Command "ls -la"
    dExecContainer -ContainerName "my-container" -Command "bash" -Detach
    #>
    param(
        [string]$ContainerName,
        [string]$Command = "bash",
        [switch]$Detach
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to execute a command"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "💻 Executing '$Command' in container '$ContainerName'..." -ForegroundColor Cyan

    $cmd = @("exec")
    if ($Detach) { $cmd += "-d" } else { $cmd += "-it" }
    $cmd += $ContainerName
    $cmd += ($Command -split "\s+" | Where-Object { $_ })

    docker @cmd
}

function dAttachContainer {
    <#
    .SYNOPSIS
    Attaches the current terminal to a running container.
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to attach"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "🔗 Attaching to container '$ContainerName'..." -ForegroundColor Cyan

    docker attach $ContainerName
}

function dTopContainer {
    <#
    .SYNOPSIS
    Shows running processes inside a container.
    .EXAMPLE
    dTopContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to view processes"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running or does not exist." -ForegroundColor Red
        return
    }

    Write-Host "📊 Processes for container '$ContainerName':" -ForegroundColor Cyan

    docker top $ContainerName
}

function dStatsContainer {
    <#
    .SYNOPSIS
    Shows live resource usage for containers (CPU, memory, IO). Use -All to include stopped containers.
    #>
    param(
        [switch]$All
    )

    if (-not (Assert-DockerCLI)) { return }

    Write-Host "📊 Docker container stats (Press Ctrl + C to exit)..." -ForegroundColor Cyan

    $cmd = @("stats")
    if ($All) { $cmd += "-a" }

    docker @cmd
}

function dWaitContainer {
    <#
    .SYNOPSIS
    Waits until a container stops running.
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to wait for"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running or does not exist." -ForegroundColor Red
        return
    }

    Write-Host "⏳ Waiting for container '$ContainerName' to stop..." -ForegroundColor Yellow

    docker wait $ContainerName | Out-Null
    Show-DockerResult -Success "✅ Container '$ContainerName' has stopped." -Failure "❌ Failed to wait for container '$ContainerName'."
}

function dRenameContainer {
    <#
    .SYNOPSIS
    Renames an existing Docker container.
    .EXAMPLE
    dRenameContainer -ContainerName "old-name" -NewName "new-name"
    #>
    param(
        [string]$ContainerName,
        [string]$NewName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to rename" -All
    $NewName = Read-Value "Enter the new container name" $NewName

    if ([string]::IsNullOrWhiteSpace($ContainerName) -or [string]::IsNullOrWhiteSpace($NewName)) {
        Write-Host "❌ Missing container name or new name." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "✏️ Renaming '$ContainerName' → '$NewName'..." -ForegroundColor Cyan

    docker rename $ContainerName $NewName
    Show-DockerResult -Success "✅ Container renamed successfully!" -Failure "❌ Failed to rename container '$ContainerName'."
}

function dUpdateContainer {
    <#
    .SYNOPSIS
    Updates a container's configuration (CPU, memory, restart policy...).
    .EXAMPLE
    dUpdateContainer -ContainerName "my-container" -Options "--memory 512m"
    #>
    param(
        [string]$ContainerName,
        [string]$Options
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to update" -All
    $Options = Read-Value "Enter update options (e.g. --memory 512m)" $Options

    if ([string]::IsNullOrWhiteSpace($ContainerName) -or [string]::IsNullOrWhiteSpace($Options)) {
        Write-Host "❌ Missing container name or options." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "⚙️ Updating container '$ContainerName'..." -ForegroundColor Cyan

    $cmd = @("update")
    $cmd += ($Options -split "\s+" | Where-Object { $_ })
    $cmd += $ContainerName

    docker @cmd
    Show-DockerResult -Success "✅ Container updated successfully!" -Failure "❌ Failed to update container '$ContainerName'."
}

function dPauseContainer {
    <#
    .SYNOPSIS
    Pauses a running container (freezes all processes).
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to pause"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "⏸️ Pausing container '$ContainerName'..." -ForegroundColor Cyan

    docker pause $ContainerName
    Show-DockerResult -Success "✅ Container paused successfully!" -Failure "❌ Failed to pause container '$ContainerName'."
}

function dUnpauseContainer {
    <#
    .SYNOPSIS
    Resumes a paused Docker container.
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to unpause" -Status "paused"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    Write-Host "▶️ Resuming container '$ContainerName'..." -ForegroundColor Cyan

    docker unpause $ContainerName
    Show-DockerResult -Success "✅ Container '$ContainerName' resumed successfully!" -Failure "❌ Failed to unpause container '$ContainerName'."
}

function dExportContainer {
    <#
    .SYNOPSIS
    Exports a container's filesystem to a .tar archive.
    .EXAMPLE
    dExportContainer -ContainerName "my-container" -OutputFile "backup.tar"
    #>
    param(
        [string]$ContainerName,
        [string]$OutputFile
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to export" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($OutputFile)) {
        $OutputFile = "$ContainerName.tar"
    }

    Write-Host "📤 Exporting container '$ContainerName'..." -ForegroundColor Cyan

    docker export $ContainerName -o $OutputFile
    Show-DockerResult -Success "✅ Container exported to '$OutputFile' successfully!" -Failure "❌ Failed to export container '$ContainerName'."
}

function dCommitContainer {
    <#
    .SYNOPSIS
    Creates a new image from a container's current state.
    .EXAMPLE
    dCommitContainer -ContainerName "my-container" -ImageName "myapp:latest" -Message "installed deps"
    #>
    param(
        [string]$ContainerName,
        [string]$ImageName,
        [string]$Message,
        [string]$Author
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to commit" -All
    $ImageName = Read-Value "Enter the new image name (e.g. myapp:latest)" $ImageName

    if ([string]::IsNullOrWhiteSpace($ContainerName) -or [string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ Missing container name or image name." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "📸 Committing container '$ContainerName' → '$ImageName'..." -ForegroundColor Cyan

    $cmd = @("commit")
    if ($Message) { $cmd += "-m"; $cmd += $Message }
    if ($Author) { $cmd += "-a"; $cmd += $Author }
    $cmd += $ContainerName
    $cmd += $ImageName

    docker @cmd
    Show-DockerResult -Success "✅ Container committed successfully as '$ImageName'!" -Failure "❌ Failed to commit container '$ContainerName'."
}

function dDiffContainer {
    <#
    .SYNOPSIS
    Shows filesystem changes of a container since it was created.
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to diff" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    Write-Host "📊 Showing filesystem changes for '$ContainerName'..." -ForegroundColor Cyan

    docker diff $ContainerName
}

function dCpContainer {
    <#
    .SYNOPSIS
    Copies files or folders between the host and a container.
    .EXAMPLE
    dCpContainer -Source "file.txt" -Destination "my-container:/app/file.txt"
    dCpContainer -Source "my-container:/app/file.txt" -Destination "./file.txt"
    #>
    param(
        [string]$Source,
        [string]$Destination
    )

    if (-not (Assert-DockerCLI)) { return }

    $Source = Read-Value "Enter source path (host or container)" $Source
    $Destination = Read-Value "Enter destination path (host or container)" $Destination

    if ([string]::IsNullOrWhiteSpace($Source) -or [string]::IsNullOrWhiteSpace($Destination)) {
        Write-Host "❌ Missing source or destination path." -ForegroundColor Red
        return
    }

    Write-Host "📁 Copying:" -ForegroundColor Cyan
    Write-Host "$Source → $Destination"

    docker cp $Source $Destination
    Show-DockerResult -Success "✅ Copy completed successfully!" -Failure "❌ Copy operation failed."
}

function dInspectContainer {
    <#
    .SYNOPSIS
    Displays detailed low-level information about a container.
    .EXAMPLE
    dInspectContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to inspect" -All
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerExists $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' not found." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting container '$ContainerName':" -ForegroundColor Cyan

    docker inspect $ContainerName
}

function dPortContainer {
    <#
    .SYNOPSIS
    Shows the public port mapping of a running container.
    .EXAMPLE
    dPortContainer -ContainerName "my-container"
    #>
    param(
        [string]$ContainerName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ContainerName = Resolve-ContainerName $ContainerName "Enter the container name or ID to view ports"
    if ([string]::IsNullOrWhiteSpace($ContainerName)) {
        Write-Host "❌ No container name provided." -ForegroundColor Red
        return
    }

    if (-not (Test-ContainerRunning $ContainerName)) {
        Write-Host "❌ Container '$ContainerName' is not running." -ForegroundColor Red
        return
    }

    Write-Host "🔌 Port mapping for container '$ContainerName':" -ForegroundColor Cyan

    docker port $ContainerName
}

function dContainerDocs {
    <#
    .SYNOPSIS
    Shows a reference table of all container-related commands.
    #>
    $commands = @(
        @{Command="dContainers [-All]"; Description="List containers (running by default, all with -All)"},
        @{Command="dRunContainer <image> [name]"; Description="Run a container (detach, ports, volumes, env, network...)"},
        @{Command="dCreateContainer <image> [name]"; Description="Create a container without starting it"},
        @{Command="dStartContainer [name]"; Description="Start a stopped container"},
        @{Command="dStopContainer [name]"; Description="Stop a running container"},
        @{Command="dRestartContainer [name]"; Description="Restart a container"},
        @{Command="dKillContainer [name]"; Description="Force stop (kill) a container"},
        @{Command="dRemoveContainer [name] [-Force] [-Volumes]"; Description="Remove a container"},
        @{Command="dLogsContainer [name] [-Follow] [-Tail]"; Description="Show container logs"},
        @{Command="dExecContainer [name] [command]"; Description="Execute a command inside a running container"},
        @{Command="dAttachContainer [name]"; Description="Attach to a container terminal"},
        @{Command="dTopContainer [name]"; Description="Show running processes inside a container"},
        @{Command="dStatsContainer [-All]"; Description="Show live resource usage for containers"},
        @{Command="dWaitContainer [name]"; Description="Wait until a container stops"},
        @{Command="dRenameContainer [name] [newName]"; Description="Rename a container"},
        @{Command="dUpdateContainer [name] [options]"; Description="Update container resources (CPU, memory...)"},
        @{Command="dPauseContainer [name]"; Description="Pause a running container"},
        @{Command="dUnpauseContainer [name]"; Description="Resume a paused container"},
        @{Command="dExportContainer [name] [file]"; Description="Export a container filesystem to a tar file"},
        @{Command="dCommitContainer [name] [image]"; Description="Create a new image from a container"},
        @{Command="dDiffContainer [name]"; Description="Show filesystem changes inside a container"},
        @{Command="dCpContainer <source> <destination>"; Description="Copy files between host and container"},
        @{Command="dInspectContainer [name]"; Description="Show low-level container information"},
        @{Command="dPortContainer [name]"; Description="Show a container's public port mapping"}
    )

    Show-DocTable -Commands $commands -Title "🐳 Docker Container Commands"
}
