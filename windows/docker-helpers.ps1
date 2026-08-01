# docker-helpers.ps1
# Shared internal helpers used by every Docker command file.
# Keeps the command files short, consistent, and free of duplicated logic.

<#
.SYNOPSIS
Checks that the Docker CLI is available on the system.
#>
function Test-DockerCLI {
    [bool](Get-Command docker -ErrorAction SilentlyContinue)
}

<#
.SYNOPSIS
Verifies Docker is installed and prints an error if it is missing.
Returns $true when Docker is available.
#>
function Assert-DockerCLI {
    if (-not (Test-DockerCLI)) {
        Write-Host "❌ Docker CLI not found. Please install Docker and restart your terminal." -ForegroundColor Red
        return $false
    }
    return $true
}

<#
.SYNOPSIS
Asks for a Y/N confirmation before a destructive operation.
Returns $true when the user confirms.
#>
function Confirm-Action {
    param(
        [string]$Message = "Continue?"
    )

    Write-Host "⚠️  $Message (Y/N)" -ForegroundColor Yellow

    if ((Read-Host) -match "^[Yy]") {
        return $true
    }

    Write-Host "❌ Operation cancelled." -ForegroundColor Red
    return $false
}

<#
.SYNOPSIS
Prints a success/failure message based on the last command exit code.
Returns $true on success.
#>
function Show-DockerResult {
    param(
        [string]$Success = "✅ Done.",
        [string]$Failure = "❌ Operation failed."
    )

    if ($LASTEXITCODE -eq 0) {
        if ($Success) { Write-Host $Success -ForegroundColor Green }
        return $true
    }

    if ($Failure) { Write-Host $Failure -ForegroundColor Red }
    return $false
}

<#
.SYNOPSIS
Returns the supplied value, or prompts the user when it is empty.
#>
function Read-Value {
    param(
        [string]$Prompt,
        [string]$Value
    )

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return Read-Host $Prompt
    }
    return $Value
}

<#
.SYNOPSIS
Appends ":latest" to an image name when no tag is given.
#>
function Complete-ImageName {
    param([string]$ImageName)

    if ($ImageName -notmatch ":") { return "$ImageName:latest" }
    return $ImageName
}

<#
.SYNOPSIS
Returns local images formatted as "repository:tag".
#>
function Get-LocalImages {
    docker images --format "{{.Repository}}:{{.Tag}}" 2>$null
}

<#
.SYNOPSIS
Returns $true when a local image exists (auto-adds ":latest").
#>
function Test-ImageExists {
    param([string]$ImageName)

    $ImageName = Complete-ImageName $ImageName
    return ((Get-LocalImages) -contains $ImageName)
}

<#
.SYNOPSIS
Prints the local image table.
#>
function Show-ImageList {
    docker images
}

<#
.SYNOPSIS
Prompts for an image name, listing local images first when needed.
#>
function Resolve-ImageName {
    param(
        [string]$Name,
        [string]$Prompt = "Enter the image name (e.g. nginx or nginx:latest)"
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "📦 Available local images:" -ForegroundColor Cyan
        Show-ImageList
        Write-Host ""
        $Name = Read-Host $Prompt
    }
    return $Name
}

<#
.SYNOPSIS
Prints a container table (all / running / by status).
#>
function Show-ContainerList {
    param(
        [switch]$All,
        [string]$Status
    )

    if ($All) {
        docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    } elseif ($Status) {
        docker ps --filter "status=$Status" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    } else {
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
    }
}

<#
.SYNOPSIS
Returns container names (all / running / by status).
#>
function Get-ContainerNames {
    param(
        [switch]$All,
        [string]$Status
    )

    if ($All) {
        docker ps -a --format "{{.Names}}" 2>$null
    } elseif ($Status) {
        docker ps --filter "status=$Status" --format "{{.Names}}" 2>$null
    } else {
        docker ps --format "{{.Names}}" 2>$null
    }
}

<#
.SYNOPSIS
Returns $true when a container exists, matching by exact name or ID prefix.
#>
function Test-ContainerExists {
    param([string]$NameOrId)

    if ([string]::IsNullOrWhiteSpace($NameOrId)) { return $false }
    if ((Get-ContainerNames -All) -contains $NameOrId) { return $true }

    foreach ($id in (docker ps -a --format "{{.ID}}" 2>$null)) {
        if ($id -like "$NameOrId*") { return $true }
    }
    return $false
}

<#
.SYNOPSIS
Returns $true when a container is currently running (name or ID prefix).
#>
function Test-ContainerRunning {
    param([string]$NameOrId)

    if ([string]::IsNullOrWhiteSpace($NameOrId)) { return $false }
    if ((Get-ContainerNames) -contains $NameOrId) { return $true }

    foreach ($id in (docker ps --format "{{.ID}}" 2>$null)) {
        if ($id -like "$NameOrId*") { return $true }
    }
    return $false
}

<#
.SYNOPSIS
Prompts for a container name, listing containers first when needed.
#>
function Resolve-ContainerName {
    param(
        [string]$Name,
        [string]$Prompt = "Enter the container name or ID",
        [switch]$All,
        [string]$Status
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "📦 Available containers:" -ForegroundColor Cyan
        Show-ContainerList -All:$All -Status $Status
        Write-Host ""
        $Name = Read-Host $Prompt
    }
    return $Name
}

<#
.SYNOPSIS
Returns Docker volume names.
#>
function Get-VolumeNames {
    docker volume ls --format "{{.Name}}" 2>$null
}

<#
.SYNOPSIS
Returns $true when a Docker volume exists.
#>
function Test-VolumeExists {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
    return ((Get-VolumeNames) -contains $Name)
}

<#
.SYNOPSIS
Returns Docker network names.
#>
function Get-NetworkNames {
    docker network ls --format "{{.Name}}" 2>$null
}

<#
.SYNOPSIS
Returns $true when a Docker network exists.
#>
function Test-NetworkExists {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
    return ((Get-NetworkNames) -contains $Name)
}

<#
.SYNOPSIS
Returns Docker Swarm service names.
#>
function Get-ServiceNames {
    docker service ls --format "{{.Name}}" 2>$null
}

<#
.SYNOPSIS
Returns $true when a Swarm service exists.
#>
function Test-ServiceExists {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) { return $false }
    return ((Get-ServiceNames) -contains $Name)
}

<#
.SYNOPSIS
Prompts for a service name, listing services first when needed.
#>
function Resolve-ServiceName {
    param(
        [string]$Name,
        [string]$Prompt = "Enter the service name"
    )

    if ([string]::IsNullOrWhiteSpace($Name)) {
        Write-Host "📦 Available services:" -ForegroundColor Cyan
        docker service ls --format "table {{.Name}}\t{{.Mode}}\t{{.Replicas}}"
        Write-Host ""
        $Name = Read-Host $Prompt
    }
    return $Name
}

<#
.SYNOPSIS
Prints an aligned command/description reference table.
#>
function Show-DocTable {
    param(
        [object[]]$Commands,
        [string]$Title = ""
    )

    $colCommandWidth = 50
    $colDescWidth = 78

    if ($Title) {
        Write-Host ""
        Write-Host $Title -ForegroundColor Cyan
    }

    Write-Host ("COMMAND".PadRight($colCommandWidth) + "DESCRIPTION".PadRight($colDescWidth)) -ForegroundColor Yellow
    Write-Host ("-" * ($colCommandWidth + $colDescWidth)) -ForegroundColor DarkGray

    foreach ($c in $Commands) {
        $name = $c.Command.PadRight($colCommandWidth)
        $desc = $c.Description.PadRight($colDescWidth)
        Write-Host "$name$desc"
    }

    Write-Host ""
}
