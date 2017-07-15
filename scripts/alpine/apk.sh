set -eux

[ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh

apk add wget file sshpass tmux vlan qemu-guest-agent
