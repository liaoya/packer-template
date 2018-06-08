! /bin/bash

echo "==> Install Oracle Linux common packages"

[[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]] || 

yum install -y -q zip unzip bzip2

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish
