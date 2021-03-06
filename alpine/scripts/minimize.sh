#!/bin/sh
set -ux

# This script must be decorated with 'set -ux'

case "$PACKER_BUILDER_TYPE" in
  qemu) exit 0 ;;
esac

dd if=/dev/zero of=/EMPTY bs=1M
rm -f /EMPTY
# Block until the empty file has been removed, otherwise, Packer
# will try to kill the box while the disk is still full and that's bad
sync
sync
sync

exit 0
