#!/bin/bash

[[ -n ${CUSTOM_SNAP} && "${CUSTOM_SNAP^^}" == "TRUE" ]] || exit 0

if [[ ! $(command -v snap) ]]; then
    if [[ ! $(command -v dnf) ]]; then
        dnf install -y -q snapd
    elif [[ ! $(command -v yum) ]]; then
        yum install -y -q snapd || true # Will fail on Oracle Linux
    elif [[ ! $(command -v apt-get) ]]; then
        apt-get install -y -qq -o "Dpkg::Use-Pty=0" snapd >/dev/null
    fi
fi

if [[ $(command -v snap) ]]; then
    mkdir -p /etc/systemd/system/snapd.service.d/
    cat <<EOF >/etc/systemd/system/snapd.service.d/override.conf
[Service]
EnvironmentFile=/etc/environment
EOF
    systemctl daemon-reload && systemctl restart snapd
fi
