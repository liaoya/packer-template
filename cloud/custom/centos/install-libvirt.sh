#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for CentOS'

yum install -y -q libvirt libvirt-daemon-kvm qemu-kvm virt-install virt-top libvirt-python
if [[ -n ${SUDO_USER} ]]; then
    getent group libvirt && usermod -aG libvirt "${SUDO_USER}"
    getent group libvirtd && usermod -aG libvirtd "${SUDO_USER}"
    getent group kvm && usermod -aG kvm "${SUDO_USER}"
fi
