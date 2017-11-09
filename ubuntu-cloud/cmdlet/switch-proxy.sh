#!/bin/bash

TEMP=`getopt -o l: --long location: -- "$@"`
eval set -- "$TEMP"

while true ; do
    case "$1" in
        -l|--location)
            LOCATION=$2 ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

[[ $EUID -gt 0 ]] && exit 1
[[ -n $LOCATION ]] || exit 1

HTTP_PROXY="http://cn-proxy.jp.oracle.com:80"
NO_PROXY="localhost,127.0.0.1,.cn.oracle.com,.jp.oracle.com,.us.oracle.com,.oraclecorp.com"
http_proxy=$HTTP_PROXY
no_proxy=$NO_PROXY

echo "==> Put proxy to /etc/environment"
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment
cat <<EOF >> /etc/environment
http_proxy=$HTTP_PROXY
https_proxy=$HTTP_PROXY
no_proxy="$NO_PROXY"
HTTP_PROXY=$HTTP_PROXY
HTTPS_PROXY=$HTTP_PROXY
NO_PROXY="$NO_PROXY"
EOF

[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ] && rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
[ -f /etc/docker/daemon.json ] && rm -f /etc/docker/daemon.json

if [[ $LOCATION == "office" ]]; then
    APT_PROXY=http://10.182.172.49:3128
    DOCKER_MIRROR_SERVER=http://10.182.172.49:5000
    no_proxy="$no_proxy,10.182.172.49"
elif [[ $LOCATION == "lab" ]]; then
    APT_PROXY=http://10.113.69.101:3128
    DOCKER_MIRROR_SERVER=http://10.113.69.101:5000
    no_proxy="$no_proxy,10.113.69.101"
fi

echo "Set Proxy for $LOCATION"
echo "\$APT_PROXY is $APT_PROXY"
echo "\$DOCKER_MIRROR_SERVER is $DOCKER_MIRROR_SERVER"

[[ -n $APT_PROXY ]] && cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$APT_PROXY";
Acquire::https::proxy "$APT_PROXY";
EOF

mkdir -p /etc/systemd/system/docker.service.d/
[[ -n $http_proxy ]] && cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="NO_PROXY=$no_proxy"
EOF
mkdir -p /etc/docker
[[ -n $DOCKER_MIRROR_SERVER ]] && cat <<EOF >> /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%')"],
    "registry-mirrors": ["$DOCKER_MIRROR_SERVER"]
}
EOF
[[ -n $DOCKER_MIRROR_SERVER ]] && sed "s/NO_PROXY=/&$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%' -e 's%:5000%%'),/" /etc/systemd/system/docker.service.d/http-proxy.conf

systemctl daemon-reload

[ -f /etc/apt/sources.list.origin ] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
sed -i -e 's%jp.archive.ubuntu.com%ftp.jaist.ac.jp/pub/Linux%' /etc/apt/sources.list
sed -i -e 's%archive.ubuntu.com%ftp.jaist.ac.jp/pub/Linux%' /etc/apt/sources.list
sed -i -e 's%security.ubuntu.com%ftp.jaist.ac.jp/pub/Linux%' /etc/apt/sources.list
sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list
