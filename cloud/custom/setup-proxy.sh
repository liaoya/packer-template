#!/bin/bash -eux

echo "==> Run custom setup proxy script"

if [[ -n $http_proxy ]]; then
    echo "==> Put $http_proxy to /etc/environment"
    cat <<EOF > /etc/environment
http_proxy=$http_proxy
https_proxy=$https_proxy
ftp_proxy=$http_proxy
no_proxy="$no_proxy"
HTTP_PROXY=$http_proxy
HTTPS_PROXY=$https_proxy
FTP_PROXY=$http_proxy
NO_PROXY="$no_proxy"
EOF
fi

[[ ! -n $APT_PROXY && -n $http_proxy ]] && APT_PROXY=$http_proxy
if [[ -n $APT_PROXY && -d /etc/apt/apt.conf.d ]]; then
    echo "==> Use $APT_PROXY for apt"
    cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$APT_PROXY";
Acquire::https::proxy "$APT_PROXY";
EOF
fi

[[ ! -n $YUM_PROXY && -n $http_proxy ]] && YUM_PROXY=$http_proxy
[[ -f /etc/yum.conf && -n $YUM_PROXY ]] && { echo "==> Use $YUM_PROXY for yum"; sed -i "/^installonly_limit/i proxy=$YUM_PROXY" /etc/yum.conf; } || true
[[ -f /etc/dnf/dnf.conf && -n $YUM_PROXY ]] && { echo "==> Use $YUM_PROXY for dnf"; sed -i "/^installonly_limit/i proxy=$YUM_PROXY" /etc/dnf/dnf.conf; } || true

mkdir -p /etc/systemd/system/docker.service.d/
[[ -n $http_proxy ]] && cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="NO_PROXY=$no_proxy"
EOF
if [[ -n $DOCKER_MIRROR_SERVER ]]; then
    mkdir -p /etc/docker
    DOCKER_MIRROR_SERVER_IP=$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%')
    cat <<EOF > /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$DOCKER_MIRROR_SERVER_IP"],
    "registry-mirrors": ["$DOCKER_MIRROR_SERVER"]
}
EOF
    [[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]] && { grep -s -q $DOCKER_MIRROR_SERVER_IP /etc/systemd/system/docker.service.d/http-proxy.conf || sed -i  "s/NO_PROXY=/&$DOCKER_MIRROR_SERVER_IP,/" /etc/systemd/system/docker.service.d/http-proxy.conf; }
    [[ $(command -v docker) ]] && systemctl daemon-reload && systemctl restart docker
fi
