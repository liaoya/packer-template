#!/bin/bash -eux

if [[ -n $OVS_BUILD && "$OVS_BUILD" == true ]]; then
    echo "==> Install $(ls -1 /tmp/output/*openvswitch*.rpm | grep -v -E "debug|devel|ovn|noarch")"
    yum install -y -q $(ls -1 /tmp/output/*openvswitch*.rpm | grep -v -E "debug|devel|ovn|noarch")
fi

[[ $(command -v ovs-vsctl) ]] || { echo '==> Install OpenvSwitch from CentOS OpenStack'; yum install -y -q openvswitch; }
systemctl enable openvswitch

[[ -n ${SSH_USERNAME} ]] && getent group openvswitch && usermod -aG openvswitch ${SSH_USERNAME} || true

sed -i "/net.ipv4.ip_forward/d" /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
