! /bin/bash

echo "==> Install Oracle Linux common packages"

[[ -n $VM_NAME && $(command -v hostnamectl) ]] && hostnamectl set-hostname $VM_NAME || true

yum install -y -q zip unzip

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish
