#!/bin/sh

USAGE="Usage $(basename $(readlink -f $0)) -h[elp] -c[lean]"
CLEAN=0
while getopts "ch" o; do
    case "${o}" in
        c)
            CLEAN=1
            ;;
        h):
            echo $USAGE
            exit 0
            ;;
        *)
            echo $USAGE
            exit 1
            ;;
    esac
done

BASEDIR=$(dirname $(readlink -f $0))
[[ -f $BASEDIR/seed.iso && $CLEAN -gt 0 ]] && rm -f $BASEDIR/seed.iso
[[ -f $BASEDIR/seed.iso ]] || cloud-localds $BASEDIR/seed.iso $BASEDIR/user-data
