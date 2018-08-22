#!/bin/bash -eux

echo "==> Install CentOS common packages"

yum install -y -q zip unzip bzip2 xz git tig jq sshpass screen python2-httpie wget

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish

[[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]] && yum -y -q update || true
