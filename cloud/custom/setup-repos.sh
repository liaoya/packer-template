#!/bin/bash -eux

echo "==> Run custom repository"

if [[ -d /etc/apt && -n ${APT_MIRROR_SERVER} && -n ${APT_MIRROR_PATH} ]]; then
    echo "APT_MIRROR_SERVER is \"${APT_MIRROR_SERVER}\", APT_MIRROR_PATH is \"${APT_MIRROR_PATH}\""
    if [[ ! -f /etc/apt/sources.list.origin ]]; then cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin; fi
    sed -i -e "s%http://.*archive.ubuntu.com%${APT_MIRROR_SERVER}${APT_MIRROR_PATH}%" /etc/apt/sources.list
    apt-get update -qq
fi

if [[ -f /etc/fedora-release ]]; then
    for elem in /etc/yum.repos.d/fedora*.repo; do
        if [[ ! -f "${elem}.origin" ]]; then cp "${elem}" "${elem}.origin"; fi
        if [[ -f "${elem}.origin" ]]; then cp -fpr "${elem}.origin" "${elem}"; fi
        sed -i "s/arch=\$basearch/arch=\$basearch\&type=http/g" "${elem}"
    done
fi

if [[ -f /etc/centos-release && -n ${YUM_MIRROR_SERVER} && -n ${YUM_MIRROR_EPEL_PATH} && -n ${YUM_MIRROR_PATH} ]]; then
# This return the major version number on CentOS and return major.minor on Oracle Linux
    CENTOS_RELEASE=$(rpm -q --qf '%{VERSION}' "$(rpm -qf /etc/redhat-release)")

    if [[ ${CENTOS_RELEASE} == 7 ]]; then
        yum install -q -y yum-utils
        yum install -y -q epel-release

        for elem in /etc/yum.repos.d/CentOS-*.repo; do
            if [[ -f "${elem}.origin" ]]; then
                cp -fpr "${elem}.origin" "${elem}"
            else
                cp "${elem}" "${elem}.origin"
            fi
            grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
            grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
            grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
            sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
            sed -i -e "s%^baseurl=http://mirror.centos.org/centos%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" "${elem}"
        done

        for elem in /etc/yum.repos.d/epel-*.repo; do
            if [[ -f "${elem}.origin" ]]; then
                cp -fpr "${elem}.origin" "${elem}"
            else
                cp "${elem}" "${elem}.origin"
            fi
            grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
            grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
            grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
            grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
            sed -i -e "s%^baseurl=.*%#&\\n&%g" "${elem}"
            sed -i -e "s%^baseurl=http://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" "${elem}"
        done

        if ! yum repolist all | grep -s -q "^ius/"; then
            curl -sL https://setup.ius.io/ -o- | bash
        fi
        sed -i "s/https:/http:/g" /etc/yum.repos.d/ius*.repo

        for repo_url in "http://download.opensuse.org/repositories/shells:/fish:/release:/3/RHEL_${CENTOS_RELEASE}/shells:fish:release:3.repo" \
                        "https://copr.fedorainfracloud.org/coprs/outman/emacs/repo/epel-${CENTOS_RELEASE}/outman-emacs-epel-${CENTOS_RELEASE}.repo" \
                        "https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-${CENTOS_RELEASE}/carlwgeorge-ripgrep-epel-${CENTOS_RELEASE}.repo" \
                        "https://copr.fedorainfracloud.org/coprs/ganto/vcsh/repo/epel-${CENTOS_RELEASE}/ganto-vcsh-epel-${CENTOS_RELEASE}.repo"
        do
            yum-config-manager --add-repo "${repo_url}"
        done

        # yum install -y -q https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${CENTOS_RELEASE}.noarch.rpm
        # yum install -y -q https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${CENTOS_RELEASE}.noarch.rpm
        # yum install -y -q http://rpms.remirepo.net/enterprise/remi-release-${CENTOS_RELEASE}.rpm
        # yum install -y -q http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el${CENTOS_RELEASE}.noarch.rpm
    elif [[ ${CENTOS_RELEASE} == 8 ]]; then
        dnf install -q -y centos-release-stream epel-release elrepo-release
        dnf install -q -y yum-utils
        dnf config-manager --enable PowerTools
        dnf install -q -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-8.noarch.rpm \
                            https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-8.noarch.rpm

        for elem in /etc/yum.repos.d/CentOS-*.repo; do
            grep -s -q -e "^mirrorlist=" "${elem}" && sed -i -e "s/^mirrorlist=/#mirrorlist=/g" "${elem}"
            grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
            grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
            sed -i -e "s%^baseurl=.*%#&\n&%g" "${elem}"
            sed -i -e "s%^baseurl=http://mirror.centos.org/\$contentdir%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_PATH}%g" "${elem}"
        done

        for elem in /etc/yum.repos.d/epel*.repo; do [ -f "${elem}.origin" ] || cp "${elem}" "${elem}.origin"; done
        for elem in /etc/yum.repos.d/epel*.repo; do
            grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
            grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
            grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
            sed -i -e "s%^baseurl=.*%#&\n&%g" "${elem}"
            sed -i -e "s%^baseurl=https://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" "${elem}"
        done
    fi
fi

