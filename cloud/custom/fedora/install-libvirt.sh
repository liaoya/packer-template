#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for Fedora'

dnf install -y -q qemu-kvm libvirt virt-install bridge-utils
systemctl enable libvirtd
systemctl start libvirtd

if [[ -n ${SUDO_USER} ]]; then
    if getent group libvirtd; then usermod -aG libvirtd "${SUDO_USER}"; fi
    if getent group libvirt; then usermod -aG libvirt "${SUDO_USER}"; fi
    if getent group qemu; then usermod -aG qemu "${SUDO_USER}"; fi
    if getent group kvm; then usermod -aG kvm "${SUDO_USER}"; fi
    su -l "${SUDO_USER}" -c 'echo export LIBVIRT_DEFAULT_URI="qemu:///system" >> ~/.bashrc'

fi
