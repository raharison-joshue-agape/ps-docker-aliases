# docker-containers.sh
# Container lifecycle management: create, run, start, stop, restart, kill,
# remove, logs, exec, attach, inspect, and file transfer between host/container.

# Usage: dContainers [-a|--all]
dContainers() {
    d_check_cli || return 1
    local all=0 arg
    for arg in "$@"; do
        case "$arg" in
            -a|--all) all=1 ;;
        esac
    done

    local cmd=(ps)
    [ "$all" -eq 1 ] && cmd+=(-a)

    docker "${cmd[@]}"
}

# Usage: dRunContainer [image] [--name NAME] [-d|--detach] [--rm] [-it]
#                         [-p PORT]... [-v VOLUME]... [-e ENV]... [--network NET]
#                         [--restart POLICY] [--pull] [-- extra-args...]
dRunContainer() {
    d_check_cli || return 1
    local ImageName="" ContainerName="" Network="" Restart="" ExtraArgs=""
    local Detach=0 Remove=0 Interactive=0 Pull=0
    local -a Ports=() Volumes=() Env=() Cmd=(run)

    while [ $# -gt 0 ]; do
        case "$1" in
            -n|--name)        ContainerName="$2"; shift 2 ;;
            -d|--detach)      Detach=1; shift ;;
            -rm|--rm)         Remove=1; shift ;;
            -it|--interactive) Interactive=1; shift ;;
            -p|--port)        Ports+=("$2"); shift 2 ;;
            -v|--volume)      Volumes+=("$2"); shift 2 ;;
            -e|--env)         Env+=("$2"); shift 2 ;;
            --network)        Network="$2"; shift 2 ;;
            --restart)        Restart="$2"; shift 2 ;;
            --pull)           Pull=1; shift ;;
            --)               shift; ExtraArgs="$*"; break ;;
            -*)               printf '%s❌ Unknown option: %s%s\n' "$dRed" "$1" "$dReset"; return 1 ;;
            *)                ImageName="$1"; shift ;;
        esac
    done

    ImageName="$(d_resolve_image "$ImageName")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }
    ImageName="$(d_complete_image "$ImageName")"

    if ! d_image_exists "$ImageName"; then
        if [ "$Pull" -eq 1 ] || d_confirm "Image '$ImageName' is not local. Pull it now?"; then
            docker pull "$ImageName" || return 1
        else
            printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"
            return 1
        fi
    fi

    [ "$Detach" -eq 1 ] && Cmd+=(-d)
    [ "$Remove" -eq 1 ] && Cmd+=(--rm)
    [ "$Interactive" -eq 1 ] && Cmd+=(-it)
    [ -n "$ContainerName" ] && Cmd+=(--name "$ContainerName")

    local p v e
    for p in "${Ports[@]}"; do Cmd+=(-p "$p"); done
    for v in "${Volumes[@]}"; do Cmd+=(-v "$v"); done
    for e in "${Env[@]}"; do Cmd+=(-e "$e"); done

    [ -n "$Network" ] && Cmd+=(--network "$Network")
    [ -n "$Restart" ] && Cmd+=(--restart "$Restart")

    # shellcheck disable=SC2206
    [ -n "$ExtraArgs" ] && Cmd+=($ExtraArgs)

    Cmd+=("$ImageName")

    printf '%s🚀 Running: docker %s%s\n' "$dCyan" "${Cmd[*]}" "$dReset"

    docker "${Cmd[@]}"
    d_show_result "✅ Container from '$ImageName' started successfully!" "❌ Failed to start container from '$ImageName'."
}

