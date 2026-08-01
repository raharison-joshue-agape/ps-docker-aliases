# docker-images.sh
# Local image management: listing, building, pulling, pushing, tagging,
# importing/exporting, and inspecting images.

# Usage: dImages
dImages() {
    d_check_cli || return 1
    docker image ls
}

# Usage: dBuildImage [folder] [tag] [--no-cache]
dBuildImage() {
    d_check_cli || return 1
    local AppName="" Tag="latest" nocache=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -nc|--no-cache) nocache=1; shift ;;
            *) [ -z "$AppName" ] && AppName="$1" || Tag="$1"; shift ;;
        esac
    done

    if [ -z "$AppName" ]; then
        read -r -p "Enter your app folder name: " AppName
    fi
    [ -z "$AppName" ] && { printf '%s❌ No folder provided.%s\n' "$dRed" "$dReset"; return 1; }
    [ -d "$AppName" ] || { printf '%s❌ Folder %s does not exist.%s\n' "$dRed" "$AppName" "$dReset"; return 1; }
    [ -f "$AppName/Dockerfile" ] || { printf '%s❌ No Dockerfile found in %s.%s\n' "$dRed" "$AppName" "$dReset"; return 1; }

    # Derive a valid image name from the folder (handles paths like ./app or .)
    local name
    if [ "$AppName" = "." ]; then
        name="$(basename "$PWD")"
    else
        name="$(basename "$AppName")"
    fi
    local full="$name:$Tag"

    printf '%s⬆️ Building Docker image %s from folder %s...%s\n' "$dCyan" "$full" "$AppName" "$dReset"

    local cmd=(build)
    [ "$nocache" -eq 1 ] && cmd+=(--no-cache)
    cmd+=(-t "$full" "$AppName")

    docker "${cmd[@]}"
    d_show_result "✅ Image '$full' built successfully!" "❌ Failed to build image '$full'."
}

# Usage: dGetImage [image[:tag]]
dGetImage() {
    d_check_cli || return 1
    local ImageName="$1"
    ImageName="$(d_resolve_image "$ImageName" "Enter image name (e.g. nginx or nginx:latest)")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }

    ImageName="$(d_complete_image "$ImageName")"

    printf '%s⬇️ Pulling image %s...%s\n' "$dCyan" "$ImageName" "$dReset"

    docker pull "$ImageName"
    d_show_result "✅ Image '$ImageName' downloaded successfully!" "❌ Failed to pull image '$ImageName'."
}

# Usage: dPushImage [image[:tag]]
dPushImage() {
    d_check_cli || return 1
    local ImageName="$1"
    ImageName="$(d_resolve_image "$ImageName" "Enter the image to push (e.g. username/app:tag)")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }

    ImageName="$(d_complete_image "$ImageName")"

    d_image_exists "$ImageName" || { printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"; return 1; }

    printf '%s⬆️ Pushing image %s to registry...%s\n' "$dCyan" "$ImageName" "$dReset"

    docker push "$ImageName"
    d_show_result "✅ Image '$ImageName' pushed successfully!" "❌ Failed to push image '$ImageName'."
}

# Usage: dRemoveImage [image[:tag]] [-f|--force]
dRemoveImage() {
    d_check_cli || return 1
    local ImageName="" force=0
    local arg
    for arg in "$@"; do
        case "$arg" in
            -f|--force) force=1 ;;
            *) ImageName="$arg" ;;
        esac
    done

    ImageName="$(d_resolve_image "$ImageName" "Enter the image name to remove (e.g. myapp:latest)")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }

    ImageName="$(d_complete_image "$ImageName")"

    d_image_exists "$ImageName" || { printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"; return 1; }

    if [ "$force" -eq 0 ]; then
        d_confirm "You are about to remove image '$ImageName'. Continue?" || return 1
    fi

    printf '%s🗑️ Removing image %s...%s\n' "$dCyan" "$ImageName" "$dReset"

    local cmd=(rmi)
    [ "$force" -eq 1 ] && cmd+=(-f)
    cmd+=("$ImageName")

    docker "${cmd[@]}"
    d_show_result "✅ Image '$ImageName' removed successfully!" "❌ Failed to remove image '$ImageName'."
}

# Usage: dPruneImage [-a|--all] [-f|--force]
dPruneImage() {
    d_check_cli || return 1
    local all=0 force=0
    local arg
    for arg in "$@"; do
        case "$arg" in
            -a|--all) all=1 ;;
            -f|--force) force=1 ;;
        esac
    done

    local what="dangling images"
    [ "$all" -eq 1 ] && what="all unused images"

    if [ "$force" -eq 0 ]; then
        d_confirm "This will remove $what. Continue?" || return 1
    fi

    printf '%s🧹 Pruning Docker images...%s\n' "$dCyan" "$dReset"

    local cmd=(image prune)
    [ "$all" -eq 1 ] && cmd+=(-a)
    cmd+=(-f)

    docker "${cmd[@]}"
    d_show_result "✅ Unused images removed successfully!" "❌ Failed to prune Docker images."
}

