#!/bin/bash -eux

echo "==> Run custom repository"

if [[ -d /etc/apt && -n $APT_MIRROR_SERVER && -n $APT_MIRROR_PATH ]]; then
    echo "APT_MIRROR_SERVER is \"$APT_MIRROR_SERVER\", APT_MIRROR_PATH is \"$APT_MIRROR_PATH\""
    [ -f /etc/apt/sources.list.origin ] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    sed -i -e "s%http://.*archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    apt-get update -qq
fi

if [[ -f /etc/fedora-release && -n $DNF_MIRROR_SERVER && -n $DNF_MIRROR_PATH ]]; then
    echo "DNF_MIRROR_SERVER is \"$DNF_MIRROR_SERVER\", DNF_MIRROR_SERVER is \"$DNF_MIRROR_SERVER\""
    for item in $(ls -1 /etc/yum.repos.d/fedora*.repo); do [ -f ${item}.origin ] || cp ${item} ${item}.origin; done
    for elem in $(ls -1 /etc/yum.repos.d/fedora*.repo); do
        grep -s -q -e "^metalink=" ${elem} && sed -i -e "s/^metalink=/#metalink=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub/fedora/linux%baseurl=${DNF_MIRROR_SERVER}${DNF_MIRROR_PATH}%g" ${elem}
    done
    dnf install -y -q yum-utils
    # I find the issue when use a specific mirror on Fedora 28
    sed -i "s%os/%%g" /etc/yum.repos.d/fedora-updates.repo
fi

if [[ -f /etc/centos-release && -n $YUM_MIRROR_SERVER && -n $YUM_MIRROR_EPEL_PATH && -n $YUM_MIRROR_PATH ]]; then
    echo "YUM_MIRROR_SERVER is \"$YUM_MIRROR_SERVER\", YUM_MIRROR_EPEL_PATH is \"$YUM_MIRROR_EPEL_PATH\", YUM_MIRROR_PATH is \"$YUM_MIRROR_PATH\""
    for elem in $(ls -1 /etc/yum.repos.d/CentOS*.repo); do [ -f ${elem}.origin ] || cp ${elem} ${elem}.origin; done
    for elem in $(ls -1 /etc/yum.repos.d/CentOS*.repo); do 
        grep -s -q -e "^mirrorlist=" ${elem} && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" ${elem}
        grep -s -q -e "^#baseurl=" ${elem} && grep -s -q -e "^baseurl=" ${elem} && sed -i -e "/^baseurl=/d" ${elem};
        grep -s -q -e "^#baseurl=" ${elem} && sed -i -e "s/^#baseurl=/baseurl=/g" ${elem}
        sed -i -e "s%^baseurl=.*%#&\n&%g" ${elem}
        sed -i -e "s%^baseurl=http://mirror.centos.org/centos%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" ${elem}
    done

    yum install -y -q yum-utils epel-release

    for elem in $(ls -1 /etc/yum.repos.d/epel*.repo); do [ -f ${elem}.origin ] || cp ${elem} ${elem}.origin; done
    for elem in $(ls -1 /etc/yum.repos.d/epel*.repo); do
        grep -s -q -e "^mirrorlist=" ${elem} && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" ${elem}
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
fi
