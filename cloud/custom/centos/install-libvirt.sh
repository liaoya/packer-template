#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for centos'

yum install -y -q libvirt qemu-kvm-ev virt-install virt-top libvirt-python
[[ -n ${SSH_USERNAME} ]] && getent group libvirtd && usermod -aG libvirtd ${SSH_USERNAME} || true
[[ -n ${SSH_USERNAME} ]] && getent group kvm && usermod -aG kvm ${SSH_USERNAME} || true
