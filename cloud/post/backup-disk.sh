#!/bin/bash

# This script use change qcow2 to 0.10 format, run virt-sparsify to decrease disk size and compress image for backup

set -e -x

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
FILE_NAME=$(basename "${THIS_FILE}")

SPARSIFY=${SPARSIFY:-false}
VERSION=${VERSION:-""}
if [[ -n $VERSION ]]; then VERSION="-$VERSION"; fi

echo "${FILE_NAME} ${OUTPUT} ${IMAGENAME} ${DEST} ${SPARSIFY} ${VERSION}"
[[ -d ${DEST} ]] || mkdir -p "${DEST}"
export LIBGUESTFS_BACKEND=direct
if [[ $SPARSIFY =~ true || $SPARSIFY =~ 1 || $SPARSIFY =~ yes ]] && [[ $(command -v virt-sparsify) ]]; then
     [[ $EUID -eq 0 ]] && virt-sparsify "$OUTPUT/$IMAGENAME.qcow2" "$DEST/$IMAGENAME.qcow2"
     [[ $EUID -gt 0 ]] && sudo virt-sparsify "$OUTPUT/$IMAGENAME.qcow2" "$DEST/$IMAGENAME.qcow2" && sudo chown "$(id -un):$(id -gn)" "$DEST/$IMAGENAME.qcow2"
     [[ -f $DEST/$IMAGENAME.qcow2 ]] && mv -f "$DEST/$IMAGENAME.qcow2" "$OUTPUT/$IMAGENAME.qcow2"
fi
qemu-img convert -c -O qcow2 "$OUTPUT/$IMAGENAME.qcow2" "$DEST/$IMAGENAME$VERSION.qcow2c"
#qemu-img convert -c -O qcow2 -o compat=0.10 "$OUTPUT/$IMAGENAME.qcow2" "$DEST/$IMAGENAME$VERSION.qcow2c"
# [[ -f $OUTPUT/$IMAGENAME.qcow2 ]] && qemu-img amend -f qcow2 -o compat=0.10 $OUTPUT/$IMAGENAME.qcow2
# [[ $(command -v pxz) ]] && pxz -c $OUTPUT/$IMAGENAME.qcow2 > $DEST/$IMAGENAME$VERSION.qcow2.xz
# [[ -f $DEST/$IMAGENAME$VERSION.qcow2.xz ]] || xz -c $OUTPUT/$IMAGENAME.qcow2 > $DEST/$IMAGENAME$VERSION.qcow2.xz
