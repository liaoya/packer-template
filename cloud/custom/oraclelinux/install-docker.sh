#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || exit 0
echo "==> Install Orace Linux docker packages"

yum install -y -q yum-utils
yum repolist disabled | grep -s -w -q ol7_addons | sudo yum-config-manager --enable grep ol7_addons
yum install -y -q docker-engine

