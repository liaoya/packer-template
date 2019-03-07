#!/bin/bash

set -e -x

echo "==> Run custom clean script"

echo "==> Run clean proxy script"
[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment

echo "==> Removing APT files"
find /var/lib/apt -type f -exec rm -f {} \;
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;
rm -fr /tmp/*
