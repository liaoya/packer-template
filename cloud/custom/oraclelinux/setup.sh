#!/bin/bash -eux

echo "==> Run Oracle Linux custom setup script"

# Enable serial login
[[ $PACKER_BUILDER_TYPE == qemu ]] && sed "s/console=tty0/console=tty1/g" /etc/default/grub && grub2-mkconfig -o /boot/grub2/grub.cfg 
