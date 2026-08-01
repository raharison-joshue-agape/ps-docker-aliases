# Docker Command Aliases — macOS

A curated collection of `d*` shortcuts that wrap everyday Docker operations for zsh on macOS.

## Overview

Instead of typing long, repetitive Docker commands, you use short, memorable functions and aliases that map one-to-one to Docker subcommands:

```zsh
dContainers                      # docker ps
dRunContainer nginx --name web -d -p 8080:80
dStopContainer web               # docker stop web
dImages                          # docker images
dComposeUp -d                    # docker compose up -d
```

The toolkit is organized into themed modules that load automatically from a single entry point, so only one line needs to be added to your shell configuration. Every command prints colored output and asks for confirmation before destructive operations.

## Prerequisites

| Requirement | Details |
| --- | --- |
| Operating system | macOS (zsh 5+, the default shell since Catalina) |
| Shell | zsh |
| Docker | Docker Engine (or Docker Desktop) installed and available in `PATH` |

## Installation

### 1. Copy the module to your config directory

```zsh
mkdir -p "$HOME/.config/alias/docker-commandes"
cp -r macos "$HOME/.config/alias/docker-commandes/"
```

### 2. Add the import line to your shell config

Open `~/.zshrc` and append:

```zsh
source "$HOME/.config/alias/docker-commandes/macos/index.zsh"
```

`index.zsh` is the entry point. It resolves its own directory (even when `~/.zshrc` is a symlink) and sources every module located there, so the shortcuts work no matter where the project has been copied to.

### 3. Reload your shell

```zsh
source ~/.zshrc
```

## Module reference

Each module groups functions by topic:

| File | Functions |
| --- | --- |
| `index.zsh` | Entry point; sources every module below |
| `docker-helpers.zsh` | `d_check_cli`, `d_confirm`, `d_show_result`, `d_read_value`, `d_complete_image`, `d_local_images`, `d_image_exists`, `d_show_images`, `d_resolve_image`, `d_show_containers`, `d_container_names`, `d_container_exists`, `d_container_running`, `d_resolve_container`, `d_volume_names`, `d_volume_exists`, `d_network_names`, `d_network_exists`, `d_service_names`, `d_service_exists`, `d_resolve_service`, `d_doc_table` |
| `docker-system.zsh` | `dVersion`, `dInfo`, `dDiskSystem`, `dEvents`, `dPruneSystem`, `dLogin`, `dLogout` |
| `docker-images.zsh` | `dImages`, `dBuildImage`, `dGetImage`, `dPushImage`, `dRemoveImage`, `dPruneImage`, `dTagImage`, `dSaveImage`, `dLoadImage`, `dHistoryImage`, `dInspectImage`, `dImageDocs` |
| `docker-containers.zsh` | `dContainers`, `dRunContainer`, `dCreateContainer`, `dStartContainer`, `dStopContainer`, `dRestartContainer`, `dKillContainer`, `dRemoveContainer`, `dLogsContainer`, `dExecContainer`, `dAttachContainer`, `dTopContainer`, `dStatsContainer`, `dWaitContainer`, `dRenameContainer`, `dUpdateContainer`, `dPauseContainer`, `dUnpauseContainer`, `dExportContainer`, `dCommitContainer`, `dDiffContainer`, `dCpContainer`, `dInspectContainer`, `dPortContainer`, `dContainerDocs` |
| `docker-compose.zsh` | `dComposes`, `dComposeUp`, `dComposeDown`, `dComposeBuild`, `dComposeLogs`, `dComposeExec`, `dComposeRestart`, `dComposePull`, `dComposeStop`, `dComposeConfig`, `dComposeValidate`, `dComposeDocs` |
| `docker-volumes.zsh` | `dVolumes`, `dCreateVolume`, `dInspectVolume`, `dRemoveVolume`, `dPruneVolume`, `dVolumeDocs` |
| `docker-networks.zsh` | `dNetworks`, `dCreateNetwork`, `dInspectNetwork`, `dConnectNetwork`, `dDisconnectNetwork`, `dRemoveNetwork`, `dPruneNetwork`, `dNetworkDocs` |
| `docker-swarm.zsh` | `dInitSwarm`, `dJoinSwarm`, `dLeaveSwarm`, `dSwarmToken`, `dNodes`, `dServices`, `dCreateService`, `dRemoveService`, `dScaleService`, `dServiceLogs`, `dStackDeploy`, `dStacks`, `dStackRemove`, `dSwarmDocs` |
| `docker-docs.zsh` | `dDocs` |
| `docker-aliases.zsh` | Short aliases (`dps`, `drun`, `dstop`, `dlogs`, `dcup`, ...) and wrapper functions (`dpsa`, `drmf`, `drmv`, `drmif`) |

## Usage

Functions behave like ordinary shell commands and accept flags that mirror the underlying Docker options:

```zsh
dContainers              # docker ps (running containers)
dps -a                   # alias: docker ps -a
dRunContainer nginx --name web -d -p 8080:80
dStopContainer web       # docker stop web
dLogsContainer web -f    # docker logs -f web
dImages                  # docker images
dComposeUp -d            # docker compose up -d
dPruneSystem -v          # docker system prune -a -f --volumes
```

Run any function without arguments for interactive mode: it lists what is available and prompts you for the missing values. Destructive commands ask for confirmation; pass `-f` or `--force` to skip it.

## Built-in help

| Command | Description |
| --- | --- |
| `dDocs` | Print an in-terminal cheat sheet of every available command and alias |
| `dhelp` | Alias for `dDocs` |

```zsh
dDocs
```

## Uninstall

1. Remove the `source` line from `~/.zshrc`.
2. Delete the directory:

```zsh
rm -rf "$HOME/.config/alias/docker-commandes/macos"
```

## Troubleshooting

| Symptom | Fix |
| --- | --- |
| Commands are unavailable | Verify the `source` line in your shell config, then reload with `source ~/.zshrc`. |
| `❌ Docker CLI not found` | Install Docker Engine / Docker Desktop and restart your shell. |
| Aliases do not expand in scripts | Aliases only apply to interactive shells; use the full function name (e.g. `dContainers`) instead. |

## Contributing

The macOS, Linux, and Windows variants of this toolkit mirror each other. If you add or change a command in one, apply the same change to the others. See [repository README](../README.md) for the other versions.
