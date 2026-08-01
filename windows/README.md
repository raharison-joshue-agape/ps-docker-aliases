# Docker Command Aliases — Windows

A curated collection of `d*` shortcuts that wrap everyday Docker operations for PowerShell on Windows.

## Overview

Instead of typing long, repetitive Docker commands, you use short, memorable functions and aliases that map one-to-one to Docker subcommands:

```powershell
dContainers                      # docker ps
dRunContainer -ImageName nginx -ContainerName web -Detach -Ports 8080:80
dStopContainer web               # docker stop web
dImages                          # docker images
dComposeUp -Detach               # docker compose up -d
```

The toolkit is organized into themed modules that load automatically from a single entry point, so only one line needs to be added to your PowerShell profile. Every function ships with comment-based help discoverable through `Get-Help`.

## Prerequisites

| Requirement | Details |
| --- | --- |
| Operating system | Windows 10 or 11 |
| Shell | Windows PowerShell 5.1+ or PowerShell 7 |
| Docker | [Docker Desktop](https://www.docker.com/products/docker-desktop/) (or the Docker CLI) installed and available in `PATH` |

## Installation

### 1. Copy the module to your config directory

```powershell
New-Item -ItemType Directory -Path "$HOME\.config\alias\docker-commandes" -Force
Copy-Item -Path "index.ps1" -Destination "$HOME\.config\alias\docker-commandes\"
Copy-Item -Path "windows" -Destination "$HOME\.config\alias\docker-commandes\" -Recurse
```

### 2. Check whether a PowerShell profile exists

```powershell
Test-Path $PROFILE
```

- `True` → your profile already exists; continue to step 4.
- `False` → create it first:

```powershell
New-Item -Path $PROFILE -ItemType File -Force
```

### 3. Open your profile

```powershell
notepad $PROFILE
```

or with Visual Studio Code:

```powershell
code $PROFILE
```

### 4. Import the aliases

Append the following line to your profile:

```powershell
. "$HOME\.config\alias\docker-commandes\index.ps1"
```

`index.ps1` is the entry point. It dot-sources every module located in the `windows/` folder next to it, so the shortcuts work no matter where the project has been copied to.

### 5. Reload your profile

```powershell
. $PROFILE
```

## Module reference

Each module groups functions by topic:

| File | Functions |
| --- | --- |
| `index.ps1` | Entry point; dot-sources every module below |
| `docker-helpers.ps1` | `Test-DockerCLI`, `Assert-DockerCLI`, `Confirm-Action`, `Show-DockerResult`, `Read-Value`, `Complete-ImageName`, `Get-LocalImages`, `Test-ImageExists`, `Resolve-ImageName`, `Show-ContainerList`, `Get-ContainerNames`, `Test-ContainerExists`, `Test-ContainerRunning`, `Resolve-ContainerName`, `Get-VolumeNames`, `Test-VolumeExists`, `Get-NetworkNames`, `Test-NetworkExists`, `Get-ServiceNames`, `Test-ServiceExists`, `Resolve-ServiceName`, `Show-DocTable` |
| `docker-system.ps1` | `dVersion`, `dInfo`, `dDiskSystem`, `dEvents`, `dPruneSystem`, `dLogin`, `dLogout` |
| `docker-images.ps1` | `dImages`, `dBuildImage`, `dGetImage`, `dPushImage`, `dRemoveImage`, `dPruneImage`, `dTagImage`, `dSaveImage`, `dLoadImage`, `dHistoryImage`, `dInspectImage`, `dImageDocs` |
| `docker-containers.ps1` | `dContainers`, `dRunContainer`, `dCreateContainer`, `dStartContainer`, `dStopContainer`, `dRestartContainer`, `dKillContainer`, `dRemoveContainer`, `dLogsContainer`, `dExecContainer`, `dAttachContainer`, `dTopContainer`, `dStatsContainer`, `dWaitContainer`, `dRenameContainer`, `dUpdateContainer`, `dPauseContainer`, `dUnpauseContainer`, `dExportContainer`, `dCommitContainer`, `dDiffContainer`, `dCpContainer`, `dInspectContainer`, `dPortContainer`, `dContainerDocs` |
| `docker-compose.ps1` | `dComposes`, `dComposeUp`, `dComposeDown`, `dComposeBuild`, `dComposeLogs`, `dComposeExec`, `dComposeRestart`, `dComposePull`, `dComposeStop`, `dComposeConfig`, `dComposeValidate`, `dComposeDocs` |
| `docker-volumes.ps1` | `dVolumes`, `dCreateVolume`, `dInspectVolume`, `dRemoveVolume`, `dPruneVolume`, `dVolumeDocs` |
| `docker-networks.ps1` | `dNetworks`, `dCreateNetwork`, `dInspectNetwork`, `dConnectNetwork`, `dDisconnectNetwork`, `dRemoveNetwork`, `dPruneNetwork`, `dNetworkDocs` |
| `docker-swarm.ps1` | `dInitSwarm`, `dJoinSwarm`, `dLeaveSwarm`, `dSwarmToken`, `dNodes`, `dServices`, `dCreateService`, `dRemoveService`, `dScaleService`, `dServiceLogs`, `dStackDeploy`, `dStacks`, `dStackRemove`, `dSwarmDocs` |
| `docker-docs.ps1` | `dDocs` |
| `docker-aliases.ps1` | Short aliases (`dps`, `drun`, `dstop`, `dlogs`, `dcup`, ...) and wrapper functions (`dpsa`, `drmf`, `drmv`, `drmif`) |

## Usage

Functions behave like ordinary PowerShell commands and accept parameters that mirror the underlying Docker flags:

```powershell
dContainers                # docker ps (running containers)
dpsa                       # alias: docker ps -a
dRunContainer -ImageName nginx -ContainerName web -Detach -Ports 8080:80
dStopContainer web         # docker stop web
dLogsContainer web -Follow # docker logs -f web
dImages                    # docker images
dComposeUp -Detach         # docker compose up -d
dPruneSystem -Volumes      # docker system prune -a -f --volumes
```

Run any function without arguments for interactive mode: it lists what is available and prompts you for the missing values.

## Built-in help

| Command | Description |
| --- | --- |
| `dDocs` | Print an in-terminal cheat sheet of every available command and alias |
| `dhelp` | Alias for `dDocs` |
| `Get-Help <function>` | Show comment-based documentation for any function, including parameters and examples |

```powershell
dDocs
Get-Help dRunContainer
```

## Uninstall

1. Remove the import line from `$PROFILE`.
2. Delete the directory:

```powershell
Remove-Item -Path "$HOME\.config\alias\docker-commandes" -Recurse -Force
```

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Commands are unavailable | Verify the import path in `$PROFILE`, then reload with `. $PROFILE`. |
| `❌ Docker CLI not found` | Install Docker Desktop and restart PowerShell. |
| Profile not found | Confirm `$PROFILE` exists with `Test-Path $PROFILE`, creating it if necessary. |

## Contributing

The Windows and Linux variants of this toolkit mirror each other. If you add or change a command in one, apply the same change to the other. See [repository README](../linux/README.md) for the bash version.
