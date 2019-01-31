#!/bin/sh
#shellcheck disable=SC1091
set -eux

[ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh
# Never install ifupdown
apk update -q --no-progress
apk add -q --no-progress bash curl nano
apk add -q --no-progress ethtool vlan
# apk add -q --no-progress sshpass wget file iproute2 net-tools

if [ "$PACKER_BUILDER_TYPE" = "qemu" ]; then
    apk add -q --no-progress qemu-guest-agent
fi

if [ "$PACKER_BUILDER_TYPE" = virtualbox-iso ]; then
    apk add -q --no-progress virtualbox-guest-additions virtualbox-guest-modules-virthardened
    rc-update add virtualbox-guest-additions
    { echo "vboxpci"; echo "vboxdrv"; echo "vboxsf"; } >> /etc/modules
fi
