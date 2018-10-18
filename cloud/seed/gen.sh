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

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")
[[ -f $THIS_DIR/seed.iso && $CLEAN -gt 0 ]] && rm -f "$THIS_DIR/seed.iso"
[[ -f $THIS_DIR/seed.iso ]] || cloud-localds "$THIS_DIR/seed.iso" "$THIS_DIR/user-data"
