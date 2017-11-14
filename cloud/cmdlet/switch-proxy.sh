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
[[ -n $LOCATION ]] || { echo "Please specify a location"; exit 1; }

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
ftp_proxy=$HTTP_PROXY
no_proxy="$NO_PROXY"
HTTP_PROXY=$HTTP_PROXY
HTTPS_PROXY=$HTTP_PROXY
FTP_PROXY=$HTTP_PROXY
NO_PROXY="$NO_PROXY"
EOF

[ -f /etc/yum.conf ] && sed -i "/^proxy/Id" /etc/yum.conf
[ -f /etc/dnf/dnf.conf ] && sed -i "/^proxy/Id" /etc/dnf/yum.conf
[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ] && rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
[ -f /etc/docker/daemon.json ] && rm -f /etc/docker/daemon.json

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

APT_MIRROR_SERVER="http://ftp.jaist.ac.jp"
APT_MIRROR_PATH="/pub/Linux/ubuntu"

if [[ -d /etc/apt ]]; then
    [ -f /etc/apt/sources.list.origin ] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    sed -i -e "s%http://.*archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" -e "s%http://security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list
fi

YUM_MIRROR_SERVER="http://ftp.jaist.ac.jp"
YUM_MIRROR_EPEL_PATH="/pub/Linux/Fedora"
YUM_MIRROR_PATH="/pub/Linux/CentOS"

# (cd /etc/yum.repos.d; for elem in $(ls -1 *.origin); do yes | cp -f $elem $(basename -s .origin $elem); done)

if [[ -f /etc/yum.conf && -n $YUM_MIRROR_SERVER && -n $YUM_MIRROR_EPEL_PATH && -n $YUM_MIRROR_PATH ]]; then
    for elem in $(ls -1 /etc/yum.repos.d/CentOS*.repo); do [ -f ${elem}.origin ] || cp ${elem} ${elem}.origin; done
    for elem in $(ls -1 /etc/yum.repos.d/CentOS*.repo); do 
        grep -s -q -e "^mirrorlist=" ${elem} && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://mirror.centos.org/centos%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" ${elem}
    done
    yum install -y -q epel-release

    for elem in $(ls -1 /etc/yum.repos.d/epel*.repo); do [ -f ${elem}.origin ] || cp ${elem} ${elem}.origin; done
    for elem in $(ls -1 /etc/yum.repos.d/epel*.repo); do
        grep -s -q -e "^mirrorlist=" ${elem} && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" ${elem}    
    done
fi

DNF_MIRROR_SERVER="http://ftp.jaist.ac.jp"
DNF_MIRROR_PATH="/pub/Linux/Fedora"

if [[ -f /etc/dnf/dnf.conf && -n $DNF_MIRROR_SERVER && -n $DNF_MIRROR_PATH ]]; then
    for item in $(ls -1 /etc/yum.repos.d/fedora*.repo); do [ -f ${item}.origin ] || cp ${item} ${item}.origin; done
    for item in $(ls -1 /etc/yum.repos.d/fedora*.repo); do
        grep -s -q -e "^metalink=" ${elem} && sed -i -e "s/^metalink=/#metalink=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub/fedora/linux%baseurl=${DNF_MIRROR_SERVER}${DNF_MIRROR_PATH}%g" ${elem}
    done
fi
