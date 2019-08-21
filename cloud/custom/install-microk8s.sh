#!/bin/bash

[[ -n ${CUSTOM_MICROK8S} && "${CUSTOM_MICROK8S^^}" == "TRUE" ]] || exit 0

if [[ $(command -v snap) ]]; then
    if [[ -n ${CUSTOM_MICROK8S_VERSION} ]]; then
        snap install --classic --channel="${CUSTOM_MICROK8S_VERSION}" microk8s 
    else
        snap install --classic microk8s 
    fi
fi
