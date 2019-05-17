#!/bin/bash

# Ubuntu minimal image does not has add-apt-repository
if [[ -z $(command -v add-apt-repository) ]]; then
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" software-properties-common apt-utils >/dev/null
fi
add-apt-repository -u -y ppa:kelleyk/emacs
add-apt-repository -u -y ppa:fish-shell/release-3
add-apt-repository -u -y ppa:kimura-o/ppa-tig
add-apt-repository -u -y ppa:lazygit-team/release
add-apt-repository -u -y ppa:alexlarsson/flatpak
# apt-get install -y -qq -o "Dpkg::Use-Pty=0"  flatpak >/dev/null
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
