# docker-swarm.sh
# Swarm cluster and service management: init, join, leave, nodes, services,
# scaling, logs, and stacks.

# Usage: dInitSwarm [--advertise-addr IP]
dInitSwarm() {
    d_check_cli || return 1
    local AdvertiseAddr=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --advertise-addr) AdvertiseAddr="$2"; shift 2 ;;
            *) printf '%s❌ Unknown option: %s%s\n' "$dRed" "$1" "$dReset"; return 1 ;;
        esac
    done

    printf '%s🚀 Initializing Docker Swarm cluster...%s\n' "$dCyan" "$dReset"

    local cmd=(swarm init)
    [ -n "$AdvertiseAddr" ] && { cmd+=(--advertise-addr); cmd+=("$AdvertiseAddr"); }

    docker "${cmd[@]}"
    d_show_result "✅ Docker Swarm initialized successfully!" "❌ Failed to initialize Docker Swarm."
}

# Usage: dJoinSwarm [token] [managerIP]
dJoinSwarm() {
    d_check_cli || return 1
    local JoinToken="${1:-}" ManagerIP="${2:-}"

    JoinToken="$(d_read_value "Enter the join token for the Swarm cluster" "$JoinToken")"
    ManagerIP="$(d_read_value "Enter the manager IP:Port (e.g., 192.168.1.10:2377)" "$ManagerIP")"

    [ -n "$JoinToken" ] && [ -n "$ManagerIP" ] || {
        printf '%s❌ Missing join token or manager address.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s🌐 Joining Docker Swarm cluster...%s\n' "$dCyan" "$dReset"

    docker swarm join --token "$JoinToken" "$ManagerIP"
    d_show_result "✅ Successfully joined Docker Swarm cluster!" "❌ Failed to join Docker Swarm cluster."
}

# Usage: dLeaveSwarm [-f]
dLeaveSwarm() {
    d_check_cli || return 1
    local Force=0 arg
    for arg in "$@"; do
        case "$arg" in
            -f|--force) Force=1 ;;
        esac
    done

    d_confirm "Leave the Docker Swarm cluster?" || return 1

    local cmd=(swarm leave)
    [ "$Force" -eq 1 ] && cmd+=(--force)

    docker "${cmd[@]}"
    d_show_result "✅ Left the Docker Swarm cluster." "❌ Failed to leave the Docker Swarm cluster."
}

# Usage: dSwarmToken [manager|worker]
dSwarmToken() {
    d_check_cli || return 1
    local Role="${1:-manager}"
    case "$Role" in
        manager|worker) ;;
        *) printf '%s❌ Invalid role '\''%s'\'' (use manager or worker).%s\n' "$dRed" "$Role" "$dReset"; return 1 ;;
    esac

    printf '%s🔑 Swarm %s join token:%s\n' "$dCyan" "$Role" "$dReset"

    docker swarm join-token "$Role"
}

# Usage: dNodes
dNodes() {
    d_check_cli || return 1
    docker node ls
}

# Usage: dServices
dServices() {
    d_check_cli || return 1
    docker service ls
}

# Usage: dCreateService [name] [image] [--replicas N] [--port P:P]
dCreateService() {
    d_check_cli || return 1
    local ServiceName="" Image="nginx" Replicas="" Port=""
    while [ $# -gt 0 ]; do
        case "$1" in
            --replicas) Replicas="$2"; shift 2 ;;
            --port|-p)  Port="$2"; shift 2 ;;
            *) [ -z "$ServiceName" ] && ServiceName="$1" || Image="$1"; shift ;;
        esac
    done

    ServiceName="$(d_read_value "Enter the service name" "$ServiceName")"
    [ -n "$ServiceName" ] || { printf '%s❌ Service name is required.%s\n' "$dRed" "$dReset"; return 1; }

    local cmd=(service create --name "$ServiceName")
    [ -n "$Replicas" ] && { cmd+=(--replicas); cmd+=("$Replicas"); }
    [ -n "$Port" ] && { cmd+=(-p); cmd+=("$Port"); }
    cmd+=("$Image")

    printf '%s🚀 Creating Swarm service '\''%s'\'' using image '\''%s'\''...%s\n' "$dCyan" "$ServiceName" "$Image" "$dReset"

    docker "${cmd[@]}"
    d_show_result "✅ Service '$ServiceName' created successfully!" "❌ Failed to create service '$ServiceName'."
}

