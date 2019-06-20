#!/bin/bash

set -e

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

rm -fr "${THIS_DIR}"/image/* "${THIS_DIR}"qemu/*
