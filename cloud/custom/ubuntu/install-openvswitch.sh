#!/bin/bash -eux

if [[ -n $OVS_BUILD && "$OVS_BUILD" == "true" ]]; then
    datapath=$(ls /tmp/output/openvswitch-datapath-module-$(uname -r)*.deb)
    [[ -n $datapath ]] || datapath=$(ls -1 /tmp/output/openvswitch-datapath-module-*.deb | tail -n 1) 
    [[ -n $datapath ]] && apt-get install -y -qq -o "Dpkg::Use-Pty=0" $(ls -1 /tmp/output/libopenvswitch_*.deb | tail -n 1) $(ls -1 /tmp/output/openvswitch-common*.deb | tail -n 1) $(ls -1 /tmp/output/openvswitch-switch*.deb | tail -n 1) $datapath >/dev/null || true
    [[ -n $datapath ]] && echo "==> Install $(ls -1 /tmp/output/libopenvswitch_*.deb | tail -n 1) $(ls -1 /tmp/output/openvswitch-common*.deb | tail -n 1) $(ls -1 /tmp/output/openvswitch-switch*.deb | tail -n 1) $datapath"
fi

[[ $(command -v ovs-vsctl) ]] || { echo '==> Install Unbuntu OpenvSwitch'; apt-get install -y -qq -o "Dpkg::Use-Pty=0" openvswitch-switch >/dev/null; }

[[ -n ${SSH_USERNAME} ]] && getent group openvswitch && usermod -aG openvswitch ${SSH_USERNAME} || true

apt list --installed 2>/dev/null | grep openvswitch
apt-get install -y -qq -o "Dpkg::Use-Pty=0" bridge-utils >/dev/null

echo "==> Enable net.ipv4.ip_forward"
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
