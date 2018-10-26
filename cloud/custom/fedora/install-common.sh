#!/bin/bash -eux

echo "==> Install Fedora common packages"

dnf install -y -q zip unzip bzip2 xz fish screen tmux sshpass fish git tig nano vim

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then dnf -y -q update; fi