# Usage: dCreateContainer [image] [--name NAME] [-p PORT]... [-v VOLUME]... [-e ENV]... [--network NET]
dCreateContainer() {
    d_check_cli || return 1
    local ImageName="" ContainerName="" Network="" ExtraArgs=""
    local -a Ports=() Volumes=() Env=() Cmd=(create)

    while [ $# -gt 0 ]; do
        case "$1" in
            -n|--name)   ContainerName="$2"; shift 2 ;;
            -p|--port)   Ports+=("$2"); shift 2 ;;
            -v|--volume) Volumes+=("$2"); shift 2 ;;
            -e|--env)    Env+=("$2"); shift 2 ;;
            --network)   Network="$2"; shift 2 ;;
            --)          shift; ExtraArgs="$*"; break ;;
            -*)          printf '%s❌ Unknown option: %s%s\n' "$dRed" "$1" "$dReset"; return 1 ;;
            *)           ImageName="$1"; shift ;;
        esac
    done

    ImageName="$(d_resolve_image "$ImageName")"
    [ -z "$ImageName" ] && { printf '%s❌ No image name provided.%s\n' "$dRed" "$dReset"; return 1; }
    ImageName="$(d_complete_image "$ImageName")"

    d_image_exists "$ImageName" || { printf '%s❌ Image %s not found locally.%s\n' "$dRed" "$ImageName" "$dReset"; return 1; }

    [ -n "$ContainerName" ] && Cmd+=(--name "$ContainerName")

    local p v e
    for p in "${Ports[@]}"; do Cmd+=(-p "$p"); done
    for v in "${Volumes[@]}"; do Cmd+=(-v "$v"); done
    for e in "${Env[@]}"; do Cmd+=(-e "$e"); done

    [ -n "$Network" ] && Cmd+=(--network "$Network")

    # shellcheck disable=SC2206
    [ -n "$ExtraArgs" ] && Cmd+=($ExtraArgs)

    Cmd+=("$ImageName")

    printf '%s🛠 Creating: docker %s%s\n' "$dCyan" "${Cmd[*]}" "$dReset"

    docker "${Cmd[@]}"
    d_show_result "✅ Container from '$ImageName' created successfully!" "❌ Failed to create container from '$ImageName'."
}

# Usage: dStartContainer [name]
dStartContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to start" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s🚀 Starting container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker start "$ContainerName"
    d_show_result "✅ Container '$ContainerName' started successfully!" "❌ Failed to start container '$ContainerName'."
}

# Usage: dStopContainer [name]
dStopContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to stop")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running or does not exist.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s🛑 Stopping container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker stop "$ContainerName"
    d_show_result "✅ Container '$ContainerName' stopped successfully!" "❌ Failed to stop container '$ContainerName'."
}

# Usage: dRestartContainer [name]
dRestartContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to restart" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s🔄 Restarting container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker restart "$ContainerName"
    d_show_result "✅ Container '$ContainerName' restarted successfully!" "❌ Failed to restart container '$ContainerName'."
}

# Usage: dKillContainer [name]
dKillContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to kill" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s💀 Killing container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker kill "$ContainerName"
    d_show_result "✅ Container '$ContainerName' killed successfully!" "❌ Failed to kill container '$ContainerName'."
}

# Usage: dRemoveContainer [name] [-f|--force] [-v|--volumes]
dRemoveContainer() {
    d_check_cli || return 1
    local ContainerName="" force=0 volumes=0
    local arg
    for arg in "$@"; do
        case "$arg" in
            -f|--force)   force=1 ;;
            -v|--volumes) volumes=1 ;;
            *)            ContainerName="$arg" ;;
        esac
    done

    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to remove" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    if [ "$force" -eq 0 ]; then
        d_confirm "You are about to remove container '$ContainerName'. Continue?" || return 1
    fi

    printf '%s🗑️ Removing container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    local cmd=(rm)
    [ "$force" -eq 1 ] && cmd+=(-f)
    [ "$volumes" -eq 1 ] && cmd+=(-v)
    cmd+=("$ContainerName")

    docker "${cmd[@]}"
    d_show_result "✅ Container '$ContainerName' removed successfully!" "❌ Failed to remove container '$ContainerName'."
}

# Usage: dLogsContainer [name] [-f|--follow] [-n|--tail N]
dLogsContainer() {
    d_check_cli || return 1
    local ContainerName="" follow=0 tail=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -f|--follow) follow=1; shift ;;
            -n|--tail)   tail="$2"; shift 2 ;;
            *)           ContainerName="$1"; shift ;;
        esac
    done

    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to view logs" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s📝 Displaying logs for container %s:%s\n' "$dCyan" "$ContainerName" "$dReset"

    local cmd=(logs)
    [ "$follow" -eq 1 ] && cmd+=(-f)
    [ "$tail" -ne 0 ] && cmd+=(--tail "$tail")
    cmd+=("$ContainerName")

    docker "${cmd[@]}"
}

# Usage: dExecContainer [name] [command...] [-d|--detach]
dExecContainer() {
    d_check_cli || return 1
    local ContainerName="" detach=0
    local -a CmdArgs=()
    while [ $# -gt 0 ]; do
        case "$1" in
            -d|--detach) detach=1; shift ;;
            *) [ -z "$ContainerName" ] && ContainerName="$1" || CmdArgs+=("$1"); shift ;;
        esac
    done
    [ "${#CmdArgs[@]}" -eq 0 ] && CmdArgs=(bash)

    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to execute a command")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    local cmd_str="${CmdArgs[*]}"
    printf '%s💻 Executing %s in container %s...%s\n' "$dCyan" "$cmd_str" "$ContainerName" "$dReset"

    local cmd=(exec)
    if [ "$detach" -eq 1 ]; then
        cmd+=(-d)
    else
        cmd+=(-it)
    fi
    cmd+=("$ContainerName" "${CmdArgs[@]}")

    docker "${cmd[@]}"
}

