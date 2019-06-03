#!/bin/bash

[[ -n ${CUSTOM_MICRO8S} && "${CUSTOM_MICRO8S}" == "true" ]] || exit 0

if [[ ! $(command -v snap) ]]; then
    snap install microk8s --classic
fi