# Usage: dRemoveService [name]
dRemoveService() {
    d_check_cli || return 1
    local ServiceName
    ServiceName="$(d_resolve_service "${1:-}")"
    [ -n "$ServiceName" ] || { printf '%s❌ Service name is required.%s\n' "$dRed" "$dReset"; return 1; }

    d_service_exists "$ServiceName" || { printf '%s❌ Service '\''%s'\'' not found.%s\n' "$dRed" "$ServiceName" "$dReset"; return 1; }

    printf '%s🗑  Removing service '\''%s'\''...%s\n' "$dYellow" "$ServiceName" "$dReset"

    docker service rm "$ServiceName"
    d_show_result "✅ Service '$ServiceName' removed successfully!" "❌ Failed to remove service '$ServiceName'."
}

# Usage: dScaleService [name] [replicas]
dScaleService() {
    d_check_cli || return 1
    local ServiceName="${1:-}" Replicas="${2:-1}"

    ServiceName="$(d_resolve_service "$ServiceName")"
    [ -n "$ServiceName" ] || { printf '%s❌ Service name is required.%s\n' "$dRed" "$dReset"; return 1; }

    d_service_exists "$ServiceName" || { printf '%s❌ Service '\''%s'\'' not found.%s\n' "$dRed" "$ServiceName" "$dReset"; return 1; }

    printf '%s🔢 Scaling service '\''%s'\'' to %s replicas...%s\n' "$dCyan" "$ServiceName" "$Replicas" "$dReset"

    docker service scale "$ServiceName=$Replicas"
    d_show_result "✅ Service '$ServiceName' scaled to $Replicas replicas!" "❌ Failed to scale service '$ServiceName'."
}

# Usage: dServiceLogs [name] [-f]
dServiceLogs() {
    d_check_cli || return 1
    local Follow=0 ServiceName=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -f|--follow) Follow=1; shift ;;
            *) ServiceName="$1"; shift ;;
        esac
    done

    ServiceName="$(d_resolve_service "$ServiceName")"
    [ -n "$ServiceName" ] || { printf '%s❌ Service name is required.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s📝 Showing logs for service '\''%s'\''...%s\n' "$dCyan" "$ServiceName" "$dReset"

    local cmd=(service logs)
    [ "$Follow" -eq 1 ] && cmd+=(-f)
    cmd+=("$ServiceName")

    docker "${cmd[@]}"
}

# Usage: dStackDeploy [stackName] [composeFile]
dStackDeploy() {
    d_check_cli || return 1
    local StackName="${1:-}" ComposeFile="${2:-docker-compose.yml}"

    StackName="$(d_read_value "Enter the stack name" "$StackName")"
    [ -n "$StackName" ] || { printf '%s❌ Stack name is required.%s\n' "$dRed" "$dReset"; return 1; }

    if [ ! -f "$ComposeFile" ]; then
        printf '%s❌ Compose file '\''%s'\'' not found.%s\n' "$dRed" "$ComposeFile" "$dReset"; return 1
    fi

    printf '%s🚀 Deploying stack '\''%s'\'' using '\''%s'\''...%s\n' "$dCyan" "$StackName" "$ComposeFile" "$dReset"

    docker stack deploy -c "$ComposeFile" "$StackName"
    d_show_result "✅ Stack '$StackName' deployed successfully!" "❌ Failed to deploy stack '$StackName'."
}

# Usage: dStacks
dStacks() {
    d_check_cli || return 1
    docker stack ls
}

# Usage: dStackRemove [stackName]
dStackRemove() {
    d_check_cli || return 1
    local StackName
    StackName="$(d_read_value "Enter the stack name to remove" "${1:-}")"
    [ -n "$StackName" ] || { printf '%s❌ Stack name is required.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s🗑  Removing stack '\''%s'\''...%s\n' "$dYellow" "$StackName" "$dReset"

    docker stack rm "$StackName"
    d_show_result "✅ Stack '$StackName' removed successfully!" "❌ Failed to remove stack '$StackName'."
}

# Usage: dSwarmDocs
dSwarmDocs() {
    d_doc_table "🐳 Docker Swarm Commands" \
        "dInitSwarm [--advertise-addr IP]" "Initialize a Docker Swarm cluster" \
        "dJoinSwarm [token] [managerIP]" "Join a Swarm cluster" \
        "dLeaveSwarm [-f]" "Leave the Swarm cluster" \
        "dSwarmToken [role]" "Show the manager/worker join token" \
        "dNodes" "List all Swarm nodes" \
        "dServices" "List all Swarm services" \
        "dCreateService [name] [image]" "Create a Swarm service" \
        "dRemoveService [name]" "Remove a Swarm service" \
        "dScaleService [name] [replicas]" "Scale a Swarm service" \
        "dServiceLogs [name] [-f]" "Show a service's logs" \
        "dStackDeploy [stackName] [composeFile]" "Deploy a stack from a compose file" \
        "dStacks" "List all deployed stacks" \
        "dStackRemove [stackName]" "Remove a deployed stack"
}
