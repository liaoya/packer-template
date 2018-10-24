#!/bin/bash -eux
#shellcheck disable=SC2086

[[ -n ${CUSTOM_NVM} && ${CUSTOM_NVM} == true ]] || exit 0
echo "==> Install nvm"

NVM_VERSION=$(curl -s "https://api.github.com/repos/creationix/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
export NVM_DIR=/opt/nvm
[[ -d ${NVM_DIR} ]] || mkdir -p ${NVM_DIR}

curl -s -o- "https://raw.githubusercontent.com/creationix/nvm/${NVM_VERSION}/install.sh" | bash

if [[ -d ${NVM_DIR} && -n "$(ls -A ${NVM_DIR})" ]]; then
    sed -i "/NVM_DIR/d" ~/.bashrc
    [[ -n ${SUDO_USER} ]] && chown -R "$(id -u ${SUDO_USER}):$(id -g ${SUDO_USER})" ${NVM_DIR}
    echo "[[ -s ${NVM_DIR}/nvm.sh ]] && export NVM_DIR=${NVM_DIR} && \\. \${NVM_DIR}/nvm.sh" | tee /etc/profile.d/nvm.sh
    [[ -d /etc/bash_completion.d ]] || mkdir -p /etc/bash_completion.d
    [[ -s ${NVM_DIR}/bash_completion ]] && cp ${NVM_DIR}/bash_completion /etc/bash_completion.d/asdf.bash
fi
