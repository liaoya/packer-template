#!/bin/bash -eux
#shellcheck disable=SC2154

echo "==> Run custom setup proxy script"

if [[ -n ${http_proxy} ]]; then
    echo "==> Put ${http_proxy} to /etc/environment"
    cat <<EOF > /etc/environment
http_proxy=${http_proxy}
https_proxy=${https_proxy}
ftp_proxy=${http_proxy}
no_proxy="${no_proxy}"
HTTP_PROXY=${http_proxy}
HTTPS_PROXY=${https_proxy}
FTP_PROXY=${http_proxy}
NO_PROXY="${no_proxy}"
EOF
fi

[[ ! -n ${APT_PROXY} && -n ${http_proxy} ]] && APT_PROXY=${http_proxy}
if [[ -n ${APT_PROXY} && -d /etc/apt/apt.conf.d ]]; then
    echo "==> Use ${APT_PROXY} for apt"
    cat <<EOF > /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "${APT_PROXY}";
Acquire::https::proxy "${APT_PROXY}";
EOF
fi

[[ ! -n ${YUM_PROXY} && -n ${http_proxy} ]] && YUM_PROXY=${http_proxy}
if [[ -f /etc/yum.conf && -n ${YUM_PROXY} ]]; then
    echo "==> Use ${YUM_PROXY} for yum"
    sed -i "/^installonly_limit/i proxy=${YUM_PROXY}" /etc/yum.conf
fi
if [[ -f /etc/dnf/dnf.conf && -n ${YUM_PROXY} ]]; then
    echo "==> Use ${YUM_PROXY} for dnf"
    sed -i "/^installonly_limit/i proxy=${YUM_PROXY}" /etc/dnf/dnf.conf
fi

if [[ -n ${http_proxy} ]]; then
    echo "==> Use ${http_proxy} for /etc/systemd/system/docker.service.d/http-proxy.conf"
    mkdir -p /etc/systemd/system/docker.service.d/
    cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${http_proxy}"
Environment="NO_PROXY=${no_proxy}"
EOF
fi

if [[ -n ${DOCKER_MIRROR_SERVER} ]]; then
    echo "==> Use ${DOCKER_MIRROR_SERVER} for /etc/docker/daemon.json"
    mkdir -p /etc/docker
    DOCKER_MIRROR_SERVER_IP=$(echo "${DOCKER_MIRROR_SERVER}" | sed -e 's%http://%%' -e 's%https://%%')
    cat <<EOF > /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["${DOCKER_MIRROR_SERVER_IP}"],
    "registry-mirrors": ["${DOCKER_MIRROR_SERVER}"]
}
EOF
    if [[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]]; then
        if grep -s -q "${DOCKER_MIRROR_SERVER_IP}" /etc/systemd/system/docker.service.d/http-proxy.conf; then
            echo "==> Add ${DOCKER_MIRROR_SERVER_IP} to /etc/systemd/system/docker.service.d/http-proxy.conf NO_PROXY list"
            sed -i "s/NO_PROXY=/&${DOCKER_MIRROR_SERVER_IP},/" /etc/systemd/system/docker.service.d/http-proxy.conf
        fi
    fi
    if [[ $(command -v docker) ]]; then
        echo "==> Restart docker daemon"
        systemctl daemon-reload && systemctl restart docker
    fi
fi