if [[ -f /etc/oracle-release && -f /etc/yum.conf ]]; then
    VERSION=$(cut -d " " -f 5 /etc/oracle-release)
    ORACLE_RELEASE=$(echo "${VERSION}" | cut -d '.' -f 1)

    if [[ ${ORACLE_RELEASE} == 7 ]]; then
        if ! rpm -q "oraclelinux-release-el${ORACLE_RELEASE}"; then
            if [[ -f "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo" ]]; then
                if [[ -f "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo.origin" ]]; then
                    sed -i "s/https:/http:/g" "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo"
                else
                    sed -i.origin "s/https:/http:/g" "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo"
                fi
            fi
            yum install -y -q "oraclelinux-release-el${ORACLE_RELEASE}"
            if [[ -f "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo.origin" ]]; then
                cp -f "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo.origin" "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo"
            fi
        fi
        if [[ -f "/etc/yum.repos.d/public-yum-ol${ORACLE_RELEASE}.repo" && -x /usr/bin/ol_yum_configure.sh ]]; then
            /usr/bin/ol_yum_configure.sh
            rm -f /etc/yum.repos.d/public-yum-ol*
        fi
        for item in /etc/yum.repos.d/*"ol${ORACLE_RELEASE}.repo"; do
            if [[ ! -f "$item.origin" ]]; then cp "$item" "$item.origin"; fi
        done
        sed -i "s/https:/http:/g" /etc/yum.repos.d/*"ol${ORACLE_RELEASE}.repo"
        yum install -y -q "oracle-epel-release-el${ORACLE_RELEASE}"
        for item in /etc/yum.repos.d/*"ol${ORACLE_RELEASE}.repo"; do
            if [[ ! -f "$item.origin" ]]; then cp "$item" "$item.origin"; fi
        done
        sed -i "s/https:/http:/g" /etc/yum.repos.d/*"ol${ORACLE_RELEASE}.repo"

        if [[ -z $(command -v repomanage) ]]; then yum install -y -q yum-utils; fi
        if yum repolist disabled | grep -s -q "ol${ORACLE_RELEASE}_developer_EPEL"; then yum-config-manager --enable "ol${ORACLE_RELEASE}_developer_EPEL" >/dev/null; fi
        if yum repolist disabled | grep -s -w -q "ol${ORACLE_RELEASE}_addons"; then yum-config-manager --enable grep "ol${ORACLE_RELEASE}_addons" > /dev/null; fi
        if yum repolist disabled | grep -s -w -q "ol${ORACLE_RELEASE}_optional_latest"; then yum-config-manager --enable grep "ol${ORACLE_RELEASE}_optional_latest" > /dev/null; fi

        if ! yum repolist all | grep -s -q "^ius/"; then
            yum install -y -q "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${ORACLE_RELEASE}.noarch.rpm" "https://rhel${ORACLE_RELEASE}.iuscommunity.org/ius-release.rpm"
            if yum repolist enabled | grep -s -q "^epel/"; then yum-config-manager --disable epel > /dev/null; fi
            sed -i "s/https:/http:/g" /etc/yum.repos.d/ius*.repo
        fi

        for repo_url in "http://download.opensuse.org/repositories/shells:/fish:/release:/3/RHEL_${CENTOS_RELEASE}/shells:fish:release:3.repo" \
                        "https://copr.fedorainfracloud.org/coprs/outman/emacs/repo/epel-${CENTOS_RELEASE}/outman-emacs-epel-${CENTOS_RELEASE}.repo" \
                        "https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-${CENTOS_RELEASE}/carlwgeorge-ripgrep-epel-${CENTOS_RELEASE}.repo" \
                        "https://copr.fedorainfracloud.org/coprs/ganto/vcsh/repo/epel-${CENTOS_RELEASE}/ganto-vcsh-epel-${CENTOS_RELEASE}.repo"
        do
            yum-config-manager --add-repo "${repo_url}"
        done
    elif [[ ${ORACLE_RELEASE} == 8 ]]; then
        if [[ -f /etc/oracle-release && -f /etc/dnf/dnf.conf ]]; then
            sed -i -e "s|https://yum\$ociregion.oracle.com|http://yum\$ociregion.oracle.com|g" /etc/yum.repos.d/*.repo
            sed -i -e "s|https://yum.oracle.com|http://yum.oracle.com|g" /etc/yum.repos.d/*.repo

            dnf install -q -y "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${ORACLE_RELEASE}.noarch.rpm"
        fi
        for elem in /etc/yum.repos.d/epel*.repo; do [ -f "${elem}.origin" ] || cp "${elem}" "${elem}.origin"; done
        for elem in /etc/yum.repos.d/epel*.repo; do
            grep -s -q -e "^metalink=" "${elem}" && sed -i -e "s/^metalink=/#metalink=/g" "${elem}"
            grep -s -q -e "^#baseurl=" "${elem}" && grep -s -q -e "^baseurl=" "${elem}" && sed -i -e "/^baseurl=/d" "${elem}";
            grep -s -q -e "^#baseurl=" "${elem}" && sed -i -e "s/^#baseurl=/baseurl=/g" "${elem}"
            sed -i -e "s%^baseurl=.*%#&\n&%g" "${elem}"
            sed -i -e "s%^baseurl=https://download.fedoraproject.org/pub%baseurl=${YUM_MIRROR_SERVER}${YUM_MIRROR_EPEL_PATH}%g" "${elem}"
        done
    fi
fi
