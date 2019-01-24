#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || [[ -n ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]] || exit 0

if [[ -n  ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]]; then
    echo "==> Install docer-ce for Ubuntu"
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" apt-transport-https ca-certificates curl software-properties-common >/dev/null
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker-ce.list
    apt-get update -y -qq -o "Dpkg::Use-Pty=0" >/dev/null
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" docker-ce >/dev/null
else
    echo "==> Install Ubuntu docker"
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" docker.io >/dev/null
fi

cat <<EOF >>/etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

if [[ -n ${SUDO_USER} ]]; then
    getent group docker && usermod -aG docker "${SUDO_USER}"
fi

#curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
#curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
