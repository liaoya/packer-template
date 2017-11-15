#!/bin/bash

CACHE_SERVER="10.113.69.79"

scp -pqr root@$CACHE_SERVER:/var/www/html/saas/binary/rhel7/* $(dirname $(readlink -f $0))/output
#scp -pqr root@$CACHE_SERVER:/var/www/html/saas/ovs/centos7/2.8.1 $(dirname $(readlink -f $0))/output
