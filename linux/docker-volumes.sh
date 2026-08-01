# docker-volumes.sh
# Persistent storage management: list, create, inspect, remove, and prune volumes.

# Usage: dVolumes
dVolumes() {
    d_check_cli || return 1
    docker volume ls
}

# Usage: dCreateVolume [name]
dCreateVolume() {
    d_check_cli || return 1
    local VolumeName
    VolumeName="$(d_read_value "Enter the name for the new Docker volume" "${1:-}")"
    [ -n "$VolumeName" ] || { printf '%s❌ No volume name provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s📦 Creating volume '\''%s'\''...%s\n' "$dCyan" "$VolumeName" "$dReset"

    docker volume create "$VolumeName"
    d_show_result "✅ Volume '$VolumeName' created successfully!" "❌ Failed to create volume '$VolumeName'."
}

# Usage: dInspectVolume [name]
dInspectVolume() {
    d_check_cli || return 1
    local VolumeName
    VolumeName="$(d_read_value "Enter the name of the volume to inspect" "${1:-}")"
    [ -n "$VolumeName" ] || { printf '%s❌ No volume name provided.%s\n' "$dRed" "$dReset"; return 1; }

    printf '%s🔍 Inspecting volume '\''%s'\''...%s\n' "$dCyan" "$VolumeName" "$dReset"

    docker volume inspect "$VolumeName"
}

# Usage: dRemoveVolume [name] [-f]
dRemoveVolume() {
    d_check_cli || return 1
    local Force=0 VolumeName=""
    while [ $# -gt 0 ]; do
        case "$1" in
            -f|--force) Force=1; shift ;;
            *) VolumeName="$1"; shift ;;
        esac
    done

    if [ -z "$VolumeName" ]; then
        printf '%s📦 Available volumes:%s\n' "$dCyan" "$dReset"
        docker volume ls
        echo
        read -r -p "Enter the name of the volume to remove: " VolumeName
    fi
    [ -n "$VolumeName" ] || { printf '%s❌ No volume name provided.%s\n' "$dRed" "$dReset"; return 1; }

    d_volume_exists "$VolumeName" || { printf '%s❌ Volume '\''%s'\'' not found.%s\n' "$dRed" "$VolumeName" "$dReset"; return 1; }

    [ "$Force" -eq 0 ] && ! d_confirm "You are about to remove volume '$VolumeName'. Continue?" && return 1

    printf '%s🗑  Removing volume '\''%s'\''...%s\n' "$dYellow" "$VolumeName" "$dReset"

    docker volume rm "$VolumeName"
    d_show_result "✅ Volume removed successfully!" "❌ Failed to remove volume '$VolumeName'."
}

# Usage: dPruneVolume [-f]
dPruneVolume() {
    d_check_cli || return 1
    local Force=0 arg
    for arg in "$@"; do
        case "$arg" in
            -f|--force) Force=1 ;;
        esac
    done

    [ "$Force" -eq 0 ] && ! d_confirm "This will remove all unused Docker volumes. Continue?" && return 1

    printf '%s🧹 Removing unused Docker volumes...%s\n' "$dCyan" "$dReset"

    docker volume prune -f
    d_show_result "✅ Unused Docker volumes removed successfully!" "❌ Failed to prune Docker volumes."
}

# Usage: dVolumeDocs
dVolumeDocs() {
    d_doc_table "🐳 Docker Volume Commands" \
        "dVolumes" "List all Docker volumes" \
        "dCreateVolume [name]" "Create a new Docker volume" \
        "dInspectVolume [name]" "Inspect a Docker volume" \
        "dRemoveVolume [name] [-f]" "Remove a Docker volume" \
        "dPruneVolume [-f]" "Remove all unused Docker volumes"
}
