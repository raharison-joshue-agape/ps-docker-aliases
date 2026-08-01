# docker-docs.zsh
# Help and documentation: overall Docker usage summary (dDocs).

# Usage: dDocs
dDocs() {
    d_doc_table "🐳 Docker Alias Documentation" \
        "dDocs" "Show this documentation"

    printf '\n%s📦 Available modules:%s\n' "$dCyan" "$dReset"
    printf '  dSystemDocs      System and daemon commands (info, disk, events, prune, login)\n'
    printf '  dImageDocs       Image commands (build, pull, push, tag, save, load, history)\n'
    printf '  dContainerDocs   Container lifecycle commands (run, exec, logs, stop, rm...)\n'
    printf '  dComposeDocs     Docker Compose commands (up, down, build, logs, exec)\n'
    printf '  dVolumeDocs      Volume commands (create, inspect, remove, prune)\n'
    printf '  dNetworkDocs     Network commands (create, connect, disconnect, prune)\n'
    printf '  dSwarmDocs       Swarm commands (init, join, services, stacks)\n'
}
