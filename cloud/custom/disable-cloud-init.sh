#!/bin/bash -eux

[[ -n ${DISABLE_CLOUD_INIT} && "${DISABLE_CLOUD_INIT}" == "true" ]] || exit 0

if [[ $(command -v dnf) ]]; then dnf remove -y -q cloud-init || true; fi
if [[ $(command -v yum) ]]; then yum remove -y -q cloud-init || true; fi
if [[ $(command -v apt-get) ]]; then apt-get remove -y -q cloud-init || true; fi
