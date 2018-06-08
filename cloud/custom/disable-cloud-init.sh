#!/bin/bash -eux

[[ $(command -v dnf) ]] && dnf remove -y -q cloud-init || true
[[ $(command -v yum) ]] && yum remove -y -q cloud-init || true
[[ $(command -v apt-get) ]] && apt-get remove -y -q cloud-init || true
