#!/bin/bash

[[ -n ${CUSTOM_MICROK8S} && "${CUSTOM_MICROK8S}" == "true" ]] || exit 0

if [[ $(command -v snap) ]]; then
    snap install microk8s --classic
fi
