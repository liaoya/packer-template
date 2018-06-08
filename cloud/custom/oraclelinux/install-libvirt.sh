#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo "==> Install Orace Linux docker packages"

yum install -y -q libvirt qemu-kvm libguestfs virt-install

[[ -n ${SSH_USERNAME} ]] && getent group libvirt && usermod -aG libvirt ${SSH_USERNAME} || true
[[ -n ${SSH_USERNAME} ]] && getent group kvm && usermod -aG kvm ${SSH_USERNAME} || true
[[ -n ${SSH_USERNAME} ]] && getent group qemu && usermod -aG qemu ${SSH_USERNAME} || true
