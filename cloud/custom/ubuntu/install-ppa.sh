#!/bin/bash

add-apt-repository -y ppa:kelleyk/emacs
add-apt-repository -y ppa:fish-shell/release-3
add-apt-repository -y ppa:kimura-o/ppa-tig
add-apt-repository -y ppa:lazygit-team/release
add-apt-repository -y ppa:alexlarsson/flatpak
# apt-get install -y -qq -o "Dpkg::Use-Pty=0"  flatpak >/dev/null
# flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
