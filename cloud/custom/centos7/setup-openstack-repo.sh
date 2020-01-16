#!/bin/bash

yum -y -q install entos-release-openstack-stein
sed -i -e "s/enabled=1/enabled=0/g" /etc/yum.repos.d/CentOS-OpenStack-stein.repo 
