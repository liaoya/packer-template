#!/bin/bash

if [[ -n ${CUSTOM_DOCKER_COMPOSE} && "${CUSTOM_DOCKER_COMPOSE^^}" == "TRUE" ]]; then
    if [[ -z $(command -v docker) ]]; then
        echo "Can't find docker installation"
        exit 0
    fi
    DOCKER_COMPOSE_VERSION=$(curl -sL "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-1.25.0}
    curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    curl -sL "https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose" -o /etc/bash_completion.d/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi
