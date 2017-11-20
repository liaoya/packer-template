#!/bin/bash -eux

echo "==> Install OpenvSwitch"
if [[ -n $OFFICIAL_BUILD && $OFFICIAL_BUILD -gt 1 ]]; then
    apt-get install -y -qq "Dpkg::Use-Pty=0" openvswitch-switch >/dev/null
else
    datapath=$(ls /tmp/output/openvswitch-datapath-module-$(uname -r)*.deb)
    [[ -n $datapath ]] || datapath=$(ls -1 /tmp/output/openvswitch-datapath-module-*.deb | tail -n 1) 
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" $(ls -1 /tmp/output/libopenvswitch_*.deb | tail -n 1) $(ls -1 /tmp/output/openvswitch-common*.deb | tail -n 1) $(ls -1 /tmp/output/openvswitch-switch*.deb | tail -n 1) $datapath >/dev/null
fi

apt list --installed 2>/dev/null | grep openvswitch

echo "==> Enable net.ipv4.ip_forward"
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
