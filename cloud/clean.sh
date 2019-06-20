#!/bin/bash

set -e -x

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

rm -fr "${THIS_DIR}"/box/* "${THIS_DIR}"/image/* "${THIS_DIR}"/qemu/* "${THIS_DIR}"/virtualbox/*
