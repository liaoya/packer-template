#!/bin/bash -eux

echo '==> Install libvirt for Fedora'

dnf install -y -q qemu-kvm libvirt virt-install bridge-utils
systemctl enable libvirtd
systemctl start libvirtd

[[ -n $SSH_USERNAME ]] && getent group libvirt && usermod -aG libvirt $SSH_USERNAME || true
[[ -n $SSH_USERNAME ]] && getent group kvm && usermod -aG kvm $SSH_USERNAME || true
