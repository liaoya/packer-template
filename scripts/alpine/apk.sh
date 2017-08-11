set -eux

[ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh

apk update
apk add wget file sshpass tmux vlan

if [ $PACKER_BUILDER_TYPE == "qemu" ]; then
    apk add qemu-guest-agent
fi

if [ $PACKER_BUILDER_TYPE == "virtualbox-iso" ]; then
    apk add virtualbox-guest-additions virtualbox-guest-modules-virthardened
    echo "vboxpci" >> /etc/modules
    echo "vboxdrv" >> /etc/modules
    echo "vboxsf" >> /etc/modules
fi
