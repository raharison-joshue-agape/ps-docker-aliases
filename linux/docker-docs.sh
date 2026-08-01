# docker-docs.sh
# Unified reference of every command available in the Docker toolkit.

# Usage: dDocs
dDocs() {
    d_doc_table "🐳 SYSTEM" \
        "dDocs / dHelp" "Show this reference" \
        "dVersion / dver" "Show the installed Docker version" \
        "dInfo / dinfo" "Show Docker system information" \
        "dDiskSystem / ddf" "Show Docker disk usage" \
        "dEvents / devents" "Stream Docker engine events" \
        "dPruneSystem / dprune" "Clean up unused containers, images, networks" \
        "dLogin / dlogin" "Log in to a Docker registry" \
        "dLogout / dlogout" "Log out from a Docker registry"

    d_doc_table "🐳 IMAGES" \
        "dImages / dimg" "List local images" \
        "dBuildImage / dbuild" "Build an image from a folder" \
        "dGetImage / dpull" "Pull an image" \
        "dPushImage / dpush" "Push a local image" \
        "dRemoveImage / drmi" "Remove an image" \
        "dPruneImage" "Remove unused/dangling images" \
        "dTagImage / dtag" "Tag an image" \
        "dSaveImage / dsave" "Save an image to a .tar file" \
        "dLoadImage / dload" "Load an image from a .tar file" \
        "dHistoryImage / dhist" "Show an image's history" \
        "dInspectImage / dinsp" "Inspect an image"

    d_doc_table "🐳 CONTAINERS" \
        "dContainers / dps" "List containers (running by default)" \
        "dRunContainer / drun" "Run a container" \
        "dCreateContainer / dcreate" "Create a container" \
        "dStartContainer / dstart" "Start a container" \
        "dStopContainer / dstop" "Stop a container" \
        "dRestartContainer / drestart" "Restart a container" \
        "dKillContainer / dkill" "Force-kill a container" \
        "dRemoveContainer / drm" "Remove a container" \
        "dLogsContainer / dlogs" "Show container logs" \
        "dExecContainer / dexec" "Execute a command in a container" \
        "dAttachContainer / dattach" "Attach to a container" \
        "dTopContainer / dtop" "Show processes in a container" \
        "dStatsContainer / dstats" "Show live container stats" \
        "dWaitContainer / dwait" "Wait for a container to stop" \
        "dRenameContainer / dren" "Rename a container" \
        "dUpdateContainer / dupdate" "Update container resources" \
        "dPauseContainer / dpause" "Pause a container" \
        "dUnpauseContainer / dunpause" "Unpause a container" \
        "dExportContainer / dexport" "Export a container filesystem" \
        "dCommitContainer / dcommit" "Commit a container to an image" \
        "dDiffContainer / ddiff" "Show container filesystem changes" \
        "dCpContainer / dcp" "Copy files host <-> container" \
        "dInspectContainer / dinspc" "Inspect a container" \
        "dPortContainer / dport" "Show a container's ports"

    d_doc_table "🐳 COMPOSE" \
        "dComposes / dcps" "List Compose services" \
        "dComposeUp / dcup" "Start Compose services" \
        "dComposeDown / dcdown" "Stop and remove Compose services" \
        "dComposeBuild / dcbuild" "Build Compose images" \
        "dComposeLogs / dclogs" "Show Compose logs" \
        "dComposeExec / dcexec" "Exec a command in a service" \
        "dComposeRestart / dcrestart" "Restart Compose services" \
        "dComposePull / dcpull" "Pull Compose images" \
        "dComposeStop / dcstop" "Stop services (keep containers)" \
        "dComposeConfig / dcconfig" "Show Compose configuration" \
        "dComposeValidate / dccheck" "Validate the Compose file"

    d_doc_table "🐳 VOLUMES" \
        "dVolumes / dvol" "List volumes" \
        "dCreateVolume / dvolc" "Create a volume" \
        "dInspectVolume / dvoli" "Inspect a volume" \
        "dRemoveVolume / dvolr" "Remove a volume" \
        "dPruneVolume / dvolp" "Remove unused volumes"

    d_doc_table "🐳 NETWORKS" \
        "dNetworks / dnet" "List networks" \
        "dCreateNetwork / dnetc" "Create a network" \
        "dInspectNetwork / dneti" "Inspect a network" \
        "dConnectNetwork / dnetco" "Connect a container to a network" \
        "dDisconnectNetwork / dnetd" "Disconnect a container from a network" \
        "dRemoveNetwork / dnetr" "Remove a network" \
        "dPruneNetwork / dnetp" "Remove unused networks"

    d_doc_table "🐳 SWARM" \
        "dInitSwarm / dswarm" "Initialize a Swarm cluster" \
        "dJoinSwarm / dswarmjoin" "Join a Swarm cluster" \
        "dLeaveSwarm / dswarmleave" "Leave the Swarm cluster" \
        "dSwarmToken / dswarmtoken" "Show the join token" \
        "dNodes / dnodes" "List Swarm nodes" \
        "dServices / dsvcs" "List Swarm services" \
        "dCreateService / dsvcc" "Create a service" \
        "dRemoveService / dsvcr" "Remove a service" \
        "dScaleService / dsvcscale" "Scale a service" \
        "dServiceLogs / dsvclogs" "Show a service's logs" \
        "dStackDeploy / dstack" "Deploy a stack" \
        "dStacks / dstacks" "List deployed stacks" \
        "dStackRemove / dstackrm" "Remove a stack"

    d_doc_table "🐳 PER-CATEGORY REFERENCES" \
        "dContainerDocs / dcdocs" "Container command reference" \
        "dImageDocs / didocs" "Image command reference" \
        "dComposeDocs / dcompdocs" "Compose command reference" \
        "dVolumeDocs / dvolumdocs" "Volume command reference" \
        "dNetworkDocs / dnetdocs" "Network command reference" \
        "dSwarmDocs / dswarmdocs" "Swarm command reference"

    printf '%s💡 Tip: run any command without arguments for interactive mode.%s\n' "$dGray" "$dReset"
}
