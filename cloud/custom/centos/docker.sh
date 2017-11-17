#!/bin/bash -eux

echo '==> Install docker-ce for centos'

sed -i "/net.ipv4.ip_forward/d" /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf

yum install -y -q openvswitch-ovn-docker
systemctl enable openvswitch
yum install -y -q yum-utils && yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo && yum install -y -q docker-ce || true
# yum install -y -q docker
systemctl enable docker
