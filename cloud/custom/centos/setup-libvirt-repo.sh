#!/bin/bash -eux

cat <<'EOF' >/etc/yum.repos.d/CentOS-libvirt-latest.repo
[libvirt-latest]
name=CentOS-$releasever - libvirt-latest
baseurl=http://mirror.centos.org/centos/\$releasever/virt/$basearch/libvirt-latest/
enabled=1
gpgcheck=0
EOF
