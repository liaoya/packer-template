#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for CentOS'

yum install -y -q libvirt libvirt-daemon-kvm qemu-kvm virt-install virt-top libvirt-python
if [[ -n ${SSH_USERNAME} ]]; then
    getent group libvirt && usermod -aG libvirt "${SSH_USERNAME}"
    getent group libvirtd && usermod -aG libvirtd "${SSH_USERNAME}"
    getent group kvm && usermod -aG kvm "${SSH_USERNAME}"
fi
