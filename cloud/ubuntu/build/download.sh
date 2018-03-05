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

[[ $CLEAN -gt 0 ]] && for folder in $(ls -1d $(dirname $(readlink -f $0))/*/); do [ -d $folder/output ] && rm -fr $folder/output/* || true; done

CACHE_SERVER="10.113.69.79"

declare -a pkgs=(fish mc nano sshpass tmux)
for folder in $(ls -1d $(dirname $(readlink -f $0))/*/); do
    for elem in ${pkgs[@]}; do 
        [ -d $folder/output ] && scp -pqr root@$CACHE_SERVER:/var/www/html/saas/binary/$(basename $folder)/${elem}* $(dirname $(readlink -f $0))/$(basename $folder)/output
    done
    [ -d $folder/output ] && scp -pqr root@$CACHE_SERVER:/var/www/html/saas/ovs/$(basename $folder)/latest/* $(dirname $(readlink -f $0))/$(basename $folder)/output
done

