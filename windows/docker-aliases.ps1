# docker-aliases.ps1
# Short, memorable aliases for every Docker command.
# Wrapper functions are used only where a default parameter makes sense
# (e.g. "dpsa" = "dContainers -All").

# NOTE: PowerShell names are case-insensitive, so an alias must never share a
# name with an existing function (e.g. "ddocs" would shadow "dDocs"). Such
# redundant aliases are intentionally omitted - the function itself is the name.

# ---------------- SYSTEM ----------------
Set-Alias -Name dver      -Value dVersion
Set-Alias -Name ddf       -Value dDiskSystem
Set-Alias -Name dprune    -Value dPruneSystem

# ---------------- IMAGES ----------------
Set-Alias -Name dimg      -Value dImages
Set-Alias -Name dimgs     -Value dImages
Set-Alias -Name dbuild    -Value dBuildImage
Set-Alias -Name dpull     -Value dGetImage
Set-Alias -Name dpush     -Value dPushImage
Set-Alias -Name drmi      -Value dRemoveImage
function drmif { dRemoveImage -Force @args }
Set-Alias -Name dpruneimg -Value dPruneImage
Set-Alias -Name dtag      -Value dTagImage
Set-Alias -Name dsave     -Value dSaveImage
Set-Alias -Name dload     -Value dLoadImage
Set-Alias -Name dhist     -Value dHistoryImage
Set-Alias -Name dinsp     -Value dInspectImage

# ---------------- CONTAINERS ----------------
Set-Alias -Name dps       -Value dContainers
function dpsa { dContainers -All @args }
Set-Alias -Name drun      -Value dRunContainer
Set-Alias -Name dcreate   -Value dCreateContainer
Set-Alias -Name dstart    -Value dStartContainer
Set-Alias -Name dstop     -Value dStopContainer
Set-Alias -Name drestart  -Value dRestartContainer
Set-Alias -Name dkill     -Value dKillContainer
Set-Alias -Name drm       -Value dRemoveContainer
function drmf { dRemoveContainer -Force @args }
function drmv { dRemoveContainer -Volumes @args }
Set-Alias -Name dlogs     -Value dLogsContainer
Set-Alias -Name dexec     -Value dExecContainer
Set-Alias -Name dattach   -Value dAttachContainer
Set-Alias -Name dtop      -Value dTopContainer
Set-Alias -Name dstats    -Value dStatsContainer
Set-Alias -Name dwait     -Value dWaitContainer
Set-Alias -Name dren      -Value dRenameContainer
Set-Alias -Name dupdate   -Value dUpdateContainer
Set-Alias -Name dpause    -Value dPauseContainer
Set-Alias -Name dunpause  -Value dUnpauseContainer
Set-Alias -Name dexport   -Value dExportContainer
Set-Alias -Name dcommit   -Value dCommitContainer
Set-Alias -Name ddiff     -Value dDiffContainer
Set-Alias -Name dcp       -Value dCpContainer
Set-Alias -Name dinspc    -Value dInspectContainer
Set-Alias -Name dport     -Value dPortContainer

# ---------------- COMPOSE ----------------
Set-Alias -Name dcps      -Value dComposes
Set-Alias -Name dcup      -Value dComposeUp
Set-Alias -Name dcdown    -Value dComposeDown
Set-Alias -Name dcbuild   -Value dComposeBuild
Set-Alias -Name dclogs    -Value dComposeLogs
Set-Alias -Name dcexec    -Value dComposeExec
Set-Alias -Name dcrestart -Value dComposeRestart
Set-Alias -Name dcpull    -Value dComposePull
Set-Alias -Name dcstop    -Value dComposeStop
Set-Alias -Name dcconfig  -Value dComposeConfig
Set-Alias -Name dccheck   -Value dComposeValidate

# ---------------- VOLUMES ----------------
Set-Alias -Name dvol      -Value dVolumes
Set-Alias -Name dvols     -Value dVolumes
Set-Alias -Name dvolc     -Value dCreateVolume
Set-Alias -Name dvoli     -Value dInspectVolume
Set-Alias -Name dvolr     -Value dRemoveVolume
Set-Alias -Name dvolp     -Value dPruneVolume

# ---------------- NETWORKS ----------------
Set-Alias -Name dnet      -Value dNetworks
Set-Alias -Name dnets     -Value dNetworks
Set-Alias -Name dnetc     -Value dCreateNetwork
Set-Alias -Name dneti     -Value dInspectNetwork
Set-Alias -Name dnetco    -Value dConnectNetwork
Set-Alias -Name dnetd     -Value dDisconnectNetwork
Set-Alias -Name dnetr     -Value dRemoveNetwork
Set-Alias -Name dnetp     -Value dPruneNetwork

# ---------------- SWARM ----------------
Set-Alias -Name dswarm      -Value dInitSwarm
Set-Alias -Name dswarmjoin  -Value dJoinSwarm
Set-Alias -Name dswarmleave -Value dLeaveSwarm
Set-Alias -Name dnode       -Value dNodes
Set-Alias -Name dsvc        -Value dServices
Set-Alias -Name dsvcs       -Value dServices
Set-Alias -Name dsvcc       -Value dCreateService
Set-Alias -Name dsvcr       -Value dRemoveService
Set-Alias -Name dsvcscale   -Value dScaleService
Set-Alias -Name dsvclogs    -Value dServiceLogs
Set-Alias -Name dstack      -Value dStackDeploy
Set-Alias -Name dstackrm    -Value dStackRemove

# ---------------- DOCS ----------------
Set-Alias -Name dhelp      -Value dDocs
Set-Alias -Name dcdocs     -Value dContainerDocs
Set-Alias -Name didocs     -Value dImageDocs
Set-Alias -Name dcompdocs  -Value dComposeDocs
Set-Alias -Name dvolumdocs -Value dVolumeDocs
Set-Alias -Name dnetdocs   -Value dNetworkDocs
