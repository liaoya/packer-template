#!/bin/bash -eux

echo "==> Install CentOS common packages"

if dnf repolist all | grep -s -q "^ius/" && [[ -n ${CUSTOM_IUS} && "${CUSTOM_IUS}" == "true" ]]; then
    dnf --enablerepo=ius install -y -q git2u tmux2u dnf-plugin-replace
else
    dnf -y -q install git
fi

dnf install -y -q zip unzip bzip2 xz
dnf install -y -q jq moreutils python3 sshpass screen tig wget vim

if [[ -z $(command -v repomanage) ]]; then dnf install -y -q dnf-utils; fi
if dnf repolist all | grep -s -q "^shells_fish_release_3"; then
    dnf install -y -q fish
fi

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then
    dnf -y -q update
fi
