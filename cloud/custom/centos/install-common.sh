#!/bin/bash -eux

echo "==> Install CentOS common packages"

if yum repolist all | grep -s -q "^ius/" && [[ -n ${CUSTOM_IUS} && "${CUSTOM_IUS}" == "true" ]]; then
    yum --enablerepo=ius install -y -q git2u tmux2u yum-plugin-replace
else
    yum -y -q install git
fi

yum install -y -q zip unzip bzip2 xz tig jq sshpass screen python2-httpie wget vim moreutils

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish
if yum repolist enabled | grep -s -q "shells_fish_release_2"; then
    yum-config-manager --disable shells_fish_release_2  > /dev/null
fi

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then
    yum -y -q update
fi
