#!/bin/bash -eux
#shellcheck disable=SC2046

echo "==> Run clean proxy script"

sed -i "/^ftp_proxy/Id" /etc/environment
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment
sed -i "/^rysnc_proxy/Id" /etc/environment

if [[ -f /etc/apt/apt.conf ]]; then sed -i "/::proxy/Id" /etc/apt/apt.conf; fi
if [[ -f /etc/apt/apt.conf.d/01proxy ]]; then rm -f /etc/apt/apt.conf.d/01proxy; fi
if [[ -f /etc/dnf/dnf.conf ]]; then sed -i "/^proxy/Id" /etc/dnf/dnf.conf; fi
if [[ -f /etc/yum.conf ]]; then sed -i "/^proxy/Id" /etc/yum.conf; fi

if [[ -f /etc/docker/daemon.json ]]; then rm -f /etc/docker/daemon.json; fi
if [[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]]; then
    rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
    systemctl daemon-reload
fi

if [[ -f /etc/apt/sources.list.origin ]]; then cp -fpr /etc/apt/sources.list.origin /etc/apt/sources.list; fi
if [[ -d /etc/yum.repos.d ]]; then
    (cd /etc/yum.repos.d; for elem in *.origin; do yes | cp -f "$elem" $(basename -s .origin "$elem"); done)
fi
