#!/bin/bash -eux

echo "==> Install Ubuntu common packages"

# https://askubuntu.com/questions/912623/how-to-permanently-disable-swap-file
grep -s -q -w "swapfile" /etc/fstab && { echo "==> Disable swapfile"; swapoff /swapfile; sed -i "s/^\\/swapfile/d" /etc/fstab; }

systemctl stop apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer || true
systemctl disable apt-daily-upgrade.service apt-daily.service apt-daily-upgrade.timer apt-daily.timer || true

apt-get install -y -qq -o "Dpkg::Use-Pty=0" zip unzip bzip2 xz-utils httpie fish jq sshpass tmux moreutils >/dev/null
if [[ ! ${VM_NAME} == *"minimal"* || ! ${VM_NAME} =~ "microk8s" ]]; then
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" git tig >/dev/null
fi

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then apt upgrade -y -qq -o "Dpkg::Use-Pty=0" >/dev/null; fi
