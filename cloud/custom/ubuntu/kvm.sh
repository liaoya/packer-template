#!/bin/bash -eux

echo "==> Install libvirt software"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" qemu-kvm libvirt-bin virtinst bridge-utils virt-manager >/dev/null

SSH_USER=vagrant
# [[ id -u $SSH_USER >/dev/null 2>&1 ]] && { adduser $SSH_USER libvirtd; adduser $SSH_USER kvm; }
SSH_USER=ubuntu
# [[ id -u $SSH_USER >/dev/null 2>&1 ]] && { adduser $SSH_USER libvirtd; adduser $SSH_USER kvm; }
