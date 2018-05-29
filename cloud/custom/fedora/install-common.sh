#! /bin/bash

echo "==> Install Fedora common packages"

[[ -n $VM_NAME && $(command -v hostnamectl) ]] && hostnamectl set-hostname $VM_NAME || true
sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

dnf install -y -q zip unzip fish screen tmux sshpass
