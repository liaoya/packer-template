#!/bin/bash -eux

mkdir -p ~/Documents ~/Downloads

echo "==> Setup Common config"
[[ -n ${VM_NAME} && $(command -v hostnamectl) ]] && echo "Set hostname to ${VM_NAME}" && hostnamectl set-hostname ${VM_NAME} || true
[[ -f /etc/selinux/config ]] && sed -i "s/^SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config && sed -i "s/^SELINUX=permissive/SELINUX=disabled/g" /etc/selinux/config
echo "root:cloud" | chpasswd


echo "==> Enhance sshd"
grep -s -q -w "UseDNS yes" /etc/ssh/sshd_config && sed -i "/UseDNS/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i UseDNS no" /etc/ssh/sshd_config
grep -s -q -w "GSSAPIAuthentication yes" /etc/ssh/sshd_config && sed -i "/GSSAPIAuthentication/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i GSSAPIAuthentication no" /etc/ssh/sshd_config
grep -s -q -w "GSSAPICleanupCredentials yes" /etc/ssh/sshd_config && sed -i "/GSSAPICleanupCredentials/d" /etc/ssh/sshd_config && sed -i "/^# no default banner path/i GSSAPICleanupCredentials no" /etc/ssh/sshd_config
sed -i "s/#PermitRootLogin.*/PermitRootLogin yes/g" /etc/ssh/sshd_config


echo "==> Enhance sudo"
sed -i "s/^.*requiretty/#Defaults requiretty/" /etc/sudoers
sed -i '/XAUTHORITY"$/a Defaults    env_keep += "HTTP_PROXY HTTPS_PROXY FTP_PROXY RSYNC_PROXY NO_PROXY"' /etc/sudoers
sed -i '/XAUTHORITY"$/a Defaults    env_keep += "http_proxy https_proxy ftp_proxy rsync_proxy no_proxy"' /etc/sudoers
sed -i '/^Defaults    secure_path/ s/$/:\/usr\/local\/sbin:\/usr\/local\/bin/' /etc/sudoers
SSH_USER=${SSH_USERNAME:-vagrant}
echo "$SSH_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/${SSH_USER}
