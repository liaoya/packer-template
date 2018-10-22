#!/bin/bash -eux

if grep -s -q -e '^datasource_list: \[ NoCloud' /etc/cloud/cloud.cfg.d/90_dpkg.cfg; then
    echo "==> Disable cloud-init"
    sed -i 's/^datasource_list.*/datasource_list: \[ None \]/' /etc/cloud/cloud.cfg.d/90_dpkg.cfg
    sed -i 's/lock_passwd: True/lock_passwd: False/' /etc/cloud/cloud.cfg
# https://askubuntu.com/questions/459402/how-to-know-if-the-running-platform-is-ubuntu-or-centos-with-help-of-a-bash-scri
# https://makandracards.com/operations/42688-how-to-remove-cloud-init-from-ubuntu
    systemctl disable cloud-config cloud-final cloud-init-local cloud-init
fi
