# docker-helpers.zsh
# Shared internal helpers for every Docker command file (zsh).
# Keeps the command files short, consistent, and free of duplicated logic.

# ---------------- Colors ----------------
readonly dCyan=$'\033[36m'
readonly dYellow=$'\033[33m'
readonly dGreen=$'\033[32m'
readonly dRed=$'\033[31m'
readonly dGray=$'\033[90m'
readonly dReset=$'\033[0m'

# ---------------- CLI checks ----------------
# Returns 0 when the Docker CLI is available.
d_check_cli() {
    if ! command -v docker >/dev/null 2>&1; then
        printf '%s❌ Docker CLI not found. Please install Docker and restart your terminal.%s\n' "$dRed" "$dReset"
        return 1
    fi
    return 0
}

# ---------------- Prompts & results ----------------
# Asks for a Y/N confirmation before a destructive operation.
# Returns 0 when confirmed.
d_confirm() {
    local msg="${1:-Continue?}"
    local ans
    printf '%s⚠  %s (Y/N)%s ' "$dYellow" "$msg" "$dReset"
    read -r ans
    case "$ans" in
        [Yy]*) return 0 ;;
        *) printf '%s❌ Operation cancelled.%s\n' "$dRed" "$dReset" ; return 1 ;;
    esac
}

# Prints success/failure based on the exit code captured at call time.
# Returns 0 on success. MUST be called immediately after the docker command.
d_show_result() {
    local rc=$?
    local ok="${1:-✅ Done.}"
    local err="${2:-❌ Operation failed.}"
    if [ "$rc" -eq 0 ]; then
        [ -n "$ok" ] && printf '%s%s%s\n' "$dGreen" "$ok" "$dReset"
        return 0
    fi
    [ -n "$err" ] && printf '%s%s%s\n' "$dRed" "$err" "$dReset"
    return 1
}

# Returns the supplied value, or prompts the user when it is empty.
d_read_value() {
    local prompt="$1"
    local value="${2:-}"
    if [ -z "$value" ]; then
        read -r "value?$prompt: "
    fi
    printf '%s' "$value"
}

# ---------------- Images ----------------
# Appends ":latest" to an image name when no tag is given.
d_complete_image() {
    case "$1" in
        *:*) printf '%s' "$1" ;;
        *) printf '%s:latest' "$1" ;;
    esac
}

# Returns local images formatted as "repository:tag".
d_local_images() {
    docker images --format "{{.Repository}}:{{.Tag}}" 2>/dev/null
}

# Returns 0 when a local image exists (auto-adds ":latest").
d_image_exists() {
    [ -z "$1" ] && return 1
    local img
    img="$(d_complete_image "$1")"
    d_local_images | grep -qxF "$img"
}

# Prints the local image table.
d_show_images() {
    docker images
}

# Prompts for an image name, listing local images first when needed.
d_resolve_image() {
    local name="${1:-}"
    local prompt="${2:-Enter the image name (e.g. nginx or nginx:latest)}"
    if [ -z "$name" ]; then
        printf '%s📦 Available local images:%s\n' "$dCyan" "$dReset"
        d_show_images
        echo
        read -r "name?$prompt: "
    fi
    printf '%s' "$name"
}

# ---------------- Containers ----------------
# Prints a container table. Mode: '' (running), -a (all), paused, stopped.
d_show_containers() {
    local mode="${1:-}"
    case "$mode" in
        -a|--all) docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" ;;
        paused)   docker ps --filter "status=paused" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" ;;
        stopped)  docker ps --filter "status=exited" --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" ;;
        *)        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" ;;
    esac
}

# Returns container names. Mode: '' (running), -a (all), paused.
d_container_names() {
    local mode="${1:-}"
    case "$mode" in
        -a|--all) docker ps -a --format "{{.Names}}" 2>/dev/null ;;
        paused)   docker ps --filter "status=paused" --format "{{.Names}}" 2>/dev/null ;;
        *)        docker ps --format "{{.Names}}" 2>/dev/null ;;
    esac
}

# Returns 0 when a container exists (exact name or ID prefix).
d_container_exists() {
    local name="${1:-}"
    [ -z "$name" ] && return 1
    if d_container_names -a | grep -qxF "$name"; then return 0; fi
    local id
    while read -r id; do
        case "$id" in
            "$name"*) return 0 ;;
        esac
    done < <(docker ps -a --format "{{.ID}}" 2>/dev/null)
    return 1
}

# Returns 0 when a container is currently running (name or ID prefix).
d_container_running() {
    local name="${1:-}"
    [ -z "$name" ] && return 1
    if d_container_names | grep -qxF "$name"; then return 0; fi
    local id
    while read -r id; do
        case "$id" in
            "$name"*) return 0 ;;
        esac
    done < <(docker ps --format "{{.ID}}" 2>/dev/null)
    return 1
}

# Prompts for a container name, listing containers first when needed.
# Mode is passed through to d_show_containers.
d_resolve_container() {
    local name="${1:-}"
    local prompt="${2:-Enter the container name or ID}"
    local mode="${3:-}"
    if [ -z "$name" ]; then
        printf '%s📦 Available containers:%s\n' "$dCyan" "$dReset"
        d_show_containers "$mode"
        echo
        read -r "name?$prompt: "
    fi
    printf '%s' "$name"
}

# ---------------- Volumes ----------------
d_volume_names() {
    docker volume ls --format "{{.Name}}" 2>/dev/null
}

d_volume_exists() {
    [ -z "$1" ] && return 1
    d_volume_names | grep -qxF "$1"
}

# ---------------- Networks ----------------
d_network_names() {
    docker network ls --format "{{.Name}}" 2>/dev/null
}

d_network_exists() {
    [ -z "$1" ] && return 1
    d_network_names | grep -qxF "$1"
}

# ---------------- Swarm services ----------------
d_service_names() {
    docker service ls --format "{{.Name}}" 2>/dev/null
}

d_service_exists() {
    [ -z "$1" ] && return 1
    d_service_names | grep -qxF "$1"
}

# Prompts for a service name, listing services first when needed.
d_resolve_service() {
    local name="${1:-}"
    local prompt="${2:-Enter the service name}"
    if [ -z "$name" ]; then
        printf '%s📦 Available services:%s\n' "$dCyan" "$dReset"
        docker service ls --format "table {{.Name}}\t{{.Mode}}\t{{.Replicas}}" 2>/dev/null
        echo
        read -r "name?$prompt: "
    fi
    printf '%s' "$name"
}

# ---------------- Documentation table ----------------
# Prints an aligned command/description reference table.
# Usage: d_doc_table "TITLE" "cmd" "desc" "cmd" "desc" ...
d_doc_table() {
    local title="${1:-}"
    shift
    if [ -n "$title" ]; then
        echo
        printf '%s%s%s\n' "$dCyan" "$title" "$dReset"
    fi
    printf '%-50s %s\n' "COMMAND" "DESCRIPTION"
    printf '%*s\n' 130 '' | tr ' ' '-'
    while [ $# -gt 0 ]; do
        printf '%-50s %s\n' "$1" "$2"
        shift 2
    done
    echo
}
