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

timedatectl set-timezone "Asia/Shanghai"

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
#shellcheck disable=SC2034
    DNF_MIRROR_SERVER="http://mirrors.ustc.edu.cn/"
#shellcheck disable=SC2034
    DNF_MIRROR_PATH="/fedora"
    DOCKER_MIRROR_SERVER="registry.docker-cn.com"
#    NPM_MIRROR_SERVER="https://registry.npm.taobao.org"
#    PIP_MIRROR_SERVER="http://mirrors.aliyun.com/pypi/simple"
    YUM_MIRROR_SERVER="http://mirrors.ustc.edu.cn/"
    YUM_MIRROR_EPEL_PATH="/epel"
    YUM_MIRROR_PATH="/centos"
fi

# https://askubuntu.com/questions/53146/how-do-i-get-add-apt-repository-to-work-through-a-proxy
setup_ppa() {
    ppa_repo=$1; shift
    if [[ -n ${http_proxy} ]]; then
        ppa_key=$1; shift
        if [[ ${UID} -eq 0 ]]; then
            apt-key adv --keyserver-options http-proxy="${http_proxy}" --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${ppa_key}"
            add-apt-repository -y -u "${ppa_repo}"
        else
            sudo apt-key adv --keyserver-options http-proxy="${http_proxy}" --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${ppa_key}"
            sudo add-apt-repository -y -u "${ppa_repo}"
        fi
    else
        if [[ ${UID} -eq 0 ]]; then
            add-apt-repository -y -u "${ppa_repo}"
        else
            sudo -E add-apt-repository -y -u "${ppa_repo}"
        fi
    fi
}

if [[ -d /etc/apt ]]; then
    [[ -f /etc/apt/sources.list.origin ]] || cp -pr /etc/apt/sources.list /etc/apt/sources.list.origin
    [[ -f /etc/apt/sources.list.origin ]] && cp -pr /etc/apt/sources.list.origin /etc/apt/sources.list
    sed -i -e "s%http://.*archive.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" -e "s%http://security.ubuntu.com%$APT_MIRROR_SERVER$APT_MIRROR_PATH%" /etc/apt/sources.list
    sed -i -e 's/^deb-src/#deb-src/' /etc/apt/sources.list

# Ubuntu minimal image does not has add-apt-repository
    if [[ -z $(command -v add-apt-repository) ]]; then
        apt-get install -y -qq -o "Dpkg::Use-Pty=0" software-properties-common apt-utils >/dev/null
    fi
    setup_ppa ppa:kelleyk/emacs 873503A090750CDAEB0754D93FF0E01EEAAFC9CD
    setup_ppa ppa:jonathonf/vim 4AB0F789CBA31744CC7DA76A8CF63AD3F06FC659
    setup_ppa ppa:fish-shell/release-3 59FDA1CE1B84B3FAD89366C027557F056DC33CA5
    setup_ppa ppa:kimura-o/ppa-tig 475470022784FBF6731C6CEC262F93255137610
    setup_ppa ppa:lazygit-team/release 41468D9A516AB58268042C6768CCF87596E97291
    setup_ppa ppa:alexlarsson/flatpak 690951F1A4DE0F905496E8C6C793BFA2FA577F07
    # apt-get install -y -qq -o "Dpkg::Use-Pty=0"  flatpak >/dev/null
    # flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

