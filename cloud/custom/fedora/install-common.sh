#! /bin/bash

echo "==> Install Fedora common packages"

dnf install -y -q zip unzip fish screen tmux sshpass fish git tig

[[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]] || yum -y -q update
