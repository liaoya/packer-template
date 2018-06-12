#!/bin/bash -eux

# should output one of 'redhat' 'centos' 'oraclelinux'
distro="$(rpm -qf --queryformat '%{NAME}' /etc/redhat-release | cut -f 1 -d '-')"

if [ "$distro" != 'redhat' ]; then
  yum -y -q clean all;
fi

[ -f /etc/NetworkManager/NetworkManager.conf ] && sed -i '/^plugins=ifcfg-rh/a dns=none' /etc/NetworkManager/NetworkManager.conf
sed -i '/PEER/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/HWADDR/d' /etc/sysconfig/network-scripts/ifcfg-e*
sed -i '/UUID/d' /etc/sysconfig/network-scripts/ifcfg-e*
#sed -i 's/BOOTPROTO=dhcp/BOOTPROTO=none/g' /etc/sysconfig/network-scripts/ifcfg-*

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
rm -rf /dev/.udev/

for ndev in $(ls -1 /etc/sysconfig/network-scripts/ifcfg-*); do
    if [ "$(basename $ndev)" != "ifcfg-lo" ]; then
        sed -i '/^HWADDR/d' "$ndev"
        sed -i '/^UUID/d' "$ndev"
    fi
done

# delete any logs that have built up during the install
find /var/log/ -name *.log -exec rm -f {} \;
rm -fr /tmp/*
