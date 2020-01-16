#!/bin/bash

# https://askubuntu.com/questions/53146/how-do-i-get-add-apt-repository-to-work-through-a-proxy

export APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=yes
setup_ppa() {
    ppa_repo=$1; shift
    if [[ -n ${http_proxy} ]]; then
        ppa_key=$1; shift
        if [[ ${UID} -eq 0 ]]; then
            apt-key adv --keyserver-options http-proxy="$http_proxy" --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${ppa_key}"
            add-apt-repository -y -u "${ppa_repo}"
        else
            sudo apt-key adv --keyserver-options http-proxy="$http_proxy" --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "${ppa_key}"
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

# Ubuntu minimal image does not has add-apt-repository
if [[ -z $(command -v add-apt-repository) ]]; then
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" software-properties-common apt-utils >/dev/null
fi
setup_ppa ppa:kelleyk/emacs 873503A090750CDAEB0754D93FF0E01EEAAFC9CD
setup_ppa ppa:jonathonf/vim 4AB0F789CBA31744CC7DA76A8CF63AD3F06FC659
setup_ppa ppa:fish-shell/release-3 59FDA1CE1B84B3FAD89366C027557F056DC33CA5
setup_ppa ppa:kimura-o/ppa-tig 475470022784FBF6731C6CEC262F93255137610
# setup_ppa ppa:lazygit-team/release 41468D9A516AB58268042C6768CCF87596E97291
# setup_ppa ppa:alexlarsson/flatpak 690951F1A4DE0F905496E8C6C793BFA2FA577F07
# apt-get install -y -qq -o "Dpkg::Use-Pty=0"  flatpak >/dev/null
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
