#!/bin/bash -eux

sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i '/XAUTHORITY"$/a Defaults    env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY NO_PROXY"' /etc/sudoers
sed -i '/XAUTHORITY"$/a Defaults    env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"' /etc/sudoers
sed -i '/^Defaults    secure_path/ s/$/:\/usr\/local\/sbin:\/usr\/local\/bin/' /etc/sudoers
