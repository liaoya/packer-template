#!/bin/bash

echo -e "\\n" | add-apt-repository ppa:kelleyk/emacs
echo -e "\\n" | add-apt-repository ppa:fish-shell/release-3
echo -e "\\n" | add-apt-repository ppa:kimura-o/ppa-tig
echo -e "\\n" | add-apt-repository ppa:lazygit-team/release
echo -e "\\n" | ppa:alexlarsson/flatpak
apt install -yq flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
