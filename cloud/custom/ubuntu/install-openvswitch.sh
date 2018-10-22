#!/bin/bash -eux

[[ -n ${CUSTOM_OPENVSWITCH} && "${CUSTOM_OPENVSWITCH}" == "true" ]] || exit 0
echo '==> Install Unbuntu OpenvSwitch'

apt-get install -y -qq -o "Dpkg::Use-Pty=0" openvswitch-switch bridge-utils >/dev/null

if [[ -n ${SSH_USERNAME} ]]; then
    getent group openvswitch && usermod -aG openvswitch "${SSH_USERNAME}"
fi

echo "==> Enable net.ipv4.ip_forward"
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.d/ovs.conf
