# docker-compose.sh
# Docker Compose multi-container orchestration: up, down, build, logs, exec,
# restart, pull, config validation, and stop. Arguments are always passed as
# arrays to the Docker CLI (no eval).

# Resolves the compose file (docker-compose.yml / compose.yaml / ...) in a path.
d_get_compose_file() {
    local path="${1:-.}"
    local f
    for f in docker-compose.yml docker-compose.yaml compose.yaml compose.yml; do
        if [ -f "$path/$f" ]; then
            echo "$path/$f"
            return 0
        fi
    done
    return 1
}

# Prompts for a service name, listing compose services first when needed.
d_resolve_compose_service() {
    local service="${1:-}"
    local cf="$2"
    local prompt="${3:-Enter the service name}"
    if [ -z "$service" ]; then
        printf '%s📦 Available services:%s\n' "$dCyan" "$dReset"
        docker compose -f "$cf" ps --services 2>/dev/null
        echo
        read -r -p "$prompt: " service
    fi
    printf '%s' "$service"
}

# Usage: dComposes [path]
dComposes() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s📦 Listing Docker Compose services...%s\n' "$dCyan" "$dReset"

    docker compose -f "$cf" ps
}

# Usage: dComposeUp [path] [-d|--detached] [-b|--build]
dComposeUp() {
    d_check_cli || return 1
    local Path="." detached=0 build=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -d|--detached) detached=1; shift ;;
            -b|--build)    build=1; shift ;;
            -p|--path)     Path="$2"; shift 2 ;;
            *)             Path="$1"; shift ;;
        esac
    done

    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s🚀 Starting Docker Compose services...%s\n' "$dCyan" "$dReset"

    local cmd=(compose -f "$cf" up)
    [ "$detached" -eq 1 ] && cmd+=(-d)
    [ "$build" -eq 1 ] && cmd+=(--build)

    docker "${cmd[@]}"
}

# Usage: dComposeDown [path] [-v|--volumes] [--remove-orphans]
dComposeDown() {
    d_check_cli || return 1
    local Path="." volumes=0 orphans=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -v|--volumes)       volumes=1; shift ;;
            --remove-orphans)   orphans=1; shift ;;
            -p|--path)          Path="$2"; shift 2 ;;
            *)                  Path="$1"; shift ;;
        esac
    done

    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s🛑 Stopping Docker Compose services...%s\n' "$dYellow" "$dReset"

    local cmd=(compose -f "$cf" down)
    [ "$volumes" -eq 1 ] && cmd+=(-v)
    [ "$orphans" -eq 1 ] && cmd+=(--remove-orphans)

    docker "${cmd[@]}"
}

# Usage: dComposeBuild [path]
dComposeBuild() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s🔨 Building Docker Compose services...%s\n' "$dCyan" "$dReset"

    docker compose -f "$cf" build
}

# Usage: dComposeLogs [path] [service] [-f|--follow] [-n|--tail N]
dComposeLogs() {
    d_check_cli || return 1
    local Path="." Service="" follow=0 tail=0
    while [ $# -gt 0 ]; do
        case "$1" in
            -f|--follow) follow=1; shift ;;
            -n|--tail)   tail="$2"; shift 2 ;;
            -p|--path)   Path="$2"; shift 2 ;;
            *)           Service="$1"; shift ;;
        esac
    done

    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s📝 Showing Docker Compose logs...%s\n' "$dCyan" "$dReset"

    local cmd=(compose -f "$cf" logs)
    [ "$follow" -eq 1 ] && cmd+=(-f)
    [ "$tail" -ne 0 ] && cmd+=(--tail "$tail")
    [ -n "$Service" ] && cmd+=("$Service")

    docker "${cmd[@]}"
}

# Usage: dComposeExec [path] [service] [command]
dComposeExec() {
    d_check_cli || return 1
    local Path="." Service="" Command="bash"
    while [ $# -gt 0 ]; do
        case "$1" in
            -p|--path) Path="$2"; shift 2 ;;
            *) [ -z "$Service" ] && Service="$1" || Command="$1"; shift ;;
        esac
    done

    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    Service="$(d_resolve_compose_service "$Service" "$cf")"
    [ -z "$Service" ] && { printf '%s❌ No service provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s💻 Executing %s in service %s...%s\n' "$dCyan" "$Command" "$Service" "$dReset"

    local cmd=(compose -f "$cf" exec -it "$Service")
    read -r -a cmd_parts <<< "$Command"
    cmd+=("${cmd_parts[@]}")

    docker "${cmd[@]}"
}

# Usage: dComposeRestart [path]
dComposeRestart() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s🔄 Restarting Docker Compose services...%s\n' "$dYellow" "$dReset"

    docker compose -f "$cf" restart
}

# Usage: dComposePull [path]
dComposePull() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s⬇️ Pulling Docker Compose images...%s\n' "$dCyan" "$dReset"

    docker compose -f "$cf" pull
}

# Usage: dComposeStop [path]
dComposeStop() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s🛑 Stopping Docker Compose services (containers kept)...%s\n' "$dYellow" "$dReset"

    docker compose -f "$cf" stop
}

# Usage: dComposeConfig [path]
dComposeConfig() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s📄 Docker Compose configuration:%s\n' "$dCyan" "$dReset"

    docker compose -f "$cf" config
}

# Usage: dComposeValidate [path]
dComposeValidate() {
    d_check_cli || return 1
    local Path="${1:-.}"
    local cf
    cf="$(d_get_compose_file "$Path")" || { printf '%s❌ No Docker Compose file found in %s.%s\n' "$dRed" "$Path" "$dReset"; return 1; }

    printf '%s🔎 Validating Docker Compose file...%s\n' "$dCyan" "$dReset"

    docker compose -f "$cf" config -q
    d_show_result "✅ Compose file is valid." "❌ Compose file is invalid."
}

dComposeDocs() {
    d_doc_table "🐳 Docker Compose Commands" \
        "dComposes [path]" "List Docker Compose services" \
        "dComposeUp [path] [-d] [-b]" "Start Compose services" \
        "dComposeDown [path] [-v] [--remove-orphans]" "Stop and remove Compose services" \
        "dComposeBuild [path]" "Build Compose service images" \
        "dComposeLogs [path] [service] [-f] [-n N]" "Show service logs" \
        "dComposeExec [path] [service] [command]" "Execute a command in a service" \
        "dComposeRestart [path]" "Restart Compose services" \
        "dComposePull [path]" "Pull Compose images" \
        "dComposeStop [path]" "Stop services (keep containers)" \
        "dComposeConfig [path]" "Show merged Compose configuration" \
        "dComposeValidate [path]" "Validate the Compose file"
}