# Usage: dAttachContainer [name]
dAttachContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to attach")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s🔗 Attaching to container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker attach "$ContainerName"
}

# Usage: dTopContainer [name]
dTopContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to view processes")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running or does not exist.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s📊 Processes for container %s:%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker top "$ContainerName"
}

# Usage: dStatsContainer [-a|--all]
dStatsContainer() {
    d_check_cli || return 1
    local all=0 arg
    for arg in "$@"; do
        case "$arg" in
            -a|--all) all=1 ;;
        esac
    done

    printf '%s📊 Docker container stats (Press Ctrl + C to exit)...%s\n' "$dCyan" "$dReset"

    local cmd=(stats)
    [ "$all" -eq 1 ] && cmd+=(-a)

    docker "${cmd[@]}"
}

# Usage: dWaitContainer [name]
dWaitContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to wait for")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running or does not exist.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s⏳ Waiting for container %s to stop...%s\n' "$dYellow" "$ContainerName" "$dReset"

    docker wait "$ContainerName" >/dev/null
    d_show_result "✅ Container '$ContainerName' has stopped." "❌ Failed to wait for container '$ContainerName'."
}

# Usage: dRenameContainer [name] [new-name]
dRenameContainer() {
    d_check_cli || return 1
    local ContainerName="${1:-}" NewName="${2:-}"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to rename" -a)"
    [ -z "$NewName" ] && read -r -p "Enter the new container name: " NewName

    if [ -z "$ContainerName" ] || [ -z "$NewName" ]; then
        printf '%s❌ Missing container name or new name.%s\n' "$dRed" "$dReset"
        return 1
    fi
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s✏️ Renaming %s → %s...%s\n' "$dCyan" "$ContainerName" "$NewName" "$dReset"

    docker rename "$ContainerName" "$NewName"
    d_show_result "✅ Container renamed successfully!" "❌ Failed to rename container '$ContainerName'."
}

# Usage: dUpdateContainer [name] [options]
dUpdateContainer() {
    d_check_cli || return 1
    local ContainerName="${1:-}" Options="${2:-}"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to update" -a)"
    [ -z "$Options" ] && read -r -p "Enter update options (e.g. --memory 512m): " Options

    if [ -z "$ContainerName" ] || [ -z "$Options" ]; then
        printf '%s❌ Missing container name or options.%s\n' "$dRed" "$dReset"
        return 1
    fi
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s⚙️ Updating container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    local cmd=(update)
    read -r -a opts <<< "$Options"
    cmd+=("${opts[@]}" "$ContainerName")

    docker "${cmd[@]}"
    d_show_result "✅ Container updated successfully!" "❌ Failed to update container '$ContainerName'."
}

# Usage: dPauseContainer [name]
dPauseContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to pause")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s⏸️ Pausing container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker pause "$ContainerName"
    d_show_result "✅ Container paused successfully!" "❌ Failed to pause container '$ContainerName'."
}

# Usage: dUnpauseContainer [name]
dUnpauseContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to unpause" paused)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s▶️ Resuming container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker unpause "$ContainerName"
    d_show_result "✅ Container '$ContainerName' resumed successfully!" "❌ Failed to unpause container '$ContainerName'."
}

# Usage: dExportContainer [name] [output-file]
dExportContainer() {
    d_check_cli || return 1
    local ContainerName="${1:-}" OutputFile="${2:-}"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to export" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    [ -z "$OutputFile" ] && OutputFile="$ContainerName.tar"

    printf '%s📤 Exporting container %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker export "$ContainerName" -o "$OutputFile"
    d_show_result "✅ Container exported to '$OutputFile' successfully!" "❌ Failed to export container '$ContainerName'."
}

