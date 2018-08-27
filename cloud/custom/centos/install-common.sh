#!/bin/bash -eux

echo "==> Install CentOS common packages"

yum repolist all | grep -s -q "^ius/" && yum --enablerepo=ius install -y -q git2u tmux2u yum-plugin-replace || yum -y -q install git

yum install -y -q zip unzip bzip2 xz tig jq sshpass screen python2-httpie wget vim

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish
yum repolist enabled | grep -s -q "shells_fish_release_2" && yum-config-manager --disable shells_fish_release_2 || true

[[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]] && yum -y -q update || true
