#!/bin/bash -eux

echo "==> Run custom repository"

if [[ -d /etc/apt && -n ${APT_MIRROR_SERVER} && -n ${APT_MIRROR_PATH} ]]; then
    echo "APT_MIRROR_SERVER is \"${APT_MIRROR_SERVER}\", APT_MIRROR_PATH is \"${APT_MIRROR_PATH}\""
    [[ -f /etc/apt/sources.list.origin ]] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    sed -i -e "s%http://.*archive.ubuntu.com%${APT_MIRROR_SERVER}${APT_MIRROR_PATH}%" /etc/apt/sources.list
    apt-get update -qq
fi

if [[ -f /etc/fedora-release ]]; then
    for elem in /etc/yum.repos.d/fedora*.repo; do
        [[ -f "${elem}.origin" ]] || cp "${elem}" "${elem}.origin"
        [[ -f "${elem}.origin" ]] && cp -fpr "${elem}.origin" "${elem}"
        sed -i "s/arch=\$basearch/arch=\$basearch\&type=http/g" "${elem}"
    done
fi

if [[ -f /etc/centos-release && -n ${YUM_MIRROR_SERVER} && -n ${YUM_MIRROR_EPEL_PATH} && -n ${YUM_MIRROR_PATH} ]]; then
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

    curl -sL https://setup.ius.io/ -o- | bash
    if yum repolist enabled | grep -s -q "^ius/"; then yum-config-manager --disable ius > /dev/null; fi

#    CENTOS_RELEASE=$(rpm -q --qf '%{VERSION}' "$(rpm -qf /etc/redhat-release)")
#    yum install -y -q https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${CENTOS_RELEASE}.noarch.rpm
#    yum install -y -q https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${CENTOS_RELEASE}.noarch.rpm
#    yum install -y -q http://rpms.remirepo.net/enterprise/remi-release-${CENTOS_RELEASE}.rpm
#    yum install -y -q http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el${CENTOS_RELEASE}.noarch.rpm
fi

if [[ -f /etc/oracle-release && -f /etc/yum.conf ]]; then
    version=$(cut -d " " -f 5 /etc/oracle-release)
    RELEASE=$(echo "${version}" | cut -d '.' -f 1)
    if ! rpm -q "oraclelinux-release-el${RELEASE}"; then
        if [[ -f "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo" ]]; then
            if [[ -f "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo.origin" ]]; then
                sed -i "s/https:/http:/g" "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo"
            else
                sed -i.origin "s/https:/http:/g" "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo"
            fi
        fi
        yum install -y -q "oraclelinux-release-el${RELEASE}"
        if [[ -f "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo.origin" ]]; then
            cp -f "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo.origin" "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo"
        fi
    fi
    if [[ -f "/etc/yum.repos.d/public-yum-ol${RELEASE}.repo" && -x /usr/bin/ol_yum_configure.sh ]]; then
        /usr/bin/ol_yum_configure.sh
        rm -f /etc/yum.repos.d/public-yum-ol*
    fi
    for item in /etc/yum.repos.d/*"ol${RELEASE}.repo"; do
        if [[ ! -f "$item.origin" ]]; then cp "$item" "$item.origin"; fi
    done
    sed -i "s/https:/http:/g" /etc/yum.repos.d/*"ol${RELEASE}.repo"
    yum install -y -q "oracle-epel-release-el${RELEASE}"
    for item in /etc/yum.repos.d/*"ol${RELEASE}.repo"; do
        if [[ ! -f "$item.origin" ]]; then cp "$item" "$item.origin"; fi
    done
    sed -i "s/https:/http:/g" /etc/yum.repos.d/*"ol${RELEASE}.repo"

    yum install -y -q yum-utils
    if yum repolist disabled | grep -s -q "ol${RELEASE}_developer_EPEL"; then yum-config-manager --enable "ol${RELEASE}_developer_EPEL" >/dev/null; fi
    if yum repolist disabled | grep -s -w -q "ol${RELEASE}_addons"; then yum-config-manager --enable grep "ol${RELEASE}_addons" > /dev/null; fi
    if yum repolist disabled | grep -s -w -q "ol${RELEASE}_optional_latest"; then yum-config-manager --enable grep "ol${RELEASE}_optional_latest" > /dev/null; fi

    yum install -y -q "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${RELEASE}.noarch.rpm" "https://rhel${RELEASE}.iuscommunity.org/ius-release.rpm"
    if yum repolist enabled | grep -s -q "^epel/"; then yum-config-manager --disable epel > /dev/null; fi
fi
