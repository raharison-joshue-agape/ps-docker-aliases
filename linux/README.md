# 🚀 Docker Command Aliases – Linux Documentation

Welcome to the Docker bash toolkit. It provides a set of `d*` helper
functions and short aliases that wrap the Docker CLI for faster, safer terminal
usage. It mirrors the PowerShell toolkit in `windows/`.

## 📁 Project Layout

```
docker-commandes/
├── index.ps1                  # Windows entry point (dot-source from PowerShell profile)
└── linux/
    ├── index.sh               # Entry point (source this from your shell config)
    ├── docker-helpers.sh      # Shared internal helpers (validation, prompts, tables)
    ├── docker-system.sh       # System info, disk usage, cleanup, login/logout, events
    ├── docker-images.sh       # Images: list, build, pull, push, tag, save/load, inspect
    ├── docker-containers.sh   # Containers: run, start/stop, logs, exec, copy, inspect...
    ├── docker-compose.sh      # Compose: up/down, build, logs, exec, config, validate
    ├── docker-volumes.sh      # Volumes: list, create, inspect, remove, prune
    ├── docker-networks.sh     # Networks: list, create, connect, disconnect, prune
    ├── docker-swarm.sh        # Swarm: init, join, nodes, services, stacks
    ├── docker-docs.sh         # Unified reference (dDocs)
    ├── docker-aliases.sh      # Short aliases (dps, drun, dstop, dlogs...)
    └── README.md              # This documentation
```

## ⚙️ Shell Setup

Add this line to your `~/.bashrc` (or `~/.zshrc` for zsh):

```bash
source "$HOME/.config/alias/docker-commandes/linux/index.sh"
```

Then reload your shell:

```bash
source ~/.bashrc
```

### ✅ Result

Your Docker commands and aliases are now active. Try:

```bash
dDocs        # show the full command reference
dVersion     # show Docker version
dContainers  # list running containers
dps -a       # alias: list all containers
dpsa         # alias: list all containers (shortcut)
```

## 💡 Tips

- Run any `d*` command without arguments for interactive mode (it lists what is
  available and prompts you).
- Destructive commands (remove, prune, leave) ask for confirmation; pass `-f`
  or `--force` to skip it.
- Restart your shell if aliases don't show up, and double-check the path in
  your shell config.
- Customize the command files under `linux/` as you like.
