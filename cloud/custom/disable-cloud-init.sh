#!/bin/bash -eux

if [[ $(command -v dnf) ]]; then dnf remove -y -q cloud-init; fi
if [[ $(command -v yum) ]]; then yum remove -y -q cloud-init; fi
if [[ $(command -v apt-get) ]]; then apt-get remove -y -q cloud-init; fi
