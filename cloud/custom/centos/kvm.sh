#!/bin/bash -eux

echo '==> Install libvirt and openvswitch for centos'

yum install -y -q libvirt qemu-kvm-ev virt-install virt-top libvirt-python openvswitch
systemctl enable openvswitch

echo "net.ipv4.ip_forward = 1" >> /etc/sysctl.conf
