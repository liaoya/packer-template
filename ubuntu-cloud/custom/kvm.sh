#!/bin/bash -eux

echo "==> Install libvirt software"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" qemu-kvm libvirt-bin virtinst bridge-utils virt-manager >/dev/null
