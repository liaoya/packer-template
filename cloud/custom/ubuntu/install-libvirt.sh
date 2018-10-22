#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo "==> Install libvirt software"

apt-get install -y -qq -o "Dpkg::Use-Pty=0" qemu-kvm libvirt-bin virtinst >/dev/null

[[ -n ${SSH_USERNAME} ]] && getent group libvirtd && (adduser "${SSH_USERNAME}" libvirtd || true)
[[ -n ${SSH_USERNAME} ]] && getent group libvirt && (adduser "${SSH_USERNAME}" libvirt || true)
[[ -n ${SSH_USERNAME} ]] && getent group kvm && (usermod -aG kvm "${SSH_USERNAME}" || true)
