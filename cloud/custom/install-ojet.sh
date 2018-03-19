#!/bin/bash -eux

echo "==> Install OJet"

export NVM_DIR=/opt/nvm
export NODE_VERSION=8.9.4

if [[ -s "$NVM_DIR/nvm.sh" ]]; then
    . "$NVM_DIR/nvm.sh"
    nvm install ${NODE_VERSION}
    nvm use ${NODE_VERSION}
    npm -g install @oracle/ojet-cli
else
    echo "Can not found nvm"
    exit 1
fi
