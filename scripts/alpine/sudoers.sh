set -eux

[ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh

apk add sudo
adduser vagrant wheel

cat << EOF >> /etc/sudoers
Defaults exempt_group=wheel
%wheel ALL=NOPASSWD:ALL

Defaults    env_reset
Defaults    env_keep =  "COLORS DISPLAY HOSTNAME HISTSIZE KDEDIR LS_COLORS"
Defaults    env_keep += "MAIL PS1 PS2 QTDIR USERNAME LANG LC_ADDRESS LC_CTYPE"
Defaults    env_keep += "LC_COLLATE LC_IDENTIFICATION LC_MEASUREMENT LC_MESSAGES"
Defaults    env_keep += "LC_MONETARY LC_NAME LC_NUMERIC LC_PAPER LC_TELEPHONE"
Defaults    env_keep += "LC_TIME LC_ALL LANGUAGE LINGUAS _XKB_CHARSET XAUTHORITY"
Defaults    env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY NO_PROXY"
Defaults    env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"

Defaults    secure_path = /sbin:/bin:/usr/sbin:/usr/bin:/usr/local/bin
EOF

