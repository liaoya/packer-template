#!/bin/bash -eux
#shellcheck disable=SC2016

[[ -n ${CUSTOM_OPENBOX} && "${CUSTOM_OPENBOX}" == "true" ]] || exit 0
echo "==> Install OpenBox and VNC"

apt-get install -y -qq -o "Dpkg::Use-Pty=0" xorg openbox xdm xcompmgr cairo-dock vnc4server >/dev/null
[[ -n ${SUDO_USER} ]] && su -l "${SUDO_USER}" -c 'mkdir -p ~/.config/openbox; echo "xcompmgr &" >> ~/.config/openbox/autostart; echo "cairo-dock &" >> ~/.config/openbox/autostart'
[[ -n ${SUDO_USER} ]] && su -l "${SUDO_USER}" -c 'mkdir -p $HOME/.vnc; echo -e "123456\n123456\n" | vncpasswd'
[[ -n ${SUDO_USER} ]] && su -l "${SUDO_USER}" -c 'vncserver; sed -i "s/x-window-manager/openbox-session/" ~/.vnc/xstartup; vncserver -kill :1'

SUDO_USER=root
[[ -n ${SUDO_USER} ]] && su -l "${SUDO_USER}" -c 'mkdir -p ~/.config/openbox; echo "xcompmgr &" >> ~/.config/openbox/autostart; echo "cairo-dock &" >> ~/.config/openbox/autostart'
[[ -n ${SUDO_USER} ]] && su -l "${SUDO_USER}" -c 'mkdir -p $HOME/.vnc; echo -e "123456\n123456\n" | vncpasswd'
[[ -n ${SUDO_USER} ]] && su -l "${SUDO_USER}" -c 'vncserver; sed -i "s/x-window-manager/openbox-session/" ~/.vnc/xstartup; vncserver -kill :1'
