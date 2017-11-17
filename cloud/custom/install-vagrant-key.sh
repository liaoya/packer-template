#!/bin/bash -eux

SSH_USER=${SSH_USERNAME:-vagrant}
if id -u $SSH_USER >/dev/null 2>&1; then
    echo "==> Install vagrant key as $SSH_USER's ssh key"
    (cd /tmp; curl -L -s -S -O https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant; curl -L -s -S -O https://raw.githubusercontent.com/hashicorp/vagrant/master/keys/vagrant.pub)
    su -l "$SSH_USER" -c '[ -d ~/.ssh ] ||  { mkdir ~/.ssh; chmod 700 ~/.ss; }'
    su -l "$SSH_USER" -c '[ -f /tmp/vagrant.pub ] && cp /tmp/vagrant.pub ~/.ssh/id_rsa.pub && chmod 644 ~/.ssh/id_rsa.pub'
    su -l "$SSH_USER" -c '[ -f /tmp/vagrant ] && cp /tmp/vagrant ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa'
fi
