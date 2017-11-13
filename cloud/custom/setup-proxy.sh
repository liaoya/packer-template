#!/bin/bash -eux

echo "==> Run custom setup proxy script"

if [[ -n $http_proxy ]]; then
    echo "==> Put $http_proxy to /etc/environment"
    cat <<EOF > /etc/environment
http_proxy=$http_proxy
https_proxy=$https_proxy
ftp_proxy=$http_proxy
no_proxy="$no_proxy"
HTTP_PROXY=$http_proxy
HTTPS_PROXY=$https_proxy
FTP_PROXY=$http_proxy
NO_PROXY="$no_proxy"
EOF
fi

[[ ! -n $APT_PROXY && -n $http_proxy ]] && APT_PROXY=$http_proxy
if [[ -n $APT_PROXY && -d /etc/apt/apt.conf.d ]]; then
    echo "==> Use $APT_PROXY for apt"
    cat <<EOF >> /etc/apt/apt.conf.d/01proxy
Acquire::http::proxy "$APT_PROXY";
Acquire::https::proxy "$APT_PROXY";
EOF
fi

[[ ! -n $YUM_PROXY && -n $http_proxy ]] && YUM_PROXY=$http_proxy
[[ -f /etc/yum.conf && -n $YUM_PROXY ]] && { echo "==> Use $YUM_PROXY for yum"; sed -i "/^installonly_limit/i proxy=$YUM_PROXY" /etc/yum.conf; }
[[ -f /etc/dnf/dnf.conf && -n $YUM_PROXY ]] && { echo "==> Use $YUM_PROXY for dnf"; sed -i "/^installonly_limit/i proxy=$YUM_PROXY" /etc/dnf/dnf.conf; }

mkdir -p /etc/systemd/system/docker.service.d/
[[ -n $http_proxy ]] && cat <<EOF >/etc/systemd/system/docker.service.d/http-proxy.conf
[Service]
Environment="HTTP_PROXY=$http_proxy"
Environment="HTTPS_PROXY=$http_proxy"
Environment="NO_PROXY=$no_proxy"
EOF
mkdir -p /etc/docker
[[ -n $DOCKER_MIRROR_SERVER ]] && cat <<EOF > /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%')"],
    "registry-mirrors": ["$DOCKER_MIRROR_SERVER"]
}
EOF
[[ -n $DOCKER_MIRROR_SERVER ]] && sed "s/NO_PROXY=/&$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%' -e 's%:5000%%'),/" /etc/systemd/system/docker.service.d/http-proxy.conf

systemctl daemon-reload

if [[ -d /etc/apt && -n $APT_MIRROR_SERVER && -n $APT_MIRROR_PATH ]]; then
    sed -i -e "s%http://us.archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e "s%http://jp.archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e "s%http://archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e "s%http://security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    systemctl stop apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer
    systemctl disable apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer    
    apt-get update -qq
fi

if [[ -f /etc/fedora-release && -n $DNF_MIRROR_SERVER && -n $DNF_MIRROR_PATH ]]; then
    for item in $(ls -1 /etc/yum.repos.d/fedora*.repo); do [ -f ${item}.origin ] || cp ${item} ${item}.origin; done
    sed -i -e "s%^metalink=https.*%#&%g" -e "s%^#baseurl=%baseurl=%" /etc/yum.repos.d/fedora*.repo
    sed -i -e "s%^baseurl=.*%#&\n&%g" /etc/yum.repos.d/fedora*.repo
    sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub/fedora/linux%baseurl=${DNF_MIRROR_SERVER}${DNF_MIRROR_PATH}%g" /etc/yum.repos.d/fedora*.repo
fi

if [[ -f /etc/centos-release && -n $YUM_MIRROR_SERVER && -n $YUM_MIRROR_EPEL_PATH && -n $YUM_MIRROR_PATH ]]; then
    for elem in $(ls -1 /etc/yum.repos.d/CentOS*.repo); do [ -f ${elem}.origin ] || cp ${elem} ${elem}.origin; done
    sed -i -e "s/^mirrorlist/#&/g" -e "s%^#baseurl=%baseurl=%" /etc/yum.repos.d/CentOS*.repo
    sed -i -e "s%^baseurl=.*%#&\n&%g" /etc/yum.repos.d/CentOS*.repo
    sed -i -e "s%^baseurl=http://mirror.centos.org/centos%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" /etc/yum.repos.d/CentOS*.repo

    [[ ! -f /etc/yum.repos.d/epel.repo.origin && -f /etc/yum.repos.d/epel.repo ]] && cp /etc/yum.repos.d/epel.repo /etc/yum.repos.d/epel.repo.origin
    [ -f /etc/yum.repos.d/epel.repo ] && sed -i -e "s/^mirrorlist/#&/g" -e "s%^#baseurl=%baseurl=%" /etc/yum.repos.d/epel.repo && sed -i -e "s%^baseurl=.*%#&\n&%g" /etc/yum.repos.d/epel.repo && sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" /etc/yum.repos.d/epel.repo
fi
