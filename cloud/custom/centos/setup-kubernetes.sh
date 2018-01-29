#!/bin/bash -eux

echo "==> Install CentOS Kubernetes packages"

yum install -y -q kubernetes etcd
[[ -n $SSH_USERNAME ]] && getent group docker && usermod -aG docker $SSH_USERNAME || true
[[ -n $SSH_USERNAME ]] && getent group dockerroot && usermod -aG dockerroot $SSH_USERNAME || true
