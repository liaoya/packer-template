#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0
echo '==> Install libvirt for CentOS'

yum install -y -q libvirt libvirt-daemon-kvm qemu-kvm virt-install virt-top libvirt-python
if [[ -n ${SUDO_USER} ]]; then
    if getent group libvirtd; then adduser "${SUDO_USER}" libvirtd; fi
    if getent group libvirt; then adduser "${SUDO_USER}" libvirt; fi
    if getent group qemu; then usermod -aG qemu "${SUDO_USER}"; fi
    if getent group kvm; then usermod -aG kvm "${SUDO_USER}"; fi
    su -l "${SUDO_USER}" -c 'echo export LIBVIRT_DEFAULT_URI="qemu:///system" >> ~/.bashrc'
fi

# all normal user to access virsh
# https://computingforgeeks.com/use-virt-manager-as-non-root-user/
# sed -i -e "s/#unix_sock_group/unix_sock_group/" -e "s/#unix_sock_rw_perms/unix_sock_rw_perms/" libvirtd.conf
# https://www.hogarthuk.com/?q=node/2
