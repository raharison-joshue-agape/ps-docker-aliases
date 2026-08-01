# docker-docs.ps1
# Unified reference of every command available in the Docker toolkit.

function dDocs {
    <#
    .SYNOPSIS
    Shows the unified reference of all Docker commands and their short aliases.
    #>
    Show-DocTable -Commands @(
        @{Command="dDocs / dHelp"; Description="Show this reference"},
        @{Command="dVersion / dver"; Description="Show the installed Docker version"},
        @{Command="dInfo / dinfo"; Description="Show Docker system information"},
        @{Command="dDiskSystem / ddf"; Description="Show Docker disk usage"},
        @{Command="dEvents / devents"; Description="Stream Docker engine events"},
        @{Command="dPruneSystem / dprune"; Description="Clean up unused containers, images, networks"},
        @{Command="dLogin / dlogin"; Description="Log in to a Docker registry"},
        @{Command="dLogout / dlogout"; Description="Log out from a Docker registry"}
    ) -Title "🐳 SYSTEM"

    Show-DocTable -Commands @(
        @{Command="dImages / dimg"; Description="List local images"},
        @{Command="dBuildImage / dbuild"; Description="Build an image from a folder"},
        @{Command="dGetImage / dpull"; Description="Pull an image"},
        @{Command="dPushImage / dpush"; Description="Push a local image"},
        @{Command="dRemoveImage / drmi"; Description="Remove an image"},
        @{Command="dPruneImage / dpruneimg"; Description="Remove unused/dangling images"},
        @{Command="dTagImage / dtag"; Description="Tag an image"},
        @{Command="dSaveImage / dsave"; Description="Save an image to a .tar file"},
        @{Command="dLoadImage / dload"; Description="Load an image from a .tar file"},
        @{Command="dHistoryImage / dhist"; Description="Show an image's history"},
        @{Command="dInspectImage / dinsp"; Description="Inspect an image"}
    ) -Title "🐳 IMAGES"

    Show-DocTable -Commands @(
        @{Command="dContainers / dps"; Description="List containers (running by default)"},
        @{Command="dRunContainer / drun"; Description="Run a container"},
        @{Command="dCreateContainer / dcreate"; Description="Create a container"},
        @{Command="dStartContainer / dstart"; Description="Start a container"},
        @{Command="dStopContainer / dstop"; Description="Stop a container"},
        @{Command="dRestartContainer / drestart"; Description="Restart a container"},
        @{Command="dKillContainer / dkill"; Description="Force-kill a container"},
        @{Command="dRemoveContainer / drm"; Description="Remove a container"},
        @{Command="dLogsContainer / dlogs"; Description="Show container logs"},
        @{Command="dExecContainer / dexec"; Description="Execute a command in a container"},
        @{Command="dAttachContainer / dattach"; Description="Attach to a container"},
        @{Command="dTopContainer / dtop"; Description="Show processes in a container"},
        @{Command="dStatsContainer / dstats"; Description="Show live container stats"},
        @{Command="dWaitContainer / dwait"; Description="Wait for a container to stop"},
        @{Command="dRenameContainer / dren"; Description="Rename a container"},
        @{Command="dUpdateContainer / dupdate"; Description="Update container resources"},
        @{Command="dPauseContainer / dpause"; Description="Pause a container"},
        @{Command="dUnpauseContainer / dunpause"; Description="Unpause a container"},
        @{Command="dExportContainer / dexport"; Description="Export a container filesystem"},
        @{Command="dCommitContainer / dcommit"; Description="Commit a container to an image"},
        @{Command="dDiffContainer / ddiff"; Description="Show container filesystem changes"},
        @{Command="dCpContainer / dcp"; Description="Copy files host <-> container"},
        @{Command="dInspectContainer / dinspc"; Description="Inspect a container"},
        @{Command="dPortContainer / dport"; Description="Show a container's ports"}
    ) -Title "🐳 CONTAINERS"

    Show-DocTable -Commands @(
        @{Command="dComposes / dcps"; Description="List Compose services"},
        @{Command="dComposeUp / dcup"; Description="Start Compose services"},
        @{Command="dComposeDown / dcdown"; Description="Stop and remove Compose services"},
        @{Command="dComposeBuild / dcbuild"; Description="Build Compose images"},
        @{Command="dComposeLogs / dclogs"; Description="Show Compose logs"},
        @{Command="dComposeExec / dcexec"; Description="Exec a command in a service"},
        @{Command="dComposeRestart / dcrestart"; Description="Restart Compose services"},
        @{Command="dComposePull / dcpull"; Description="Pull Compose images"},
        @{Command="dComposeStop / dcstop"; Description="Stop services (keep containers)"},
        @{Command="dComposeConfig / dcconfig"; Description="Show Compose configuration"},
        @{Command="dComposeValidate / dccheck"; Description="Validate the Compose file"}
    ) -Title "🐳 COMPOSE"

    Show-DocTable -Commands @(
        @{Command="dVolumes / dvol"; Description="List volumes"},
        @{Command="dCreateVolume / dvolc"; Description="Create a volume"},
        @{Command="dInspectVolume / dvoli"; Description="Inspect a volume"},
        @{Command="dRemoveVolume / dvolr"; Description="Remove a volume"},
        @{Command="dPruneVolume / dvolp"; Description="Remove unused volumes"}
    ) -Title "🐳 VOLUMES"

    Show-DocTable -Commands @(
        @{Command="dNetworks / dnet"; Description="List networks"},
        @{Command="dCreateNetwork / dnetc"; Description="Create a network"},
        @{Command="dInspectNetwork / dneti"; Description="Inspect a network"},
        @{Command="dConnectNetwork / dnetco"; Description="Connect a container to a network"},
        @{Command="dDisconnectNetwork / dnetd"; Description="Disconnect a container from a network"},
        @{Command="dRemoveNetwork / dnetr"; Description="Remove a network"},
        @{Command="dPruneNetwork / dnetp"; Description="Remove unused networks"}
    ) -Title "🐳 NETWORKS"

    Show-DocTable -Commands @(
        @{Command="dInitSwarm / dswarm"; Description="Initialize a Swarm cluster"},
        @{Command="dJoinSwarm / dswarmjoin"; Description="Join a Swarm cluster"},
        @{Command="dLeaveSwarm / dswarmleave"; Description="Leave the Swarm cluster"},
        @{Command="dSwarmToken / dswarmtoken"; Description="Show the join token"},
        @{Command="dNodes / dnodes"; Description="List Swarm nodes"},
        @{Command="dServices / dsvcs"; Description="List Swarm services"},
        @{Command="dCreateService / dsvcc"; Description="Create a service"},
        @{Command="dRemoveService / dsvcr"; Description="Remove a service"},
        @{Command="dScaleService / dsvcscale"; Description="Scale a service"},
        @{Command="dServiceLogs / dsvclogs"; Description="Show a service's logs"},
        @{Command="dStackDeploy / dstack"; Description="Deploy a stack"},
        @{Command="dStacks / dstacks"; Description="List deployed stacks"},
        @{Command="dStackRemove / dstackrm"; Description="Remove a stack"}
    ) -Title "🐳 SWARM"

    Show-DocTable -Commands @(
        @{Command="dContainerDocs / dcdocs"; Description="Container command reference"},
        @{Command="dImageDocs / didocs"; Description="Image command reference"},
        @{Command="dComposeDocs / dcompdocs"; Description="Compose command reference"},
        @{Command="dVolumeDocs / dvolumdocs"; Description="Volume command reference"},
        @{Command="dNetworkDocs / dnetdocs"; Description="Network command reference"},
        @{Command="dSwarmDocs / dswarmdocs"; Description="Swarm command reference"}
    ) -Title "🐳 PER-CATEGORY REFERENCES"

    Write-Host "💡 Tip: run any command without arguments for interactive mode. Use Get-Help <command> for details." -ForegroundColor DarkGray
}
