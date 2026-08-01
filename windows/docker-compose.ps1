# docker-compose.ps1
# Docker Compose multi-container orchestration: up, down, build, logs, exec,
# restart, pull, config validation, and stop. No Invoke-Expression - arguments
# are always passed as arrays to the Docker CLI.

<#
.SYNOPSIS
Resolves the compose file (docker-compose.yml / compose.yaml / ...) in a path.
Returns $null and prints an error when no compose file is found.
#>
function Get-ComposeFile {
    param([string]$Path = ".")

    foreach ($name in @("docker-compose.yml", "docker-compose.yaml", "compose.yaml", "compose.yml")) {
        $file = Join-Path $Path $name
        if (Test-Path $file -PathType Leaf) {
            return $file
        }
    }

    Write-Host "❌ No Docker Compose file found in '$Path'." -ForegroundColor Red
    return $null
}

<#
.SYNOPSIS
Prompts for a service name, listing compose services first when needed.
#>
function Resolve-ComposeService {
    param(
        [string]$Service,
        [string]$ComposeFile,
        [string]$Prompt = "Enter the service name"
    )

    if ([string]::IsNullOrWhiteSpace($Service)) {
        Write-Host "📦 Available services:" -ForegroundColor Cyan
        docker compose -f $ComposeFile ps --services 2>$null
        Write-Host ""
        $Service = Read-Host $Prompt
    }
    return $Service
}

function dComposes {
    <#
    .SYNOPSIS
    Lists the running services of a Docker Compose project.
    .EXAMPLE
    dComposes -Path "."
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "📦 Listing Docker Compose services..." -ForegroundColor Cyan

    docker compose -f $composeFile ps
}

function dComposeUp {
    <#
    .SYNOPSIS
    Starts Docker Compose services. Use -Detached for background mode and -Build to rebuild images.
    .EXAMPLE
    dComposeUp -Detached
    dComposeUp -Path "C:\my-project" -Build
    #>
    param(
        [string]$Path = ".",
        [switch]$Detached,
        [switch]$Build
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "🚀 Starting Docker Compose services..." -ForegroundColor Cyan

    $cmd = @("compose", "-f", $composeFile, "up")
    if ($Detached) { $cmd += "-d" }
    if ($Build) { $cmd += "--build" }

    docker @cmd
}

function dComposeDown {
    <#
    .SYNOPSIS
    Stops and removes Docker Compose services, networks, and containers.
    Use -Volumes to also remove volumes and -RemoveOrphans to clean up unused containers.
    .EXAMPLE
    dComposeDown -Volumes
    #>
    param(
        [string]$Path = ".",
        [switch]$Volumes,
        [switch]$RemoveOrphans
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "🛑 Stopping Docker Compose services..." -ForegroundColor Yellow

    $cmd = @("compose", "-f", $composeFile, "down")
    if ($Volumes) { $cmd += "-v" }
    if ($RemoveOrphans) { $cmd += "--remove-orphans" }

    docker @cmd
}

function dComposeBuild {
    <#
    .SYNOPSIS
    Builds the images defined in a Docker Compose file without starting them.
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "🔨 Building Docker Compose services..." -ForegroundColor Cyan

    docker compose -f $composeFile build
}

function dComposeLogs {
    <#
    .SYNOPSIS
    Shows logs for Docker Compose services. Use -Follow to stream and -Tail to limit lines.
    .EXAMPLE
    dComposeLogs -Service "api" -Follow
    #>
    param(
        [string]$Path = ".",
        [string]$Service = "",
        [switch]$Follow,
        [int]$Tail
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "📝 Showing Docker Compose logs..." -ForegroundColor Cyan

    $cmd = @("compose", "-f", $composeFile, "logs")
    if ($Follow) { $cmd += "-f" }
    if ($Tail) { $cmd += "--tail"; $cmd += "$Tail" }
    if (-not [string]::IsNullOrWhiteSpace($Service)) { $cmd += $Service }

    docker @cmd
}

function dComposeExec {
    <#
    .SYNOPSIS
    Executes a command inside a Docker Compose service (default: interactive bash).
    .EXAMPLE
    dComposeExec -Service "api" -Command "sh"
    #>
    param(
        [string]$Path = ".",
        [string]$Service,
        [string]$Command = "bash"
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    $Service = Resolve-ComposeService $Service $composeFile
    if ([string]::IsNullOrWhiteSpace($Service)) {
        Write-Host "❌ No service provided." -ForegroundColor Red
        return
    }

    Write-Host "💻 Executing '$Command' in service '$Service'..." -ForegroundColor Cyan

    $cmd = @("compose", "-f", $composeFile, "exec", "-it", $Service)
    $cmd += ($Command -split "\s+" | Where-Object { $_ })

    docker @cmd
}

function dComposeRestart {
    <#
    .SYNOPSIS
    Restarts all Docker Compose services.
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "🔄 Restarting Docker Compose services..." -ForegroundColor Yellow

    docker compose -f $composeFile restart
}

function dComposePull {
    <#
    .SYNOPSIS
    Pulls the images referenced by a Docker Compose file.
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "⬇️ Pulling Docker Compose images..." -ForegroundColor Cyan

    docker compose -f $composeFile pull
}

function dComposeStop {
    <#
    .SYNOPSIS
    Stops running Docker Compose services without removing them.
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "🛑 Stopping Docker Compose services (containers kept)..." -ForegroundColor Yellow

    docker compose -f $composeFile stop
}

function dComposeConfig {
    <#
    .SYNOPSIS
    Shows the merged and validated Docker Compose configuration.
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "📄 Docker Compose configuration:" -ForegroundColor Cyan

    docker compose -f $composeFile config
}

function dComposeValidate {
    <#
    .SYNOPSIS
    Validates the Docker Compose file syntax without running anything.
    #>
    param(
        [string]$Path = "."
    )

    if (-not (Assert-DockerCLI)) { return }

    $composeFile = Get-ComposeFile $Path
    if (-not $composeFile) { return }

    Write-Host "🔎 Validating Docker Compose file..." -ForegroundColor Cyan

    docker compose -f $composeFile config -q
    Show-DockerResult -Success "✅ Compose file is valid." -Failure "❌ Compose file is invalid."
}

function dComposeDocs {
    <#
    .SYNOPSIS
    Shows a reference table of all Docker Compose commands.
    #>
    $commands = @(
        @{Command="dComposes [path]"; Description="List Docker Compose services"},
        @{Command="dComposeUp [path] [-Detached] [-Build]"; Description="Start Compose services"},
        @{Command="dComposeDown [path] [-Volumes] [-RemoveOrphans]"; Description="Stop and remove Compose services"},
        @{Command="dComposeBuild [path]"; Description="Build Compose service images"},
        @{Command="dComposeLogs [path] [service] [-Follow] [-Tail]"; Description="Show service logs"},
        @{Command="dComposeExec [path] [service] [command]"; Description="Execute a command in a service"},
        @{Command="dComposeRestart [path]"; Description="Restart Compose services"},
        @{Command="dComposePull [path]"; Description="Pull Compose images"},
        @{Command="dComposeStop [path]"; Description="Stop services (keep containers)"},
        @{Command="dComposeConfig [path]"; Description="Show merged Compose configuration"},
        @{Command="dComposeValidate [path]"; Description="Validate the Compose file"}
    )

    Show-DocTable -Commands $commands -Title "🐳 Docker Compose Commands"
}
