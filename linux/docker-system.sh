# docker-system.sh
# Docker engine information, disk usage, cleanup, events, and registry auth.

# Usage: dVersion
dVersion() {
    d_check_cli || return 1
    docker --version
}

# Usage: dInfo
dInfo() {
    d_check_cli || return 1
    docker info
}

# Usage: dDiskSystem
dDiskSystem() {
    d_check_cli || return 1
    printf '%s📊 Docker disk usage:%s\n' "$dCyan" "$dReset"
    docker system df
}

# Usage: dEvents
dEvents() {
    d_check_cli || return 1
    printf '%s👀 Streaming Docker events (Press Ctrl + C to exit)...%s\n' "$dCyan" "$dReset"
    docker system events
}

# Usage: dPruneSystem [-v|--volumes]
dPruneSystem() {
    d_check_cli || return 1
    local volumes=0
    local arg
    for arg in "$@"; do
        case "$arg" in
            -v|--volumes) volumes=1 ;;
        esac
    done

    local what="unused containers, images, networks"
    [ "$volumes" -eq 1 ] && what="$what, and volumes"

    d_confirm "This will remove $what. Continue?" || return 1

    printf '%s🧹 Cleaning Docker system...%s\n' "$dCyan" "$dReset"

    if [ "$volumes" -eq 1 ]; then
        docker system prune -a -f --volumes
    else
        docker system prune -a -f
    fi
    d_show_result "✅ Docker system cleaned successfully." "❌ Failed to clean Docker system."
}

# Usage: dLogin [registry]
dLogin() {
    d_check_cli || return 1
    local registry="${1:-}"
    if [ -z "$registry" ]; then
        read -r -p "Enter the Docker registry (default: docker.io): " registry
    fi
    [ -z "$registry" ] && registry="docker.io"

    printf '%s🔑 Logging in to registry %s...%s\n' "$dCyan" "$registry" "$dReset"

    docker login "$registry"
    d_show_result "✅ Logged in successfully to '$registry'." "❌ Failed to log in to '$registry'."
}

# Usage: dLogout [registry]
dLogout() {
    d_check_cli || return 1
    local registry="${1:-}"
    if [ -z "$registry" ]; then
        read -r -p "Enter the Docker registry to log out from (default: docker.io): " registry
    fi
    [ -z "$registry" ] && registry="docker.io"

    printf '%s🔓 Logging out from registry %s...%s\n' "$dCyan" "$registry" "$dReset"

    docker logout "$registry"
    d_show_result "✅ Logged out successfully from '$registry'." "❌ Failed to log out from '$registry'."
}
