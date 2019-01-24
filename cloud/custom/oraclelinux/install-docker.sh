#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || exit 0
echo "==> Install Orace Linux docker packages"

yum install -y -q yum-utils
yum repolist disabled | grep -s -w -q ol7_addons | sudo yum-config-manager --enable grep ol7_addons >/dev/null || true
yum install -y -q docker-engine

[[ $(command -v docker) ]] && systemctl enable docker
if [[ -n ${SUDO_USER} ]] && getent group docker; then usermod -aG docker "${SUDO_USER}"; fi

cat <<EOF >>/etc/sysctl.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF
