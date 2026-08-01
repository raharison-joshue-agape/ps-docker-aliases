#!/usr/bin/env bash
# index.sh
# Docker Command Aliases (Linux) - main entry point.
#
# Add the following line to your ~/.bashrc to load the toolkit:
#   source "$HOME/.config/alias/docker-commandes/linux/index.sh"

DOCKER_ALIASES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for _docker_aliases_file in \
    docker-helpers.sh \
    docker-system.sh \
    docker-images.sh \
    docker-containers.sh \
    docker-compose.sh \
    docker-volumes.sh \
    docker-networks.sh \
    docker-swarm.sh \
    docker-docs.sh \
    docker-aliases.sh
do
    _docker_aliases_path="$DOCKER_ALIASES_DIR/$_docker_aliases_file"
    if [ -f "$_docker_aliases_path" ]; then
        # shellcheck disable=SC1090
        . "$_docker_aliases_path"
    else
        printf '\033[31mDocker alias module not found: %s\033[0m\n' "$_docker_aliases_path"
    fi
done

unset _docker_aliases_file _docker_aliases_path
