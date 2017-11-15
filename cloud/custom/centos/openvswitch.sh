#!/bin/bash -eux

yum install -y -q $(ls -1 tmp/output/*openvswitch*.rpm | grep -v -E "debuginfo|test")

sed -i "/net.ipv4.ip_forward/d" /etc/sysctl.conf
echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
