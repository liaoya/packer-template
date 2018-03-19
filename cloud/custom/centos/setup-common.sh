#! /bin/bash

echo "==> Install CentOS common packages"

[[ -n $VM_NAME && $(command -v hostnamectl) ]] && hostnamectl set-hostname $VM_NAME || true

yum install -y -q zip unzip
