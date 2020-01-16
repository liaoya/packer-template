#!/bin/bash

dnf -C -y remove linux-firmware

# Remove firewalld; it is required to be present for install/image building.
# but we dont ship it in cloud
dnf -C -y remove firewalld --setopt="clean_requirements_on_remove=1"

# Clean up network interface persistence
rm -f /etc/udev/rules.d/70*
rm -f /etc/udev/rules.d/70-persistent-net.rules
mkdir -p /etc/udev/rules.d/70-persistent-net.rules
rm -f /lib/udev/rules.d/75-persistent-net-generator.rules
ln -s /dev/null /etc/udev/rules.d/80-net-name-slot.rules
rm -rf /dev/.udev/

# allow we modify /etc/resolv.conf manually
[ -f /etc/NetworkManager/NetworkManager.conf ] && sed -i '/^\[main\]$/a dns=none' /etc/NetworkManager/NetworkManager.conf

rm -f /etc/sysconfig/network-scripts/ifcfg-ens*
# simple eth0 config, again not hard-coded to the build hardware
cat > /etc/sysconfig/network-scripts/ifcfg-eth0 << EOF
DEVICE="eth0"
BOOTPROTO="dhcp"
ONBOOT="yes"
TYPE="Ethernet"
USERCTL="yes"
PEERDNS="yes"
IPV6INIT="no"
PERSISTENT_DHCLIENT="1"
EOF

dnf clean all

echo "Fixing SELinux contexts."
touch /var/log/cron
touch /var/log/boot.log
mkdir -p /var/cache/yum
/usr/sbin/fixfiles -R -a restore

grep -s -q -w "UseDNS yes" /etc/ssh/sshd_config && sed -i "/UseDNS/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i UseDNS no" /etc/ssh/sshd_config
grep -s -q -w "GSSAPIAuthentication yes" /etc/ssh/sshd_config && sed -i "/GSSAPIAuthentication/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i GSSAPIAuthentication no" /etc/ssh/sshd_config
grep -s -q -w "GSSAPICleanupCredentials yes" /etc/ssh/sshd_config && sed -i "/GSSAPICleanupCredentials/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i GSSAPICleanupCredentials no" /etc/ssh/sshd_config

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i '/XAUTHORITY"$/a Defaults    env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY NO_PROXY"' /etc/sudoers
sed -i '/XAUTHORITY"$/a Defaults    env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"' /etc/sudoers
sed -i '/^Defaults    secure_path/ s/$/:\/usr\/local\/sbin:\/usr\/local\/bin/' /etc/sudoers

# delete any logs that have built up during the install
find /var/log/ -name "*.log" -exec rm -f {} \;
rm -fr /tmp/*

passwd -d root
passwd -l root
sync
shutdown -P now
