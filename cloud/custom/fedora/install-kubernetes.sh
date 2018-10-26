#!/bin/bash -eux

[[ -n ${CUSTOM_KUBENETES} && "${CUSTOM_KUBENETES}" == "true" ]] || exit 0
echo "==> Install Fedora Kubernetes packages"

dnf install -y -q kubernetes etcd
if [[ -n ${SSH_USERNAME} ]] && getent group docker; then usermod -aG docker "${SSH_USERNAME}"; fi
if [[ -n ${SSH_USERNAME} ]] && getent group dockerroot; then usermod -aG dockerroot "${SSH_USERNAME}"; fi
