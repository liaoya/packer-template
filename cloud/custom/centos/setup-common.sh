#! /bin/bash

[[ -n $VM_NAME ]] && hostnamectl set-hostname $VM_NAME || true

yum install -y -q sshpass screen

echo "==> Install self built software"
declare -a pkgs=($(ls -1 /tmp/output/fish*.txz | sort | tail -n 1) \
    $(ls -1 /tmp/output/mc*.txz | sort | tail -n 1) \
    $(ls -1 /tmp/output/nano*.txz | sort | tail -n 1) \
    $(ls -1 /tmp/output/tmux*.txz | sort | tail -n 1) )
for elem in ${pkgs[@]}; do [[ -n $elem ]] && [ -f $elem ] && echo "==> Uncompress $elem" && tar -C /usr/local -xf $elem; done
for elem in $(ls -1 /usr/local/bin/install-*.sh); do bash $elem || true; done