# Usage: dCommitContainer [name] [image] [-m MESSAGE] [-a AUTHOR]
dCommitContainer() {
    d_check_cli || return 1
    local ContainerName="" ImageName="" Message="" Author=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -m|--message) Message="$2"; shift 2 ;;
            -a|--author)  Author="$2"; shift 2 ;;
            *) [ -z "$ContainerName" ] && ContainerName="$1" || ImageName="$1"; shift ;;
        esac
    done

    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to commit" -a)"
    [ -z "$ImageName" ] && read -r -p "Enter the new image name (e.g. myapp:latest): " ImageName

    if [ -z "$ContainerName" ] || [ -z "$ImageName" ]; then
        printf '%s❌ Missing container name or image name.%s\n' "$dRed" "$dReset"
        return 1
    fi
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s📸 Committing container %s → %s...%s\n' "$dCyan" "$ContainerName" "$ImageName" "$dReset"

    local cmd=(commit)
    [ -n "$Message" ] && cmd+=(-m "$Message")
    [ -n "$Author" ] && cmd+=(-a "$Author")
    cmd+=("$ContainerName" "$ImageName")

    docker "${cmd[@]}"
    d_show_result "✅ Container committed successfully as '$ImageName'!" "❌ Failed to commit container '$ContainerName'."
}

# Usage: dDiffContainer [name]
dDiffContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to diff" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s📊 Showing filesystem changes for %s...%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker diff "$ContainerName"
}

# Usage: dCpContainer <source> <destination>
dCpContainer() {
    d_check_cli || return 1
    local Source="${1:-}" Destination="${2:-}"
    [ -z "$Source" ] && read -r -p "Enter source path (host or container): " Source
    [ -z "$Destination" ] && read -r -p "Enter destination path (host or container): " Destination

    if [ -z "$Source" ] || [ -z "$Destination" ]; then
        printf '%s❌ Missing source or destination path.%s\n' "$dRed" "$dReset"
        return 1
    fi

    printf '%s📁 Copying: %s → %s%s\n' "$dCyan" "$Source" "$Destination" "$dReset"

    docker cp "$Source" "$Destination"
    d_show_result "✅ Copy completed successfully!" "❌ Copy operation failed."
}

# Usage: dInspectContainer [name]
dInspectContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to inspect" -a)"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_exists "$ContainerName" || { printf '%s❌ Container %s not found.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s🔍 Inspecting container %s:%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker inspect "$ContainerName"
}

# Usage: dPortContainer [name]
dPortContainer() {
    d_check_cli || return 1
    local ContainerName="$1"
    ContainerName="$(d_resolve_container "$ContainerName" "Enter the container name or ID to view ports")"
    [ -z "$ContainerName" ] && { printf '%s❌ No container name provided.%s\n' "$dRed" "$dReset"; return 1; }
    d_container_running "$ContainerName" || { printf '%s❌ Container %s is not running.%s\n' "$dRed" "$ContainerName" "$dReset"; return 1; }

    printf '%s🔌 Port mapping for container %s:%s\n' "$dCyan" "$ContainerName" "$dReset"

    docker port "$ContainerName"
}

# Usage: dContainerDocs
dContainerDocs() {
    d_doc_table "🐳 Docker Container Commands" \
        "dContainers [-a]" "List containers (running by default, all with -a)" \
        "dRunContainer <image> [name] [flags]" "Run a container (detach, ports, volumes, env, network...)" \
        "dCreateContainer <image> [name] [flags]" "Create a container without starting it" \
        "dStartContainer [name]" "Start a stopped container" \
        "dStopContainer [name]" "Stop a running container" \
        "dRestartContainer [name]" "Restart a container" \
        "dKillContainer [name]" "Force stop (kill) a container" \
        "dRemoveContainer [name] [-f] [-v]" "Remove a container" \
        "dLogsContainer [name] [-f] [-n N]" "Show container logs" \
        "dExecContainer [name] [command...]" "Execute a command inside a running container" \
        "dAttachContainer [name]" "Attach to a container terminal" \
        "dTopContainer [name]" "Show running processes inside a container" \
        "dStatsContainer [-a]" "Show live resource usage for containers" \
        "dWaitContainer [name]" "Wait until a container stops" \
        "dRenameContainer [name] [newName]" "Rename a container" \
        "dUpdateContainer [name] [options]" "Update container resources (CPU, memory...)" \
        "dPauseContainer [name]" "Pause a running container" \
        "dUnpauseContainer [name]" "Resume a paused container" \
        "dExportContainer [name] [file]" "Export a container filesystem to a tar file" \
        "dCommitContainer [name] [image]" "Create a new image from a container" \
        "dDiffContainer [name]" "Show filesystem changes inside a container" \
        "dCpContainer <source> <destination>" "Copy files between host and container" \
        "dInspectContainer [name]" "Show low-level container information" \
        "dPortContainer [name]" "Show a container's public port mapping"
}
