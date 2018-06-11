#!/bin/bash -eux

[[ -n ${CUSTOM_KUBENETES} && "${CUSTOM_KUBENETES}" == "true" ]] || exit 0
echo "==> Install Fedora Kubernetes packages"

dnf install -y -q kubernetes etcd
[[ -n ${SSH_USERNAME} ]] && getent group docker && usermod -aG docker ${SSH_USERNAME} || true
[[ -n ${SSH_USERNAME} ]] && getent group dockerroot && usermod -aG dockerroot ${SSH_USERNAME} || true
