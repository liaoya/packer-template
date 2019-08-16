#!/bin/bash

echo "==> Install Oracle Linux common packages"

if yum repolist all | grep -s -q "^ius/" && [[ -n ${CUSTOM_IUS} && "${CUSTOM_IUS}" == "true" ]]; then
    yum --enablerepo=ius install -y -q git222 tmux2 yum-plugin-replace
else
    yum -y -q install git
fi

yum install -y -q zip unzip bzip2 xz
yum install -y -q jq moreutils python36 sshpass screen tig wget vim

if [[ -z $(command -v repomanage) ]]; then yum install -y -q yum-utils; fi
if yum repolist all | grep -s -q "^shells_fish_release_3"; then
    yum install -y -q fish
fi

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then
    yum -y -q update
fi
