#!/bin/bash -eux

if [[ -n ${CUSTOM_NVM} && ${CUSTOM_NVM} == true ]] || exit 0
echo "==> Install nvm"

export NVM_VERSION=$(curl -s "https://api.github.com/repos/creationix/nvm/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
export NVM_DIR=/opt/nvm

curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash
[[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" ${NVM_DIR}

sed -i "/NVM_DIR/d" ~/.bashrc

cat << 'EOF' > /etc/profile.d/nvm.sh
export NVM_DIR=/opt/nvm
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
