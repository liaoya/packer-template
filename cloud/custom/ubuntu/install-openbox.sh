#!/bin/bash -eux

echo "==> Install OpenBox and VNC"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" xorg openbox xdm xcompmgr cairo-dock vnc4server >/dev/null
[[ -n $SSH_USERNAME ]] && su -l $SSH_USERNAME -c 'mkdir -p ~/.config/openbox; echo "xcompmgr &" >> ~/.config/openbox/autostart; echo "cairo-dock &" >> ~/.config/openbox/autostart'
[[ -n $SSH_USERNAME ]] && su -l $SSH_USERNAME -c 'mkdir -p $HOME/.vnc; echo -e "123456\n123456\n" | vncpasswd'
[[ -n $SSH_USERNAME ]] && su -l $SSH_USERNAME -c 'vncserver; sed -i "s/x-window-manager/openbox-session/" ~/.vnc/xstartup; vncserver -kill :1'

SSH_USERNAME=root
[[ -n $SSH_USERNAME ]] && su -l $SSH_USERNAME -c 'mkdir -p ~/.config/openbox; echo "xcompmgr &" >> ~/.config/openbox/autostart; echo "cairo-dock &" >> ~/.config/openbox/autostart'
[[ -n $SSH_USERNAME ]] && su -l $SSH_USERNAME -c 'mkdir -p $HOME/.vnc; echo -e "123456\n123456\n" | vncpasswd'
[[ -n $SSH_USERNAME ]] && su -l $SSH_USERNAME -c 'vncserver; sed -i "s/x-window-manager/openbox-session/" ~/.vnc/xstartup; vncserver -kill :1'
