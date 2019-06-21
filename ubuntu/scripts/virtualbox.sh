#!/bin/bash -eux

if [[ $PACKER_BUILDER_TYPE =~ virtualbox ]]; then
    echo "==> Install virtualbox addition"
    apt-get -y -qq update
    apt-get install -y -qq virtualbox-guest-utils
# As virtualbox-guest-utils fail to start in our box, load vboxsf by mannual
    if [ -f /lib/modules/$(uname -r)/kernel/ubuntu/vbox/vboxsf/vboxsf.ko ]; then
        grep -s -q -w -e "^vboxsf" /etc/modules-load.d/modules.conf || echo "vboxsf" >> /etc/modules-load.d/modules.conf
    else
        echo "Fail to find vboxsf"
    fi
fi
