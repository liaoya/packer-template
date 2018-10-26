#!/bin/bash -eux

echo "==> Run custom repository"

if [[ -d /etc/apt && -n ${APT_MIRROR_SERVER} && -n ${APT_MIRROR_PATH} ]]; then
    echo "APT_MIRROR_SERVER is \"${APT_MIRROR_SERVER}\", APT_MIRROR_PATH is \"${APT_MIRROR_PATH}\""
    [ -f /etc/apt/sources.list.origin ] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    sed -i -e "s%http://.*archive.ubuntu.com%${APT_MIRROR_SERVER}${APT_MIRROR_PATH}%" /etc/apt/sources.list
    apt-get update -qq
fi

if [[ -f /etc/fedora-release && -n ${DNF_MIRROR_SERVER} && -n ${DNF_MIRROR_PATH} ]]; then
    echo "DNF_MIRROR_SERVER is \"${DNF_MIRROR_SERVER}\", DNF_MIRROR_PATH is \"${DNF_MIRROR_PATH}\""
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

if [[ -f /etc/centos-release && -n ${YUM_MIRROR_SERVER} && -n ${YUM_MIRROR_EPEL_PATH} && -n ${YUM_MIRROR_PATH} ]]; then
    for elem in /etc/yum.repos.d/CentOS*.repo; do [ -f "${elem}.origin" ] || cp "${elem}" "${elem}.origin"; done
    for elem in /etc/yum.repos.d/CentOS*.repo; do 
        grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
        grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
        grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
        sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
        sed -i -e "s%^baseurl=http://mirror.centos.org/centos%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" "${elem}"
    done
    yum install -y -q epel-release

    for elem in /etc/yum.repos.d/epel*.repo; do [ -f "${elem}.origin" ] || cp "${elem}" "${elem}.origin"; done
    for elem in /etc/yum.repos.d/epel*.repo; do
        grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
        grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
        grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
        grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
        sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
        sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" "${elem}"
    done

    CENTOS_RELEASE=$(rpm -q --qf '%{VERSION}' "$(rpm -qf /etc/redhat-release)")
    yum install -y -q "https://centos${CENTOS_RELEASE}.iuscommunity.org/ius-release.rpm"
    if yum repolist enabled | grep -s -q "^ius/"; then yum-config-manager --disable ius > /dev/null; fi
    
#    yum install -y -q https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${CENTOS_RELEASE}.noarch.rpm
#    yum install -y -q https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${CENTOS_RELEASE}.noarch.rpm
#    yum install -y -q http://rpms.remirepo.net/enterprise/remi-release-${CENTOS_RELEASE}.rpm
#    yum install -y -q http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el${CENTOS_RELEASE}.noarch.rpm
fi

if [[ -f /etc/oracle-release && -f /etc/yum.conf ]]; then
    version=$(cut -d " " -f 5 /etc/oracle-release)
    sed -i "s/https:/http:/g" /etc/yum.repos.d/public-yum-ol7.repo
    yum install -y -q yum-utils
    if ! yum repolist all | grep -s -w -q ol7_developer_EPEL; then
        cat << 'EOF' >>/etc/yum.repos.d/public-yum-ol7.repo

[ol7_developer_EPEL]
name=Oracle Linux $releasever Development Packages ($basearch)
baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/developer_EPEL/$basearch/
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-oracle
gpgcheck=1
enabled=1
EOF
    else
        if yum repolist disabled | grep -s -q ol7_developer_EPEL; then yum-config-manager --enable "ol7_developer_EPEL" >/dev/null; then
    fi
    yum repolist disabled | grep -s -w -q ol7_addons | yum-config-manager --enable grep ol7_addons > /dev/null || true
    yum repolist disabled | grep -s -w -q ol7_optional_latest | yum-config-manager --enable grep ol7_optional_latest > /dev/null || true
    RELEASE=$(echo "${version}" | cut -d '.' -f 1)
    yum install -y -q "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${RELEASE}.noarch.rpm" "https://rhel${RELEASE}.iuscommunity.org/ius-release.rpm"
    if yum repolist enabled | grep -s -q "^epel/"; then yum-config-manager --disable epel > /dev/null; fi
fi
