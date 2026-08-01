# docker-images.ps1
# Local image management: listing, building, pulling, pushing, tagging,
# importing/exporting, and inspecting images.

function dImages {
    <#
    .SYNOPSIS
    Lists all local Docker images.
    #>
    if (-not (Assert-DockerCLI)) { return }
    docker image ls
}

function dBuildImage {
    <#
    .SYNOPSIS
    Builds a Docker image from a folder containing a Dockerfile.
    .EXAMPLE
    dBuildImage -AppName "my-app" -Tag "1.0.0"
    dBuildImage -AppName "my-app" -NoCache
    #>
    param(
        [string]$AppName,
        [string]$Tag = "latest",
        [switch]$NoCache
    )

    if (-not (Assert-DockerCLI)) { return }

    $AppName = Read-Value "Enter your app folder name" $AppName
    if ([string]::IsNullOrWhiteSpace($AppName)) {
        Write-Host "❌ No folder provided." -ForegroundColor Red
        return
    }

    if (-not (Test-Path $AppName -PathType Container)) {
        Write-Host "❌ Folder '$AppName' does not exist." -ForegroundColor Red
        return
    }

    $dockerfilePath = Join-Path $AppName "Dockerfile"
    if (-not (Test-Path $dockerfilePath)) {
        Write-Host "❌ No Dockerfile found in '$AppName'." -ForegroundColor Red
        return
    }

    $fullImageName = "$AppName`:$Tag"

    $cmd = @("build")
    if ($NoCache) { $cmd += "--no-cache" }
    $cmd += "-t"; $cmd += $fullImageName
    $cmd += $AppName

    Write-Host "⬆️ Building Docker image '$fullImageName' from folder '$AppName'..." -ForegroundColor Cyan

    docker @cmd
    Show-DockerResult -Success "✅ Image '$fullImageName' built successfully!" -Failure "❌ Failed to build image '$fullImageName'."
}

