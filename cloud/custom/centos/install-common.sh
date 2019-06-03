#!/bin/bash -eux

echo "==> Install CentOS common packages"

if yum repolist all | grep -s -q "^ius/" && [[ -n ${CUSTOM_IUS} && "${CUSTOM_IUS}" == "true" ]]; then
    yum --enablerepo=ius install -y -q git2u tmux2u yum-plugin-replace
else
    yum -y -q install git
fi

yum install -y -q zip unzip bzip2 xz tig jq sshpass screen python2-httpie wget vim moreutils

yum install -y -q yum-utils
if ! yum repolist all | grep -s -q "^shells_fish_release_3"; then
    yum install -y -q fish
fi

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then
    yum -y -q update
fi
