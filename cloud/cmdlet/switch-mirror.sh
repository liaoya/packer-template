#!/bin/bash

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
#    NPM_MIRROR_SERVER="https://registry.npm.taobao.org"
#    PIP_MIRROR_SERVER="http://mirrors.aliyun.com/pypi/simple"
    YUM_MIRROR_SERVER="http://mirrors.ustc.edu.cn/"
    YUM_MIRROR_EPEL_PATH="/epel"
    YUM_MIRROR_PATH="/centos"
fi

if [[ -d /etc/apt ]]; then
    [[ -f /etc/apt/sources.list.origin ]] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    [[ -f /etc/apt/sources.list.origin ]] && cp -pr /etc/apt/sources.list.origin /etc/apt/sources.list
    sed -i -e "s%http://.*archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" -e "s%http://security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list
fi

if [[ -f /etc/fedora-release && -n ${DNF_MIRROR_SERVER} && -n ${DNF_MIRROR_PATH} ]]; then
    echo "DNF_MIRROR_SERVER is \"${DNF_MIRROR_SERVER}\", DNF_MIRROR_PATH is \"${DNF_MIRROR_PATH}\""
    for elem in /etc/yum.repos.d/fedora*.repo; do
        [[ -e "${elem}" ]] || continue
        [[ -f "${elem}.origin" ]] || cp "${elem}" "${elem}.origin"
        [[ -f "${elem}.origin" ]] && cp -fpr "${elem}.origin" "${elem}"
        grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
        grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
        grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
        sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub/fedora/linux%baseurl=${DNF_MIRROR_SERVER}${DNF_MIRROR_PATH}%g" "${elem}"
    done
    dnf install -y -q yum-utils
    # I find the issue when use a specific mirror on Fedora 28
    sed -i "s%os/%%g" /etc/yum.repos.d/fedora-updates.repo
fi

if [[ -f /etc/centos-release && -f /etc/yum.conf && -n $YUM_MIRROR_SERVER && -n $YUM_MIRROR_EPEL_PATH && -n $YUM_MIRROR_PATH ]]; then
    for elem in /etc/yum.repos.d/CentOS*.repo; do
        [[ -e "${elem}" ]] || continue
        [[ -f "${elem}.origin" ]] || cp "${elem}" "${elem}.origin"
        [[ -f "${elem}.origin" ]] && cp -fpr "${elem}.origin" "${elem}"
        grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
        grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
        grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
        sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
        sed -i -e "s%^baseurl=http://mirror.centos.org/centos%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" "${elem}"
    done
    yum install -y -q epel-release

    for elem in /etc/yum.repos.d/epel*.repo; do
        [[ -e "${elem}" ]] || continue
        [[ -f "${elem}.origin" ]] || cp "${elem}" "${elem}.origin"
        [[ -f "${elem}.origin" ]] && cp -fpr "${elem}.origin" "${elem}"
        grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
        grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
        grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
        grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
        sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" "${elem}"
    done

    # CENTOS_RELEASE=$(rpm -q --qf '%{VERSION}' "$(rpm -qf /etc/redhat-release)")
    # yum install -y -q "https://centos${CENTOS_RELEASE}.iuscommunity.org/ius-release.rpm"
    curl -sL https://setup.ius.io/ -o- | bash
    if yum repolist enabled | grep -s -q "^ius/"; then yum-config-manager --disable ius > /dev/null; fi

    curl -sL https://copr.fedorainfracloud.org/coprs/outman/emacs/repo/epel-7/outman-emacs-epel-7.repo -o /etc/yum.repos.d/emacs-copr.repo
    
#    yum install -y -q https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${CENTOS_RELEASE}.noarch.rpm
#    yum install -y -q https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${CENTOS_RELEASE}.noarch.rpm
#    yum install -y -q http://rpms.remirepo.net/enterprise/remi-release-${CENTOS_RELEASE}.rpm
#    yum install -y -q http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el${CENTOS_RELEASE}.noarch.rpm
fi

if [[ -f /etc/oracle-release && -f /etc/yum.conf ]]; then
    [[ -f /etc/yum.repos.d/public-yum-ol7.repo.origin ]] || mv /etc/yum.repos.d/public-yum-ol7.repo /etc/yum.repos.d/public-yum-ol7.repo.origin
    curl -sL https://yum.oracle.com/public-yum-ol7.repo -o /etc/yum.repos.d/public-yum-ol7.repo
    sed -i "s/https:/http:/g" /etc/yum.repos.d/public-yum-ol7.repo
    yum install -y -q yum-utils
    if yum repolist disabled | grep -s -q ol7_developer_EPEL; then yum-config-manager --enable "ol7_developer_EPEL" >/dev/null; fi
    if yum repolist disabled | grep -s -w -q ol7_addons; then yum-config-manager --enable grep ol7_addons > /dev/null; fi
    if yum repolist disabled | grep -s -w -q ol7_optional_latest; then yum-config-manager --enable grep ol7_optional_latest > /dev/null; fi
    version=$(cut -d " " -f 5 /etc/oracle-release)
    RELEASE=$(echo "${version}" | cut -d '.' -f 1)
    yum install -y -q "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${RELEASE}.noarch.rpm" "https://rhel${RELEASE}.iuscommunity.org/ius-release.rpm"
    if yum repolist enabled | grep -s -q "^epel/"; then yum-config-manager --disable epel > /dev/null; fi

    curl -sL https://copr.fedorainfracloud.org/coprs/outman/emacs/repo/epel-7/outman-emacs-epel-7.repo -o /etc/yum.repos.d/emacs-copr.repo
fi

if [[ -f /etc/fedora-release && -f /etc/dnf/dnf.conf && -n $DNF_MIRROR_SERVER && -n $DNF_MIRROR_PATH ]]; then
    for elem in /etc/yum.repos.d/fedora*.repo; do [ -f "${elem}.origin" ] || cp "${elem}" "${elem}.origin"; done
    for elem in /etc/yum.repos.d/fedora*.repo; do
        grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
        grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
        grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
        sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub/fedora/linux%baseurl=${DNF_MIRROR_SERVER}${DNF_MIRROR_PATH}%g" "${elem}"
    done
    dnf install -y -q yum-utils
    # I find the issue when use a specific mirror on Fedora 28
    sed -i "s%os/%%g" /etc/yum.repos.d/fedora-updates.repo
fi

[[ -n ${DOCKER_MIRROR_SERVER} ]] && cat <<EOF >> /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$(echo ${DOCKER_MIRROR_SERVER} | sed -e 's%http://%%' -e 's%https://%%')"],
    "registry-mirrors": ["${DOCKER_MIRROR_SERVER}"]
}
EOF