# Usage: dTagImage <source> <target>
dTagImage() {
    d_check_cli || return 1
    local SourceImage="${1:-}" TargetImage="${2:-}"
    [ -z "$SourceImage" ] && read -r -p "Enter source image (name:tag): " SourceImage
    [ -z "$TargetImage" ] && read -r -p "Enter target image (name:tag): " TargetImage

    if [ -z "$SourceImage" ] || [ -z "$TargetImage" ]; then
        printf '%s❌ Source or target image missing.%s\n' "$dRed" "$dReset"
        return 1
    fi

    SourceImage="$(d_complete_image "$SourceImage")"
    TargetImage="$(d_complete_image "$TargetImage")"

    d_image_exists "$SourceImage" || { printf '%s❌ Source image %s not found locally.%s\n' "$dRed" "$SourceImage" "$dReset"; return 1; }

    printf '%s🏷️ Tagging: %s ➜ %s%s\n' "$dCyan" "$SourceImage" "$TargetImage" "$dReset"

    docker tag "$SourceImage" "$TargetImage"
    d_show_result "✅ Image tagged successfully!" "❌ Failed to tag image '$SourceImage'."
}

# Usage: dSaveImage [image[:tag]] [output-file]
dSaveImage() {
    d_check_cli || return 1
    local ImageName="${1:-}" OutputFile="${2:-}"
    ImageName="$(d_resolve_image "$ImageName" "Enter the image name to save (e.g. myapp:latest)")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }

    ImageName="$(d_complete_image "$ImageName")"

    d_image_exists "$ImageName" || { printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"; return 1; }

    if [ -z "$OutputFile" ]; then
        OutputFile="${ImageName//[:]/_}.tar"
        OutputFile="${OutputFile//\//_}"
    fi

    printf '%s💾 Saving image %s to file %s...%s\n' "$dCyan" "$ImageName" "$OutputFile" "$dReset"

    docker save "$ImageName" -o "$OutputFile"
    d_show_result "✅ Image saved successfully to '$OutputFile'." "❌ Failed to save image '$ImageName'."
}

# Usage: dLoadImage [file.tar]
dLoadImage() {
    d_check_cli || return 1
    local InputFile="${1:-}"
    if [ -z "$InputFile" ]; then
        printf '%s📂 Available .tar files in current directory:%s\n' "$dCyan" "$dReset"
        ls -1 *.tar 2>/dev/null || echo "(none)"
        echo
        read -r -p "Enter the path to the .tar file to load: " InputFile
    fi

    [ -z "$InputFile" ] && { printf '%s❌ No file path provided.%s\n' "$dRed" "$dReset"; return 1; }
    [ -f "$InputFile" ] || { printf '%s❌ File %s does not exist.%s\n' "$dRed" "$InputFile" "$dReset"; return 1; }

    printf '%s⬇️ Loading Docker image from %s...%s\n' "$dCyan" "$InputFile" "$dReset"

    docker load -i "$InputFile"
    d_show_result "✅ Image loaded successfully from '$InputFile'." "❌ Failed to load image from '$InputFile'."
}

# Usage: dHistoryImage [image[:tag]]
dHistoryImage() {
    d_check_cli || return 1
    local ImageName="$1"
    ImageName="$(d_resolve_image "$ImageName" "Enter the image name to view history (e.g. ubuntu:latest)")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }

    ImageName="$(d_complete_image "$ImageName")"

    d_image_exists "$ImageName" || { printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"; return 1; }

    printf '%s📜 Showing history for image %s:%s\n' "$dCyan" "$ImageName" "$dReset"

    docker history "$ImageName"
}

# Usage: dInspectImage [image[:tag]]
dInspectImage() {
    d_check_cli || return 1
    local ImageName="$1"
    ImageName="$(d_resolve_image "$ImageName" "Enter the image name to inspect (e.g. ubuntu:latest)")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }

    ImageName="$(d_complete_image "$ImageName")"

    d_image_exists "$ImageName" || { printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"; return 1; }

    printf '%s🔍 Inspecting image %s:%s\n' "$dCyan" "$ImageName" "$dReset"

    docker inspect "$ImageName"
}

# Usage: dImageDocs
dImageDocs() {
    d_doc_table "🐳 Docker Image Commands" \
        "dImages" "List all local Docker images" \
        "dBuildImage [folder] [tag] [--no-cache]" "Build a Docker image from a folder" \
        "dGetImage [image[:tag]]" "Pull a Docker image from a registry" \
        "dPushImage [image[:tag]]" "Push a local Docker image to a registry" \
        "dRemoveImage [image[:tag]] [-f]" "Remove a local Docker image" \
        "dPruneImage [-a] [-f]" "Remove unused/dangling images" \
        "dTagImage <source[:tag]> <target[:tag]>" "Tag a Docker image with a new reference" \
        "dSaveImage [image[:tag]] [file]" "Save a Docker image to a .tar archive" \
        "dLoadImage [file.tar]" "Load a Docker image from a .tar archive" \
        "dHistoryImage [image[:tag]]" "Show the layer history of an image" \
        "dInspectImage [image[:tag]]" "Show low-level image information"
}
