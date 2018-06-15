#!/bin/bash -eux

echo "==> Setup Common config"

[[ -n ${VM_NAME} && $(command -v hostnamectl) ]] && echo "Set hostname to ${VM_NAME}" && hostnamectl set-hostname ${VM_NAME} || true

[[ -f /etc/selinux/config ]] && sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config && sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config
