#!/bin/bash -eux

echo "==> Install OpenBox and VNC"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" xorg openbox xdm xcompmgr cairo-dock vnc4server >/dev/null
mkdir -p ~/.config/openbox; echo "xterm &" > ~/.config/openbox/autostart; echo "xcompmgr &" >> ~/.config/openbox/autostart; echo "cairo-dock &" >> ~/.config/openbox/autostart
[[ $SSH_USERNAME ]]su -l $SSH_USERNAME -c 'mkdir -p ~/.config/openbox; echo "xterm &" > ~/.config/openbox/autostart; echo "xcompmgr &" >> ~/.config/openbox/autostart; echo "cairo-dock &" >> ~/.config/openbox/autostart'
