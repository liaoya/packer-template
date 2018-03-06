#!/bin/bash

set -x

BASEDIR=$(dirname $0)

rm -fr ${BASEDIR}/box/* ${BASEDIR}/image/* ${BASEDIR}/qemu/* ${BASEDIR}/virtualbox/*
