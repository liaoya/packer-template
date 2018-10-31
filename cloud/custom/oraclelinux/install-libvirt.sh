#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo "==> Install Orace Linux docker packages"

yum install -y -q libvirt qemu-kvm libguestfs virt-install

if [[ -n ${SUDO_USER} ]]; then
    getent group libvirt && usermod -aG libvirt "${SUDO_USER}"
    getent group kvm && usermod -aG kvm "${SUDO_USER}"
    getent group qemu && usermod -aG qemu "${SUDO_USER}"
fi
