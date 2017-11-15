#!/bin/bash

USAGE="Usage $(basename $(readlink -f $0)) -h[elp] -c[lean]"
CLEAN=0
while getopts "ch" o; do
    case "${o}" in
        c)
            CLEAN=1
            ;;
        h):
            echo $USAGE
            ;;
        *)
            echo $USAGE
            ;;
    esac
done

[[ $CLEAN -gt 0 ]] && rm -fr $(dirname $(readlink -f $0))/output/*

CACHE_SERVER="10.113.69.79"

declare -a pkgs=(fish mc nano tmux)
for elem in ${pkgs[@]}; do scp -pqr root@$CACHE_SERVER:/var/www/html/saas/binary/rhel7/${elem}* $(dirname $(readlink -f $0))/output; done
#scp -pqr root@$CACHE_SERVER:/var/www/html/saas/ovs/centos7/2.8.1/* $(dirname $(readlink -f $0))/output
