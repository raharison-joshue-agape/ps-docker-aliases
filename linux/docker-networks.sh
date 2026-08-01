# docker-networks.sh
# Container networking: list, create, inspect, connect, disconnect, remove,
# and prune networks.

# Usage: dNetworks
dNetworks() {
    d_check_cli || return 1
    docker network ls
}

# Usage: dCreateNetwork [name] [--driver bridge] [--subnet CIDR]
dCreateNetwork() {
    d_check_cli || return 1
    local NetworkName="" Driver="" Subnet=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --driver) Driver="$2"; shift 2 ;;
            --subnet) Subnet="$2"; shift 2 ;;
            *) NetworkName="$1"; shift ;;
        esac
    done

    NetworkName="$(d_read_value "Enter the name for the new Docker network" "$NetworkName")"
    [ -n "$NetworkName" ] || { printf '%s❌ No network name provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s🌐 Creating network '\''%s'\''...%s\n' "$dCyan" "$NetworkName" "$dReset"

    local cmd=(network create)
    [ -n "$Driver" ] && { cmd+=(--driver); cmd+=("$Driver"); }
    [ -n "$Subnet" ] && { cmd+=(--subnet); cmd+=("$Subnet"); }
    cmd+=("$NetworkName")

    docker "${cmd[@]}"
    d_show_result "✅ Network '$NetworkName' created successfully!" "❌ Failed to create network '$NetworkName'."
}

# Usage: dInspectNetwork [name]
dInspectNetwork() {
    d_check_cli || return 1
    local NetworkName
    NetworkName="$(d_read_value "Enter the name of the network to inspect" "${1:-}")"
    [ -n "$NetworkName" ] || { printf '%s❌ No network name provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s🔍 Inspecting network '\''%s'\''...%s\n' "$dCyan" "$NetworkName" "$dReset"

    docker network inspect "$NetworkName"
}

# Usage: dConnectNetwork [network] [container]
dConnectNetwork() {
    d_check_cli || return 1
    local NetworkName="${1:-}" ContainerName="${2:-}"

    if [ -z "$NetworkName" ]; then
        printf '%s📦 Available networks:%s\n' "$dCyan" "$dReset"
        docker network ls
        echo
        read -r -p "Enter the network name to connect: " NetworkName
    fi

    if [ -z "$ContainerName" ]; then
        printf '%s📦 Running containers:%s\n' "$dCyan" "$dReset"
        docker ps --format "table {{.Names}}\t{{.Status}}"
        echo
        read -r -p "Enter the container name or ID to connect: " ContainerName
    fi

    [ -n "$NetworkName" ] && [ -n "$ContainerName" ] || {
        printf '%s❌ Network or container name is missing.%s\n' "$dRed" "$dReset"; return 1; }

    d_network_exists "$NetworkName" || { printf '%s❌ Network '\''%s'\'' not found.%s\n' "$dRed" "$NetworkName" "$dReset"; return 1; }

    printf '%s🔗 Connecting '\''%s'\'' to network '\''%s'\''...%s\n' "$dCyan" "$ContainerName" "$NetworkName" "$dReset"

    docker network connect "$NetworkName" "$ContainerName"
    d_show_result "✅ Container '$ContainerName' connected to '$NetworkName'." "❌ Failed to connect container '$ContainerName' to '$NetworkName'."
}

# Usage: dDisconnectNetwork [network] [container]
dDisconnectNetwork() {
    d_check_cli || return 1
    local NetworkName="${1:-}" ContainerName="${2:-}"

    if [ -z "$NetworkName" ]; then
        printf '%s📦 Available networks:%s\n' "$dCyan" "$dReset"
        docker network ls
        echo
        read -r -p "Enter the network name to disconnect: " NetworkName
    fi

    if [ -z "$ContainerName" ]; then
        printf '%s📦 Connected containers:%s\n' "$dCyan" "$dReset"
        docker network inspect "$NetworkName" --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null
        echo
        read -r -p "Enter the container name or ID to disconnect: " ContainerName
    fi

    [ -n "$NetworkName" ] && [ -n "$ContainerName" ] || {
        printf '%s❌ Network or container name is missing.%s\n' "$dRed" "$dReset"; return 1; }

    d_network_exists "$NetworkName" || { printf '%s❌ Network '\''%s'\'' not found.%s\n' "$dRed" "$NetworkName" "$dReset"; return 1; }

    printf '%s🔌 Disconnecting '\''%s'\'' from '\''%s'\''...%s\n' "$dYellow" "$ContainerName" "$NetworkName" "$dReset"

    docker network disconnect "$NetworkName" "$ContainerName"
    d_show_result "✅ Container '$ContainerName' disconnected from '$NetworkName'." "❌ Failed to disconnect container '$ContainerName'."
}

# Usage: dRemoveNetwork [name]
dRemoveNetwork() {
    d_check_cli || return 1
    local NetworkName
    NetworkName="$(d_read_value "Enter the network name to remove" "${1:-}")"
    [ -n "$NetworkName" ] || { printf '%s❌ No network name provided.%s\n' "$dRed" "$dReset"; return 1; }

    d_network_exists "$NetworkName" || { printf '%s❌ Network '\''%s'\'' not found.%s\n' "$dRed" "$NetworkName" "$dReset"; return 1; }

    printf '%s🗑  Removing network '\''%s'\''...%s\n' "$dYellow" "$NetworkName" "$dReset"

    docker network rm "$NetworkName"
    d_show_result "✅ Network '$NetworkName' removed successfully!" "❌ Failed to remove network '$NetworkName'."
}

# Usage: dPruneNetwork [-f]
dPruneNetwork() {
    d_check_cli || return 1
    local Force=0 arg
    for arg in "$@"; do
        case "$arg" in
            -f|--force) Force=1 ;;
        esac
    done

    [ "$Force" -eq 0 ] && ! d_confirm "This will remove all unused Docker networks. Continue?" && return 1

    printf '%s🧹 Pruning unused Docker networks...%s\n' "$dCyan" "$dReset"

    docker network prune -f
    d_show_result "✅ Unused Docker networks removed successfully!" "❌ Failed to prune Docker networks."
}

# Usage: dNetworkDocs
dNetworkDocs() {
    d_doc_table "🐳 Docker Network Commands" \
        "dNetworks" "List all Docker networks" \
        "dCreateNetwork [name] [--driver] [--subnet]" "Create a new Docker network" \
        "dInspectNetwork [name]" "Inspect a Docker network" \
        "dConnectNetwork [network] [container]" "Connect a container to a network" \
        "dDisconnectNetwork [network] [container]" "Disconnect a container from a network" \
        "dRemoveNetwork [name]" "Remove a Docker network" \
        "dPruneNetwork [-f]" "Remove all unused Docker networks"
}
