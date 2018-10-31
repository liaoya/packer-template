#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo "==> Install libvirt software"

apt-get install -y -qq -o "Dpkg::Use-Pty=0" qemu-kvm libvirt-bin virtinst >/dev/null

if [[ -n ${SUDO_USER} ]] && getent group libvirtd; then adduser "${SUDO_USER}" libvirtd; fi
if [[ -n ${SUDO_USER} ]] && getent group libvirt; then adduser "${SUDO_USER}" libvirt; fi
if [[ -n ${SUDO_USER} ]] && getent group kvm; then usermod -aG kvm "${SUDO_USER}"; fi
