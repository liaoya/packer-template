#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || [[ -n ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]] || exit 0

yum install -y -q yum-utils

if [[ -n  ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]]; then
    echo "==> Install Orace Linux docker packages"

    yum repolist disabled | grep -s -w -q ol7_addons | sudo yum-config-manager --enable ol7_addons >/dev/null || true
    yum install -y -q docker-engine
else
    echo '==> Install docker-ce for Oracle Linux'
    
    yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo
    yum install -y -q docker-ce
    if yum repolist enabled | grep -s -q "docker-ce-stable"; then
        yum-config-manager --disable docker-ce-stable
    fi
fi

[[ $(command -v docker) ]] && systemctl enable docker
if [[ -n ${SUDO_USER} ]] && getent group docker; then usermod -aG docker "${SUDO_USER}"; fi

cat <<EOF >> /etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
