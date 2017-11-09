#!/bin/bash -eux

# This script is not used for base ubuntu box
[[ $VM_NAME =~ ubuntu ]] && exit 0

echo "==> Run custom setup proxy script"

[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment

if [[ -n $APT_PROXY ]]; then
    echo "==> Use $APT_PROXY for apt"
    cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$APT_PROXY";
Acquire::https::proxy "$APT_PROXY";
EOF
elif [[ -n $http_proxy ]]; then
    echo "==> Use $http_proxy for apt"
    cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$http_proxy";
Acquire::https::proxy "$http_proxy";
EOF
fi

if [[ -n $http_proxy ]]; then
    echo "==> Put $http_proxy to /etc/environment"
    cat <<EOF > /etc/environment
http_proxy=$http_proxy
https_proxy=$https_proxy
no_proxy="$no_proxy"
HTTP_PROXY=$http_proxy
HTTPS_PROXY=$https_proxy
NO_PROXY="$no_proxy"
EOF
fi

mkdir -p /etc/systemd/system/docker.service.d/
[[ -n $http_proxy ]] && cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="NO_PROXY=$no_proxy"
EOF
mkdir -p /etc/docker
[[ -n $DOCKER_MIRROR_SERVER ]] && cat <<EOF > /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%')"],
    "registry-mirrors": ["$DOCKER_MIRROR_SERVER"]
}
EOF
[[ -n $DOCKER_MIRROR_SERVER ]] && sed "s/NO_PROXY=/&$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%' -e 's%:5000%%'),/" /etc/systemd/system/docker.service.d/http-proxy.conf

systemctl daemon-reload

if [[ -n $APT_MIRROR_SERVER ]]; then
    sed -i -e "s%archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e "s%security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
fi

systemctl stop apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer
systemctl disable apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer
apt-get update -qq
