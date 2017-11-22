#!/bin/bash -eux

echo "==> Run Ubuntu custom setup script"

# https://superuser.com/questions/203272/list-only-the-device-names-of-all-available-network-interfaces
# https://unix.stackexchange.com/questions/335461/predictable-network-interface-names-break-vm-migration
if grep -s -q -e '^GRUB_CMDLINE_LINUX=""' /etc/default/grub; then
    echo "==> Change ethernet interface naming rule"

    DEVICE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
    [ -f /etc/network/interfaces ] && sed -i "s/$DEVICE/eth0/g" /etc/network/interfaces
    [ -f /etc/network/interfaces.d/50-cloud-init.cfg ] && sed -i "s/$DEVICE/eth0/g" /etc/network/interfaces.d/50-cloud-init.cfg
    [ -f /etc/udev/rules.d/70-persistent-net.rules ] && rm -f /etc/udev/rules.d/70-persistent-net.rules
    sed -i 's/^GRUB_CMDLINE_LINUX=".*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
    update-grub
fi

if [[ $PACKER_BUILDER_TYPE == qemu ]]; then
    if grep -s -q -e '^GRUB_CMDLINE_LINUX_DEFAULT=""' /etc/default/grub; then
        echo "==> Enable serial login"
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,115200 console=tty0"/' /etc/default/grub
        update-grub
    fi
fi

# Handle netplan from ubuntu 17.10
if [[ -d /etc/netplan ]]; then
    rm -f /etc/netplan/*
    netplan apply
fi
