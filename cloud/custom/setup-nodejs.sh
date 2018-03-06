#!/bin/bash -eux

echo "==> Install nvm"

export NVM_VERSION=0.33.8
export NODE_VERSION=8.9.4
export NVM_DIR=/opt/nvm

curl -s -o- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash
[[ -s "$NVM_DIR/nvm.sh" ]] && source "$NVM_DIR/nvm.sh"
nvm install ${NODE_VERSION}
nvm use ${NODE_VERSION}

echo << 'EOF' > /etc/profile.d/nvm.sh
export NVM_DIR=/opt/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
EOF
