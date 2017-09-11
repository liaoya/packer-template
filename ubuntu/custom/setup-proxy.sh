#!/usr/bin/env bash

set -eux

echo "==> Run custom setup proxy script"

[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment

if [ -n $APT_PROXY ]; then
    cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$APT_PROXY";
Acquire::https::proxy "$APT_PROXY";
EOF
fi

if [ -n $http_proxy ]; then
    cat <<EOF >> /etc/environment
http_proxy=$http_proxy
https_proxy=$https_proxy
no_proxy="$no_proxy"
HTTP_PROXY=$http_proxy
HTTPS_PROXY=$https_proxy
NO_PROXY="$no_proxy"
EOF

fi

. /etc/lsb-release

if [ -n $APT_MIRROR_SERVER ]; then
    sed -i -e "s%archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e "s%security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
fi
