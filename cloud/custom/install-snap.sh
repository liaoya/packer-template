#!/bin/bash

[[ -n ${CUSTOM_SNAP} && "${CUSTOM_SNAP}" == "true" ]] || exit 0

if [[ ! $(command -v dnf) ]]; then
    dnf install -y -q snapd
elif [[ ! $(command -v yum) ]]; then
    yum install -y -q snapd || true # Will fail on Oracle Linux
fi

if [[ $(command -v snapd) ]]; then
    mkdir -p /etc/systemd/system/snapd.service.d/
    cat <<EOF >/etc/systemd/system/snapd.service.d/override.conf
[Service]
EnvironmentFile=/etc/environment
EOF
    systemctl daemon-reload && systemctl restart snapd
fi
