#!/usr/bin/env zsh
# index.zsh
# Docker Command Aliases (macOS) - main entry point.
#
# Add the following line to your ~/.zshrc to load the toolkit:
#   source "$HOME/.config/alias/docker-commandes/macos/index.zsh"

# Resolve this file's directory (absolute, symlinks expanded) using ${0:A:h}.
DOCKER_ALIASES_DIR="${0:A:h}"

for _docker_aliases_file in \
    docker-helpers.zsh \
    docker-system.zsh \
    docker-images.zsh \
    docker-containers.zsh \
    docker-compose.zsh \
    docker-volumes.zsh \
    docker-networks.zsh \
    docker-swarm.zsh \
    docker-docs.zsh \
    docker-aliases.zsh
do
    _docker_aliases_path="$DOCKER_ALIASES_DIR/$_docker_aliases_file"
    if [[ -f "$_docker_aliases_path" ]]; then
        # shellcheck disable=SC1090
        source "$_docker_aliases_path"
    else
        printf '\033[31mDocker alias module not found: %s\033[0m\n' "$_docker_aliases_path"
    fi
done

unset _docker_aliases_file _docker_aliases_path
