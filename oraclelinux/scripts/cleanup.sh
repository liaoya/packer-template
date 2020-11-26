#!/bin/bash

set -ex

if [[ "$PACKER_BUILDER_TYPE" = "qemu" ]]; then
    echo 'GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,115200 console=tty1"' >> /etc/default/grub
#    grub2-mkconfig -o /boot/grub2/grub.cfg
fi

# For docker
cat <<EOF >>/etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

# Do not overwrite /etc/resolv.conf
if [[ -f /etc/NetworkManager/NetworkManager.conf ]]; then
    sed -i '/^plugins=ifcfg-rh/a dns=none' /etc/NetworkManager/NetworkManager.conf
fi

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/
rm -f /etc/udev/rules.d/80-net-name-slot.rules
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules

for ndev in /etc/sysconfig/network-scripts/ifcfg-*; do
    if [ "$ndev" != "/etc/sysconfig/network-scripts/ifcfg-lo" ]; then
        sed -i '/PEER/d' "$ndev"
        sed -i '/^HWADDR/d' "$ndev"
        sed -i '/^UUID/d' "$ndev"
    fi
done

# delete any logs that have built up during the install
find /var/log/ -name "*.log" -exec rm -f {} \;
rm -fr /tmp/*

passwd -d root
passwd -l root
sync
shutdown -P now
