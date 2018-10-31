#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for Fedora'

dnf install -y -q qemu-kvm libvirt virt-install bridge-utils
systemctl enable libvirtd
systemctl start libvirtd

if [[ -n ${SUDO_USER} ]]; then
    getent group libvirt && usermod -aG libvirt "${SUDO_USER}"
    getent group kvm && usermod -aG kvm "${SUDO_USER}"
    getent group qemu && usermod -aG qemu "${SUDO_USER}"
fi
