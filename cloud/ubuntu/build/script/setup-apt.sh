#!/bin/bash

# The proxy must be setup by vagrant-proxyconf plugin

if [[ ${http_proxy} =~ "cn-proxy.jp.oracle.com" || ${http_proxy} =~ "10.182.17" || ${http_proxy} =~ "10.113" ]]; then
    echo "==> Use Jaist as Ubuntu mirror"
    [ -f /etc/apt/sources.list.origin ] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    sed -i -e 's%jp.archive.ubuntu.com%ftp.jaist.ac.jp/pub/Linux%' /etc/apt/sources.list
    sed -i -e 's%archive.ubuntu.com%ftp.jaist.ac.jp/pub/Linux%' /etc/apt/sources.list
    sed -i -e 's%security.ubuntu.com%ftp.jaist.ac.jp/pub/Linux%' /etc/apt/sources.list
    sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list
fi

systemctl stop apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer
systemctl disable apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer

apt-get update -qq

apt-get install -qq -y -o "Dpkg::Use-Pty=0" build-essential autoconf automake pkg-config >/dev/null
