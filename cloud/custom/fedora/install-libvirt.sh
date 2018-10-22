#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for Fedora'

dnf install -y -q qemu-kvm libvirt virt-install bridge-utils
systemctl enable libvirtd
systemctl start libvirtd

if [[ -n ${SSH_USERNAME} ]]; then
    getent group libvirt && usermod -aG libvirt "${SSH_USERNAME}"
    getent group kvm && usermod -aG kvm "${SSH_USERNAME}"
    getent group qemu && usermod -aG qemu "${SSH_USERNAME}"
fi
