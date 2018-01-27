#!/bin/bash -eux

[[ $(command -v dnf) ]] && dnf remove -y cloud-init || true
[[ $(command -v yum) ]] && yum remove -y cloud-init || true
[[ $(command -v apt-get) ]] && apt-get remove -y cloud-init || true
