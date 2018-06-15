#! /bin/bash

echo "==> Install Fedora common packages"

dnf install -y -q zip unzip bzip2 xz fish screen tmux sshpass fish git tig nano vim

[[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]] || yum -y -q update
