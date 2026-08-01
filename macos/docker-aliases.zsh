# docker-aliases.zsh
# Short, memorable aliases for every Docker command.
# Wrapper functions are used only where a default parameter makes sense
# (e.g. "dpsa" = "dContainers -a").

# NOTE: zsh is case-sensitive, so unlike PowerShell an alias may safely use a
# different case than its function (e.g. "ddocs" and "dDocs" coexist).

# ---------------- SYSTEM ----------------
alias dver='dVersion'
alias dinfo='dInfo'
alias ddf='dDiskSystem'
alias devents='dEvents'
alias dprune='dPruneSystem'
alias dlogin='dLogin'
alias dlogout='dLogout'

# ---------------- IMAGES ----------------
alias dimg='dImages'
alias dimgs='dImages'
alias dbuild='dBuildImage'
alias dpull='dGetImage'
alias dpush='dPushImage'
alias drmi='dRemoveImage'
drmif() { dRemoveImage -f "$@"; }
alias dpruneimg='dPruneImage'
alias dtag='dTagImage'
alias dsave='dSaveImage'
alias dload='dLoadImage'
alias dhist='dHistoryImage'
alias dinsp='dInspectImage'

# ---------------- CONTAINERS ----------------
alias dps='dContainers'
dpsa() { dContainers -a "$@"; }
alias drun='dRunContainer'
alias dcreate='dCreateContainer'
alias dstart='dStartContainer'
alias dstop='dStopContainer'
alias drestart='dRestartContainer'
alias dkill='dKillContainer'
alias drm='dRemoveContainer'
drmf() { dRemoveContainer -f "$@"; }
drmv() { dRemoveContainer -v "$@"; }
alias dlogs='dLogsContainer'
alias dexec='dExecContainer'
alias dattach='dAttachContainer'
alias dtop='dTopContainer'
alias dstats='dStatsContainer'
alias dwait='dWaitContainer'
alias dren='dRenameContainer'
alias dupdate='dUpdateContainer'
alias dpause='dPauseContainer'
alias dunpause='dUnpauseContainer'
alias dexport='dExportContainer'
alias dcommit='dCommitContainer'
alias ddiff='dDiffContainer'
alias dcp='dCpContainer'
alias dinspc='dInspectContainer'
alias dport='dPortContainer'

# ---------------- COMPOSE ----------------
alias dcps='dComposes'
alias dcup='dComposeUp'
alias dcdown='dComposeDown'
alias dcbuild='dComposeBuild'
alias dclogs='dComposeLogs'
alias dcexec='dComposeExec'
alias dcrestart='dComposeRestart'
alias dcpull='dComposePull'
alias dcstop='dComposeStop'
alias dcconfig='dComposeConfig'
alias dccheck='dComposeValidate'

# ---------------- VOLUMES ----------------
alias dvol='dVolumes'
alias dvols='dVolumes'
alias dvolc='dCreateVolume'
alias dvoli='dInspectVolume'
alias dvolr='dRemoveVolume'
alias dvolp='dPruneVolume'

# ---------------- NETWORKS ----------------
alias dnet='dNetworks'
alias dnets='dNetworks'
alias dnetc='dCreateNetwork'
alias dneti='dInspectNetwork'
alias dnetco='dConnectNetwork'
alias dnetd='dDisconnectNetwork'
alias dnetr='dRemoveNetwork'
alias dnetp='dPruneNetwork'

# ---------------- SWARM ----------------
alias dswarm='dInitSwarm'
alias dswarmjoin='dJoinSwarm'
alias dswarmleave='dLeaveSwarm'
alias dswarmtoken='dSwarmToken'
alias dnode='dNodes'
alias dnodes='dNodes'
alias dsvc='dServices'
alias dsvcs='dServices'
alias dsvcc='dCreateService'
alias dsvcr='dRemoveService'
alias dsvcscale='dScaleService'
alias dsvclogs='dServiceLogs'
alias dstack='dStackDeploy'
alias dstacks='dStacks'
alias dstackrm='dStackRemove'

# ---------------- DOCS ----------------
alias dhelp='dDocs'
alias ddocs='dDocs'
alias dcdocs='dContainerDocs'
alias didocs='dImageDocs'
alias dcompdocs='dComposeDocs'
alias dvolumdocs='dVolumeDocs'
alias dnetdocs='dNetworkDocs'
alias dswarmdocs='dSwarmDocs'
