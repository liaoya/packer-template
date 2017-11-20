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

[[ $EUID -gt 0 ]] && { echo "Only root can run this script"; exit 1; }
[[ -n $LOCATION ]] || { echo "Please specify a location (lab|office)"; exit 1; }

# Remove the previous settings

sed -i "/^ftp_proxy/Id" /etc/environment
sed -i "/^http_proxy/Id" /etc/environment
sed -i "/^https_proxy/Id" /etc/environment
sed -i "/^no_proxy/Id" /etc/environment
sed -i "/^rysnc_proxy/Id" /etc/environment
[ -f /etc/yum.conf ] && sed -i "/^proxy/Id" /etc/yum.conf
[ -f /etc/dnf/dnf.conf ] && sed -i "/^proxy/Id" /etc/dnf/yum.conf
[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ] && rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
[ -f /etc/docker/daemon.json ] && rm -f /etc/docker/daemon.json

if 

HTTP_PROXY="http://cn-proxy.jp.oracle.com:80"
NO_PROXY="localhost,127.0.0.1,.cn.oracle.com,.jp.oracle.com,.us.oracle.com,.oraclecorp.com"
http_proxy=$HTTP_PROXY
no_proxy=$NO_PROXY

echo "==> Put proxy to /etc/environment"

cat <<EOF >> /etc/environment
http_proxy=$HTTP_PROXY
https_proxy=$HTTP_PROXY
ftp_proxy=$HTTP_PROXY
no_proxy="$NO_PROXY"
HTTP_PROXY=$HTTP_PROXY
HTTPS_PROXY=$HTTP_PROXY
FTP_PROXY=$HTTP_PROXY
NO_PROXY="$NO_PROXY"
EOF

if [[ $LOCATION == "office" ]]; then
    APT_PROXY=http://10.182.172.49:3128
    DOCKER_MIRROR_SERVER=http://10.182.172.49:5000
    YUM_PROXY=http://10.182.172.49:3128
    no_proxy="$no_proxy,10.182.172.49"
elif [[ $LOCATION == "lab" ]]; then
    APT_PROXY=http://10.113.69.101:3128
    DOCKER_MIRROR_SERVER=http://10.113.69.101:5000
    YUM_PROXY=http://10.113.69.101:3128
    no_proxy="$no_proxy,10.113.69.101"
fi

echo "Set Proxy for $LOCATION"
echo "\$APT_PROXY is $APT_PROXY"
echo "\$DOCKER_MIRROR_SERVER is $DOCKER_MIRROR_SERVER"
echo "\$YUM_PROXY is $YUM_PROXY"

[[ -d /etc/apt ]] && [[ -n $APT_PROXY ]] && cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$APT_PROXY";
Acquire::https::proxy "$APT_PROXY";
EOF

[[ -f /etc/yum.conf && -n $YUM_PROXY ]] && sed -i "/^installonly_limit/i proxy=$YUM_PROXY" /etc/yum.conf

[[ -f /etc/dnf/dnf.conf && -n $YUM_PROXY ]] && sed -i "/^installonly_limit/i proxy=$YUM_PROXY" /etc/dnf/dnf.conf

mkdir -p /etc/systemd/system/docker.service.d/
[[ -n $http_proxy ]] && cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="NO_PROXY=$no_proxy"
EOF

if [[ -n $DOCKER_MIRROR_SERVER ]]; then
    mkdir -p /etc/docker
    DOCKER_MIRROR_SERVER_IP=$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%')
    cat <<EOF > /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$DOCKER_MIRROR_SERVER_IP"],
    "registry-mirrors": ["$DOCKER_MIRROR_SERVER"]
}
EOF
    [[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]] && { grep -s -q $DOCKER_MIRROR_SERVER_IP /etc/systemd/system/docker.service.d/http-proxy.conf ||  sed -i "s/NO_PROXY=/&$DOCKER_MIRROR_SERVER_IP,/" /etc/systemd/system/docker.service.d/http-proxy.conf; }
    [[ $(command -v docker) ]] && systemctl daemon-reload && systemctl restart docker
fi
