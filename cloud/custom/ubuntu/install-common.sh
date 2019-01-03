#!/bin/bash -eux

echo "==> Install Ubuntu common packages"

# https://askubuntu.com/questions/912623/how-to-permanently-disable-swap-file
grep -s -q -w "swapfile" /etc/fstab && { echo "==> Disable swapfile"; swapoff /swapfile; sed -i "s/^\\/swapfile/d" /etc/fstab; }

systemctl stop apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer || true
systemctl disable apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer || true

apt-get install -y -qq -o "Dpkg::Use-Pty=0" zip unzip bzip2 xz-utils screen httpie fish git tig jq sshpass tmux moreutils >/dev/null

if [[ $(command -v python3) ]]; then
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" python3-distutils >/dev/null
fi
if [[ $(command -v python2) ]]; then
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" python2-distutils >/dev/null
fi

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then apt upgrade -y -qq -o "Dpkg::Use-Pty=0" >/dev/null; fi
