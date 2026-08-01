# 🚀 Docker Command Aliases – Documentation

Welcome to the Docker PowerShell toolkit. It provides a set of `d*` helper
functions and short aliases that wrap the Docker CLI for faster, safer terminal
usage.

## 📁 Project Layout

```
docker-commandes/
├── index.ps1                  # Entry point (dot-source this from your profile)
└── windows/
    ├── docker-helpers.ps1     # Shared internal helpers (validation, prompts, tables)
    ├── docker-system.ps1      # System info, disk usage, cleanup, login/logout, events
    ├── docker-images.ps1      # Images: list, build, pull, push, tag, save/load, inspect
    ├── docker-containers.ps1  # Containers: run, start/stop, logs, exec, copy, inspect...
    ├── docker-compose.ps1     # Compose: up/down, build, logs, exec, config, validate
    ├── docker-volumes.ps1     # Volumes: list, create, inspect, remove, prune
    ├── docker-networks.ps1    # Networks: list, create, connect, disconnect, prune
    ├── docker-swarm.ps1       # Swarm: init, join, nodes, services, stacks
    ├── docker-docs.ps1        # Unified reference (dDocs)
    └── docker-aliases.ps1     # Short aliases (dps, drun, dstop, dlogs...)
```

## ⚙️ PowerShell Profile Setup

### Check if the profile exists

```powershell
Test-Path $PROFILE
```

`True` → the profile already exists. `False` → create it:

```powershell
New-Item -Path $PROFILE -ItemType File -Force
```

### Install the aliases

Make sure the repo is in place (e.g. cloned or copied to `~/.config/alias`):

```powershell
git clone https://github.com/raharison-joshue-agape/ps-docker-aliases.git docker-commandes
```

Then add this line to your PowerShell profile (`code $PROFILE`):

```powershell
. "$HOME\.config\alias\docker-commandes\index.ps1"
```

### Apply changes

```powershell
. $PROFILE
```

### ✅ Result

Your Docker commands and aliases are now active. Try:

```powershell
dDocs       # show the full command reference
dVersion    # show Docker version
dContainers # list running containers
dps -All    # alias: list all containers
```

## 💡 Tips

- Run any `d*` command without arguments for interactive mode (it lists what is
  available and prompts you).
- Use `Get-Help <command>` (e.g. `Get-Help dRunContainer`) for usage details.
- Restart PowerShell if aliases don't show up, and double-check the path in
  your profile.
- Customize the command files under `windows/` as you like.
