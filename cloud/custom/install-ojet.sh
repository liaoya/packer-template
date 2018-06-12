#!/bin/bash -eux

[[ -n ${CUSTOM_OJET} && ${CUSTOM_OJET} == true ]] || exit 0
echo "==> Install OJet"

NVM_DIR=${NVM_DIR:-/opt/nvm}
NODE_VERSION=8.11.2

[[ $(command nvm) ]] || { [[ -s "$NVM_DIR/nvm.sh" ]] && . "$NVM_DIR/nvm.sh"; }

if [[ $(command nvm) ]]; then
    nvm install ${NODE_VERSION}
    nvm use ${NODE_VERSION}
    npm -g install @oracle/ojet-cli
else
    echo "Can not found nvm"
    exit 0
fi
