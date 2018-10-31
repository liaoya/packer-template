#!/bin/bash -eux

[[ -n ${CUSTOM_KUBENETES} && "${CUSTOM_KUBENETES}" == "true" ]] || exit 0
echo "==> Install Fedora Kubernetes packages"

dnf install -y -q kubernetes etcd
if [[ -n ${SUDO_USER} ]] && getent group docker; then usermod -aG docker "${SUDO_USER}"; fi
if [[ -n ${SUDO_USER} ]] && getent group dockerroot; then usermod -aG dockerroot "${SUDO_USER}"; fi
