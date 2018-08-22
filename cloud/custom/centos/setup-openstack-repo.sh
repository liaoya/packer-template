#!/bin/bash -eux

yum -y -q install centos-release-openstack-queens
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-OpenStack-queens.repo
