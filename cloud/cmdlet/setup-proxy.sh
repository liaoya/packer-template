#!/bin/bash

set -e

IPADDR=$(hostname -I | cut -d' ' -f1)
LOCATION=""
if [[ ${IPADDR} =~ 10.113 ]]; then LOCATION="lab"; fi
if [[ ${IPADDR} =~ 10.182.17 ]]; then LOCATION="office"; fi

TEMP=$(getopt -o l: --long location: -- "$@")
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
[ -f /etc/dnf/dnf.conf ] && sed -i "/^proxy/Id" /etc/dnf/dnf.conf
[ -f /etc/apt/apt.conf ] && sed -i "/::proxy/Id" /etc/apt/apt.conf
[ -f /etc/apt/apt.conf.d/01proxy ] && rm -f /etc/apt/apt.conf.d/01proxy
[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ] && rm -f /etc/systemd/system/docker.service.d/http-proxy.conf
[ -f /etc/docker/daemon.json ] && rm -f /etc/docker/daemon.json

http_proxy="http://www-proxy-tyo.jp.oracle.com:80"
no_proxy="localhost,127.0.0.1,$(hostname -f),$(hostname -I | cut -d " " -f 1),10.113.69.40,10.113.69.79,10.113.69.101"

if [[ $LOCATION == "office" ]]; then
    APT_PROXY=http://10.113.69.101:5900
    DOCKER_MIRROR_SERVER=http://10.113.69.101:5901
    YUM_PROXY=http://10.113.69.101:5900
    no_proxy="${no_proxy},cn.oracle.com,jp.oracle.com,us.oracle.com,oraclecorp.com"
elif [[ $LOCATION == "lab" ]]; then
    APT_PROXY=http://10.113.69.101:5900
    DOCKER_MIRROR_SERVER=http://10.113.69.101:5901
    YUM_PROXY=http://10.113.69.101:5900
    no_proxy="${no_proxy}"
fi

echo "Put proxy to /etc/environment"

cat <<EOF >> /etc/environment
http_proxy=${http_proxy}
https_proxy=${http_proxy}
ftp_proxy=${http_proxy}
no_proxy="${no_proxy}"
HTTP_PROXY=${http_proxy}
HTTPS_PROXY=${http_proxy}
FTP_PROXY=${http_proxy}
NO_PROXY="${no_proxy}"
EOF

cat <<EOF > /etc/profile.d/proxy.sh
proxy_on() {
    export http_proxy=${http_proxy}
    export https_proxy=${http_proxy}
    export ftp_proxy=${http_proxy}
    export no_proxy="${no_proxy}"
    export HTTP_PROXY=${http_proxy}
    export HTTPS_PROXY=${http_proxy}
    export FTP_PROXY=${http_proxy}
    export NO_PROXY="${no_proxy}"
}
proxy_off() {
    unset ftp_proxy http_proxy https_proxy no_proxy FTP_PROXY HTTP_PROXY HTTPS_PROXY NO_PROXY 
}
EOF

echo "Set Proxy for $LOCATION"
echo "\${APT_PROXY} is ${APT_PROXY}"
echo "\${DOCKER_MIRROR_SERVER} is ${DOCKER_MIRROR_SERVER}"
echo "\${YUM_PROXY} is ${YUM_PROXY}"
echo "\${http_proxy} is ${http_proxy}"
echo "\${no_proxy} is ${no_proxy}"

[[ -d /etc/apt/apt.conf.d ]] && [[ -n ${APT_PROXY} ]] && cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "${APT_PROXY}";
Acquire::https::proxy "${APT_PROXY}";
EOF

[[ -f /etc/yum.conf && -n ${YUM_PROXY} ]] && sed -i "/^installonly_limit/i proxy=${YUM_PROXY}" /etc/yum.conf

[[ -f /etc/dnf/dnf.conf && -n ${YUM_PROXY} ]] && sed -i "/^installonly_limit/i proxy=${YUM_PROXY}" /etc/dnf/dnf.conf

if [[ -n ${http_proxy} ]]; then
    echo "Use ${http_proxy} and ${no_proxy} for /etc/systemd/system/docker.service.d/http-proxy.conf"
    mkdir -p /etc/systemd/system/docker.service.d/
    cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=${http_proxy}"
Environment="HTTPS_PROXY=${http_proxy}"
Environment="NO_PROXY=${no_proxy}"
EOF
fi

if [[ $(command -v docker) && -n ${DOCKER_MIRROR_SERVER} ]]; then
    echo "Use ${DOCKER_MIRROR_SERVER} for /etc/docker/daemon.json"
    [[ -d /etc/docker ]] || mkdir -p /etc/docker
    DOCKER_MIRROR_SERVER_IP_PORT=$(echo ${DOCKER_MIRROR_SERVER} | sed -e 's%http://%%' -e 's%https://%%')
    cat <<EOF > /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["${DOCKER_MIRROR_SERVER_IP_PORT}"],
    "registry-mirrors": ["${DOCKER_MIRROR_SERVER}"]
}
EOF

    DOCKER_MIRROR_SERVER_IP=$(cut -d':' -f1 <<<"${DOCKER_MIRROR_SERVER_IP_PORT}")
    [[ -f /etc/systemd/system/docker.service.d/http-proxy.conf ]] \
        && grep "NO_PROXY" /etc/systemd/system/docker.service.d/http-proxy.conf | grep -v -s -q "${DOCKER_MIRROR_SERVER_IP}" \
        && echo "Add ${DOCKER_MIRROR_SERVER_IP} to /etc/systemd/system/docker.service.d/http-proxy.conf NO_PROXY list" \
        && sed -i "s/NO_PROXY=/&${DOCKER_MIRROR_SERVER_IP},/" /etc/systemd/system/docker.service.d/http-proxy.conf
    echo "Restart docker daemon"
    systemctl daemon-reload && systemctl restart docker
fi

if [[ $(command -v snapd) ]]; then
    mkdir -p /etc/systemd/system/snapd.service.d/
    cat <<EOF >/etc/systemd/system/snapd.service.d/override.conf
[Service]
EnvironmentFile=/etc/environment
EOF
    systemctl daemon-reload && systemctl restart snapd
fi
