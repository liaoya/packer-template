#!/bin/bash -eux

echo "==> Run clean proxy script"
[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment

[ -f /etc/docker/daemon.json ] && rm -f /etc/docker/daemon.json
[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ] && rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
systemctl daemon-reload
