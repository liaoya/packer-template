#!/bin/bash

if [[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || [[ -n ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]]; then
    DOCKER_COMPOSE_VERSION=$(curl -s "https://api.github.com/repos/docker/compose/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    DOCKER_COMPOSE_VERSION=${DOCKER_COMPOSE_VERSION:-1.24.0}
    curl -sL "https://github.com/docker/compose/releases/download/${DOCKER_COMPOSE_VERSION}/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    curl -sL https://raw.githubusercontent.com/docker/compose/${DOCKER_COMPOSE_VERSION}/contrib/completion/bash/docker-compose -o /etc/bash_completion.d/docker-compose
    chmod +x /usr/local/bin/docker-compose
fi