function dGetImage {
    <#
    .SYNOPSIS
    Pulls a Docker image from a registry (Docker Hub by default).
    .EXAMPLE
    dGetImage -ImageName "nginx:latest"
    dGetImage "ubuntu:22.04"
    #>
    param(
        [string]$ImageName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName "Enter image name (e.g. nginx or nginx:latest)"
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    Write-Host "⬇️ Pulling image '$ImageName'..." -ForegroundColor Cyan

    docker pull $ImageName
    Show-DockerResult -Success "✅ Image '$ImageName' downloaded successfully!" -Failure "❌ Failed to pull image '$ImageName'."
}

function dPushImage {
    <#
    .SYNOPSIS
    Pushes a local Docker image to a registry.
    .EXAMPLE
    dPushImage -ImageName "username/app:1.0.0"
    #>
    param(
        [string]$ImageName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName "Enter the image to push (e.g. username/app:tag)"
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "⬆️ Pushing image '$ImageName' to registry..." -ForegroundColor Cyan

    docker push $ImageName
    Show-DockerResult -Success "✅ Image '$ImageName' pushed successfully!" -Failure "❌ Failed to push image '$ImageName'."
}

function dRemoveImage {
    <#
    .SYNOPSIS
    Removes a local Docker image. Use -Force to skip the confirmation.
    .EXAMPLE
    dRemoveImage -ImageName "myapp:1.0.0"
    dRemoveImage "nginx" -Force
    #>
    param(
        [string]$ImageName,
        [switch]$Force
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName "Enter the image name to remove (e.g. myapp:latest)"
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    if (-not $Force -and -not (Confirm-Action "You are about to remove image '$ImageName'. Continue?")) {
        return
    }

    Write-Host "🗑️ Removing image '$ImageName'..." -ForegroundColor Cyan

    $cmd = @("rmi")
    if ($Force) { $cmd += "-f" }
    $cmd += $ImageName

    docker @cmd
    Show-DockerResult -Success "✅ Image '$ImageName' removed successfully!" -Failure "❌ Failed to remove image '$ImageName'."
}

function dPruneImage {
    <#
    .SYNOPSIS
    Removes unused images. Use -All to also remove images not used by any container.
    #>
    param(
        [switch]$All,
        [switch]$Force
    )

    if (-not (Assert-DockerCLI)) { return }

    $what = $(if ($All) { "all unused images" } else { "dangling images" })

    if (-not $Force -and -not (Confirm-Action "This will remove $what. Continue?")) { return }

    Write-Host "🧹 Pruning Docker images..." -ForegroundColor Cyan

    $cmd = @("image", "prune")
    if ($All) { $cmd += "-a" }
    $cmd += "-f"

    docker @cmd
    Show-DockerResult -Success "✅ Unused images removed successfully!" -Failure "❌ Failed to prune Docker images."
}

function dTagImage {
    <#
    .SYNOPSIS
    Tags a Docker image by creating a new reference (name:tag).
    .EXAMPLE
    dTagImage -SourceImage "myapp:1.0.0" -TargetImage "username/myapp:prod"
    #>
    param(
        [string]$SourceImage,
        [string]$TargetImage
    )

    if (-not (Assert-DockerCLI)) { return }

    $SourceImage = Read-Value "Enter source image (name:tag)" $SourceImage
    $TargetImage = Read-Value "Enter target image (name:tag)" $TargetImage

    if ([string]::IsNullOrWhiteSpace($SourceImage) -or [string]::IsNullOrWhiteSpace($TargetImage)) {
        Write-Host "❌ Source or target image missing." -ForegroundColor Red
        return
    }

    $SourceImage = Complete-ImageName $SourceImage
    $TargetImage = Complete-ImageName $TargetImage

    if (-not (Test-ImageExists $SourceImage)) {
        Write-Host "❌ Source image '$SourceImage' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "🏷️ Tagging: $SourceImage ➜ $TargetImage" -ForegroundColor Cyan

    docker tag $SourceImage $TargetImage
    Show-DockerResult -Success "✅ Image tagged successfully!" -Failure "❌ Failed to tag image '$SourceImage'."
}

function dSaveImage {
    <#
    .SYNOPSIS
    Saves a Docker image to a .tar archive file.
    .EXAMPLE
    dSaveImage -ImageName "nginx:latest" -OutputFile "nginx.tar"
    #>
    param(
        [string]$ImageName,
        [string]$OutputFile
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName "Enter the image name to save (e.g. myapp:latest)"
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    if ([string]::IsNullOrWhiteSpace($OutputFile)) {
        $safeName = $ImageName -replace "[:/]", "_"
        $OutputFile = "$safeName.tar"
    }

    Write-Host "💾 Saving image '$ImageName' to file '$OutputFile'..." -ForegroundColor Cyan

    docker save $ImageName -o $OutputFile
    Show-DockerResult -Success "✅ Image saved successfully to '$OutputFile'." -Failure "❌ Failed to save image '$ImageName'."
}

function dLoadImage {
    <#
    .SYNOPSIS
    Loads a Docker image from a .tar archive file.
    .EXAMPLE
    dLoadImage -InputFile "myapp.tar"
    #>
    param(
        [string]$InputFile
    )

    if (-not (Assert-DockerCLI)) { return }

    if ([string]::IsNullOrWhiteSpace($InputFile)) {
        Write-Host "📂 Available .tar files in current directory:" -ForegroundColor Cyan
        Get-ChildItem -Filter *.tar -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Name
        Write-Host ""
        $InputFile = Read-Host "Enter the path to the .tar file to load"
    }

    if ([string]::IsNullOrWhiteSpace($InputFile)) {
        Write-Host "❌ No file path provided." -ForegroundColor Red
        return
    }

    if (-not (Test-Path $InputFile -PathType Leaf)) {
        Write-Host "❌ File '$InputFile' does not exist." -ForegroundColor Red
        return
    }

    Write-Host "⬇️ Loading Docker image from '$InputFile'..." -ForegroundColor Cyan

    docker load -i $InputFile
    Show-DockerResult -Success "✅ Image loaded successfully from '$InputFile'." -Failure "❌ Failed to load image from '$InputFile'."
}

function dHistoryImage {
    <#
    .SYNOPSIS
    Displays the layer history of a Docker image.
    .EXAMPLE
    dHistoryImage -ImageName "ubuntu:latest"
    #>
    param(
        [string]$ImageName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName "Enter the image name to view history (e.g. ubuntu:latest)"
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "📜 Showing history for image '$ImageName':" -ForegroundColor Cyan

    docker history $ImageName
}

function dInspectImage {
    <#
    .SYNOPSIS
    Displays detailed low-level information about a Docker image.
    .EXAMPLE
    dInspectImage -ImageName "ubuntu:latest"
    #>
    param(
        [string]$ImageName
    )

    if (-not (Assert-DockerCLI)) { return }

    $ImageName = Resolve-ImageName $ImageName "Enter the image name to inspect (e.g. ubuntu:latest)"
    if ([string]::IsNullOrWhiteSpace($ImageName)) {
        Write-Host "❌ No image name provided." -ForegroundColor Red
        return
    }

    $ImageName = Complete-ImageName $ImageName

    if (-not (Test-ImageExists $ImageName)) {
        Write-Host "❌ Image '$ImageName' not found locally." -ForegroundColor Red
        return
    }

    Write-Host "🔍 Inspecting image '$ImageName':" -ForegroundColor Cyan

    docker inspect $ImageName
}

function dImageDocs {
    <#
    .SYNOPSIS
    Shows a reference table of all image-related commands.
    #>
    $commands = @(
        @{Command="dImages"; Description="List all local Docker images"},
        @{Command="dBuildImage <folder> [tag] [-NoCache]"; Description="Build a Docker image from a folder"},
        @{Command="dGetImage <image[:tag]>"; Description="Pull a Docker image from a registry"},
        @{Command="dPushImage <image[:tag]>"; Description="Push a local Docker image to a registry"},
        @{Command="dRemoveImage <image[:tag]> [-Force]"; Description="Remove a local Docker image"},
        @{Command="dPruneImage [-All] [-Force]"; Description="Remove unused/dangling images"},
        @{Command="dTagImage <source[:tag]> <target[:tag]>"; Description="Tag a Docker image with a new reference"},
        @{Command="dSaveImage <image[:tag]> [file]"; Description="Save a Docker image to a .tar archive"},
        @{Command="dLoadImage <file.tar>"; Description="Load a Docker image from a .tar archive"},
        @{Command="dHistoryImage <image[:tag]>"; Description="Show the layer history of an image"},
        @{Command="dInspectImage <image[:tag]>"; Description="Show low-level image information"}
    )

    Show-DocTable -Commands $commands -Title "🐳 Docker Image Commands"
}
