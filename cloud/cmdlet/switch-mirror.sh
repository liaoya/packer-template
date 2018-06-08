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
[[ -n $LOCATION ]] || { echo "Please specify a location (cn|jp)"; exit 1; }

if [[ $LOCATION == "jp" ]]; then
    APT_MIRROR_SERVER="http://ftp.jaist.ac.jp"
    APT_MIRROR_PATH="/pub/Linux/ubuntu"
    DNF_MIRROR_SERVER="http://ftp.jaist.ac.jp"
    DNF_MIRROR_PATH="/pub/Linux/Fedora"
    YUM_MIRROR_SERVER="http://ftp.jaist.ac.jp"
    YUM_MIRROR_EPEL_PATH="/pub/Linux/Fedora"
    YUM_MIRROR_PATH="/pub/Linux/CentOS"
elif [[ $LOCATION == "cn" ]]; then
    APT_MIRROR_SERVER="http://mirrors.ustc.edu.cn/"
    APT_MIRROR_PATH="/ubuntu"
    DNF_MIRROR_SERVER="http://mirrors.ustc.edu.cn/"
    DNF_MIRROR_PATH="/fedora"
    DOCKER_MIRROR_SERVER="registry.docker-cn.com"
    NPM_MIRROR_SERVER="https://registry.npm.taobao.org"
    PIP_MIRROR_SERVER="http://mirrors.aliyun.com/pypi/simple"
    YUM_MIRROR_SERVER="http://mirrors.ustc.edu.cn/"
    YUM_MIRROR_EPEL_PATH="/epel"
    YUM_MIRROR_PATH="/centos"
fi

if [[ -d /etc/apt ]]; then
    [ -f /etc/apt/sources.list.origin ] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    [ -f /etc/apt/sources.list.origin ] && yes | cp -pr /etc/apt/sources.list.origin /etc/apt/sources.list || true
    sed -i -e "s%http://.*archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" -e "s%http://security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list
fi

# (cd /etc/yum.repos.d; for elem in $(ls -1 *.origin); do yes | cp -f $elem $(basename -s .origin $elem); done)

if [[ -f /etc/centos-release && -f /etc/yum.conf && -n $YUM_MIRROR_SERVER && -n $YUM_MIRROR_EPEL_PATH && -n $YUM_MIRROR_PATH ]]; then
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
        grep -s -q -e "^metalink=" ${elem} && sed -i -e "s/^metalink=/#metalink=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" ${elem}    
    done
fi

if [[ -f /etc/oracle-release && -f /etc/yum.conf ]]; then
    sed -i "s/https:/http:/g" /etc/yum.repos.d/public-yum-ol7.repo
    yum install -y -q yum-utils
    yum repolist disabled | grep -s -q ol7_developer_EPEL &&  yum-config-manager --enable "ol7_developer_EPEL"
    yum repolist disabled | grep -s -w -q ol7_addons | sudo yum-config-manager --enable grep ol7_addons
fi

if [[ -f /etc/fedora-release && -f /etc/dnf/dnf.conf && -n $DNF_MIRROR_SERVER && -n $DNF_MIRROR_PATH ]]; then
    for elem in $(ls -1 /etc/yum.repos.d/fedora*.repo); do [ -f ${elem}.origin ] || cp ${elem} ${elem}.origin; done
    for elem in $(ls -1 /etc/yum.repos.d/fedora*.repo); do
        grep -s -q -e "^metalink=" ${elem} && sed -i -e "s/^metalink=/#metalink=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub/fedora/linux%baseurl=${DNF_MIRROR_SERVER}${DNF_MIRROR_PATH}%g" ${elem}
    done
    # I find the issue when use a specific mirror on Fedora 28
    sed -i "s%os/%%g" /etc/yum.repos.d/fedora-updates.repo
fi

[[ -n $DOCKER_MIRROR_SERVER ]] && cat <<EOF >> /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$(echo $DOCKER_MIRROR_SERVER | sed -e 's%http://%%' -e 's%https://%%')"],
    "registry-mirrors": ["$DOCKER_MIRROR_SERVER"]
}
EOF
