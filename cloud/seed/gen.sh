#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")
USAGE=$(basename "${THIS_FILE}")
printf -v USAGE "Usage: %s -h[elp] -c[lean]" "${USAGE}"

CLEAN=0
while getopts "ch" o; do
    case "${o}" in
        c)
            CLEAN=1
            ;;
        h):
            echo "${USAGE}"
            exit 0
            ;;
        *)
            echo "${USAGE}"
            exit 1
            ;;
    esac
done

[[ -f $THIS_DIR/seed.iso && $CLEAN -gt 0 ]] && rm -f "$THIS_DIR/seed.iso"
[[ -f $THIS_DIR/seed.iso ]] || cloud-localds "$THIS_DIR/seed.iso" "$THIS_DIR/user-data"
