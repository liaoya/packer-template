#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo "==> Install libvirt software"

apt-get install -y -qq -o "Dpkg::Use-Pty=0" qemu-kvm libvirt-bin virtinst >/dev/null

if [[ -n ${SSH_USERNAME} ]] && getent group libvirtd; then adduser "${SSH_USERNAME}" libvirtd; fi
if [[ -n ${SSH_USERNAME} ]] && getent group libvirt; then adduser "${SSH_USERNAME}" libvirt; fi
if [[ -n ${SSH_USERNAME} ]] && getent group kvm; then usermod -aG kvm "${SSH_USERNAME}"; fi
