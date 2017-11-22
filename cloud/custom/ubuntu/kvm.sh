#!/bin/bash -eux

echo "==> Install libvirt software"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" qemu-kvm libvirt-bin virtinst >/dev/null

[[ -n $SSH_USERNAME ]] && getent group libvirtd && adduser $SSH_USERNAME libvirtd || true
[[ -n $SSH_USERNAME ]] && getent group kvm && usermod -aG kvm $SSH_USERNAME || true