if [[ -f /etc/centos-release && -f /etc/yum.conf && -n $YUM_MIRROR_SERVER && -n $YUM_MIRROR_EPEL_PATH && -n $YUM_MIRROR_PATH ]]; then
    CENTOS_RELEASE=$(rpm -q --qf '%{VERSION}' "$(rpm -qf /etc/redhat-release)")

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

    if ! yum repolist all | grep -s -q "^epel/"; then
        yum install -y -q epel-release
    fi

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

    if ! yum repolist all | grep -s -q "^ius/"; then
        curl -sL https://setup.ius.io/ -o- | bash
    fi
    if yum repolist enabled | grep -s -q "^ius/"; then yum-config-manager --disable ius > /dev/null; fi

    if ! yum repolist all | grep -s -q "shells_fish_release_3"; then
        yum-config-manager --add-repo "http://download.opensuse.org/repositories/shells:/fish:/release:/3/RHEL_${CENTOS_RELEASE}/shells:fish:release:3.repo"
    fi
    if ! yum repolist all | grep -s -q "outman-emacs/"; then
        curl -sL "https://copr.fedorainfracloud.org/coprs/outman/emacs/repo/epel-${CENTOS_RELEASE}/outman-emacs-epel-${CENTOS_RELEASE}.repo" -o /etc/yum.repos.d/emacs-copr.repo
    fi
    if ! yum repolist all | grep -s -q "carlwgeorge-ripgrep/"; then
        curl -sL "https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-${CENTOS_RELEASE}/carlwgeorge-ripgrep-epel-${CENTOS_RELEASE}.repo" -o /etc/yum.repos.d/ripgrep.repo
    fi
    
    # if ! yum repolist all | grep -s -q "rpmfusion-free-updates"; then
    #     yum install -y -q https://download1.rpmfusion.org/free/el/rpmfusion-free-release-${CENTOS_RELEASE}.noarch.rpm
    # fi
    # if ! yum repolist all | grep -s -q "rpmfusion-nonfree-updates"; then
    #     yum install -y -q https://download1.rpmfusion.org/nonfree/el/rpmfusion-nonfree-release-${CENTOS_RELEASE}.noarch.rpm
    # fi
    # if ! yum repolist all | grep -s -q "remi-safe"; then
    #     yum install -y -q http://rpms.remirepo.net/enterprise/remi-release-${CENTOS_RELEASE}.rpm
    # fi
    # if ! yum repolist all | grep -s -q "gf/"; then
    #     yum install -y -q http://mirror.ghettoforge.org/distributions/gf/gf-release-latest.gf.el${CENTOS_RELEASE}.noarch.rpm
    # fi
fi

if [[ -f /etc/fedora-release ]]; then
    for elem in /etc/yum.repos.d/fedora*.repo; do
        [[ -f "${elem}.origin" ]] || cp "${elem}" "${elem}.origin"
        [[ -f "${elem}.origin" ]] && cp -fpr "${elem}.origin" "${elem}"
        sed -i "s/arch=\$basearch/arch=\$basearch\&type=http/g" "${elem}"
    done
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
    
    if [[ -z $(command -v repomanage) ]]; then yum install -y -q yum-utils; fi
    if yum repolist disabled | grep -s -q "ol${RELEASE}_developer_EPEL"; then yum-config-manager --enable "ol${RELEASE}_developer_EPEL" >/dev/null; fi
    if yum repolist disabled | grep -s -w -q "ol${RELEASE}_addons"; then yum-config-manager --enable grep "ol${RELEASE}_addons" > /dev/null; fi
    if yum repolist disabled | grep -s -w -q "ol${RELEASE}_optional_latest"; then yum-config-manager --enable grep "ol${RELEASE}_optional_latest" > /dev/null; fi

    if ! yum repolist all | grep -s -q "^ius/"; then
        yum install -y -q "https://dl.fedoraproject.org/pub/epel/epel-release-latest-${RELEASE}.noarch.rpm" "https://rhel${RELEASE}.iuscommunity.org/ius-release.rpm"
        if yum repolist enabled | grep -s -q "^epel/"; then yum-config-manager --disable epel > /dev/null; fi
    fi
    if yum repolist enabled | grep -s -q "^ius/"; then yum-config-manager --disable ius > /dev/null; fi

    for repo_url in "http://download.opensuse.org/repositories/shells:/fish:/release:/3/RHEL_${RELEASE}/shells:fish:release:3.repo" \
                    "https://copr.fedorainfracloud.org/coprs/outman/emacs/repo/epel-${RELEASE}/outman-emacs-epel-${RELEASE}.repo" \
                    "https://copr.fedorainfracloud.org/coprs/carlwgeorge/ripgrep/repo/epel-${RELEASE}/carlwgeorge-ripgrep-epel-${RELEASE}.repo" \
                    "https://copr.fedorainfracloud.org/coprs/hnakamur/vim/repo/epel-${RELEASE}/hnakamur-vim-epel-${RELEASE}.repo"; do
        yum-config-manager --add-repo "${repo_url}"
    done
fi

[[ -n ${DOCKER_MIRROR_SERVER} ]] && cat <<EOF >> /etc/docker/daemon.json
{
    "disable-legacy-registry": true,
    "insecure-registries": ["$(echo ${DOCKER_MIRROR_SERVER} | sed -e 's%http://%%' -e 's%https://%%')"],
    "registry-mirrors": ["${DOCKER_MIRROR_SERVER}"]
}
EOF
