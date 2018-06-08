#! /bin/bash

echo "==> Install CentOS common packages"

[[ -n $VM_NAME && $(command -v hostnamectl) ]] && hostnamectl set-hostname $VM_NAME || true
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config
sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

yum install -y -q zip unzip

yum install -y -q yum-utils
yum-config-manager --add-repo http://download.opensuse.org/repositories/shells:/fish:/release:/2/RHEL_7/shells:fish:release:2.repo
yum install -y -q fish
