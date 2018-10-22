#!/bin/bash -eux

[[ -f /etc/selinux/config ]] && sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config && sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config

dnf -y -q clean all

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/

for ndev in /etc/sysconfig/network-scripts/ifcfg-*; do
    if [ "$ndev" != "/etc/sysconfig/network-scripts/ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev"
        sed -i '/^UUID/d' "$ndev"
    fi
done

# delete any logs that have built up during the install
find /var/log/ -name "*.log" -exec rm -f {} \;
rm -fr /tmp/*
