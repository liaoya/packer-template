#!/bin/bash

[ -f ubuntu64.ova ] && rm -f ubuntu64.ova
vboxmanage list vms | grep -s -q "ubuntu-export" && vagrant destroy -f
vagrant up && vagrant halt && vboxmanage export ubuntu-export --output ubuntu64.ova && vagrant destroy -f

