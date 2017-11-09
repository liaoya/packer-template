#!/bin/bash -eux

echo "==> Run custom setup script"

if grep -s -q "PermitRootLogin prohibit-password" /etc/ssh/sshd_config; then
    echo "==> Enable root remote ssh login"
    sed -i 's/^PermitRootLogin.*/PermitRootLogin yes/g' /etc/ssh/sshd_config
    echo "root:ubuntu" | chpasswd
fi

# https://superuser.com/questions/203272/list-only-the-device-names-of-all-available-network-interfaces
# https://unix.stackexchange.com/questions/335461/predictable-network-interface-names-break-vm-migration
if grep -s -q -e '^GRUB_CMDLINE_LINUX=""' /etc/default/grub; then
    echo "==> Change ethernet interface naming rule"

    DEVICE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo)
    [ -f /etc/network/interfaces ] && sed -i "s/$DEVICE/eth0/g" /etc/network/interfaces
    [ -f /etc/network/interfaces.d/50-cloud-init.cfg ] && sed -i "s/$DEVICE/eth0/g" /etc/network/interfaces.d/50-cloud-init.cfg
    [ -f /etc/udev/rules.d/70-persistent-net.rules ] && rm -f /etc/udev/rules.d/70-persistent-net.rules
    sed -i 's/^GRUB_CMDLINE_LINUX=".*/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/' /etc/default/grub
    update-grub
fi

if [[ $PACKER_BUILDER_TYPE == qemu ]]; then
    if grep -s -q -e '^GRUB_CMDLINE_LINUX_DEFAULT=""' /etc/default/grub; then
        echo "==> Enable serial login"
        sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT=".*/GRUB_CMDLINE_LINUX_DEFAULT="console=ttyS0,115200 console=tty0"/' /etc/default/grub
        update-grub
    fi
fi

SSH_USER="vagrant"
SSH_GROUP="users"
SSH_PASS="vagrant"
SSH_USER_HOME=/home/${SSH_USER}
VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"

if ! id -u $SSH_USER >/dev/null 2>&1; then
    echo "==> Creating $SSH_USER user"
    useradd $SSH_USER -g $SSH_GROUP -m -c "$SSH_USER" -s /bin/bash
    echo -e "$SSH_PASS\n$SSH_PASS\n" | passwd $SSH_USER
    if id -u ubuntu >/dev/null 2>&1; then
        declare -a -r groups=($(id -G ubuntu))
        for item in ${groups[@]}; do usermod -aG $item $SSH_USER; done
        gpasswd -d $SSH_USER $(id -gn ubuntu)
    fi

    echo "==> Giving ${SSH_USER} sudo powers"
    echo "${SSH_USER}        ALL=(ALL)       NOPASSWD: ALL" > /etc/sudoers.d/$SSH_USER
    chown "root:root" /etc/sudoers.d/$SSH_USER
    chmod 440 /etc/sudoers.d/$SSH_USER

    echo "==> Installing vagrant key"
    runuser -l $SSH_USER -c "mkdir $SSH_USER_HOME/.ssh"
    runuser -l $SSH_USER -c "chmod 700 $SSH_USER_HOME/.ssh"
    echo "${VAGRANT_INSECURE_KEY}" > $SSH_USER_HOME/.ssh/authorized_keys
    chown "$SSH_USER:$(id -gn $SSH_USER)" $SSH_USER_HOME/.ssh/authorized_keys
    chmod 600 $SSH_USER_HOME/.ssh/authorized_keys
fi
