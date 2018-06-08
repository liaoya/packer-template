#!/bin/bash -eux

echo "==> Run clean proxy script"

sed -i "/^ftp_proxy/Id" /etc/environment
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment
sed -i "/^rysnc_proxy/Id" /etc/environment

[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf || true
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy  || true
[ -f /etc/dnf/dnf.conf ] && sed -i "/^proxy/Id" /etc/dnf/dnf.conf || true
[ -f /etc/yum.conf ] && sed -i "/^proxy/Id" /etc/yum.conf || true

[ -f /etc/docker/daemon.json ] && rm -f /etc/docker/daemon.json || true
[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ] && rm -f /etc/systemd/system/docker.service.d/http-proxy.conf && systemctl daemon-reload || true

[ -f /etc/apt/sources.list.origin ] && yes | cp -pr /etc/apt/sources.list.origin /etc/apt/sources.list || true
[ -d /etc/yum.repos.d ] && { cd /etc/yum.repos.d; ls -1 *.origin 1>/dev/null 2&>1 && for elem in $(ls -1 *.origin); do yes | cp -f $elem $(basename -s .origin $elem); done } || true
