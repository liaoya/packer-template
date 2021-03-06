#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || [[ -n ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]] || exit 0

if [[ -n  ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]]; then
    echo "==> Install Fedora docker-ce packages"
    dnf -y -q install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    releasever=$(cut -d " " -f 3 /etc/fedora-release)
    # The docker-ce for current release has not available
    if ! curl -sL "https://download.docker.com/linux/fedora/${releasever}/x86_64/stable/Packages/" | grep -s -q 'href="docker-ce'; then
        releasever=$((releasever-1))
        sed -i "s/\$releasever/${releasever}/g" /etc/yum.repos.d/docker-ce.repo
    fi
    dnf -y -q install docker-ce
else
    echo "==> Install Fedora docker packages"
    dnf install -y -q docker
fi

cat <<EOF >>/etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

[[ $(command -v docker) ]] && systemctl enable docker
if [[ -n ${SUDO_USER} ]] && getent group docker; then usermod -aG docker "${SUDO_USER}"; fi

#curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
#curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
