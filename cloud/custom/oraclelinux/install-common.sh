#!/bin/bash

echo "==> Install Oracle Linux common packages"

if yum repolist all | grep -s -q "^ius/"; then
    yum --enablerepo=ius install -y -q git2u tmux2u
else
    yum -y -q install git
fi

yum install -y -q zip unzip bzip2 xz tig jq sshpass screen python2-httpie moreutils

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then
    yum -y -q update
fi
