#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || [[ -n ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]] || exit 0

yum install -y -q bridge-utils

if [[ -n  ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]]; then
    echo '==> Install docker-ce for CentOS'
    if [[ -z $(command -v repomanage) ]]; then yum install -y -q yum-utils; fi
    yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo
    yum install -y -q docker-ce
    if yum repolist enabled | grep -s -q "docker-ce-stable"; then
        yum-config-manager --disable docker-ce-stable
    fi
else
    echo "==> Install CentOS docker packages"
    yum install -y -q docker
fi

cat <<EOF >> /etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

[[ $(command -v docker) ]] && systemctl enable docker
if [[ -n ${SUDO_USER} ]] && getent group docker; then usermod -aG docker "${SUDO_USER}"; fi

#curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
#curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
