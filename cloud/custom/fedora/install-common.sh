#! /bin/bash

echo "==> Install Fedora common packages"

[[ -n $VM_NAME && $(command -v hostnamectl) ]] && hostnamectl set-hostname $VM_NAME || true

dnf install -y -q zip unzip
