# packer-template

My own packer template repository

## How to build CentOS

I suggest use CentOS official vagrant box since they're always up-to-date

Use the following command to build CentOS 7.3.1611 for virtualbox-iso

    packer build -only virtualbox-iso -var-file conf/centos/c7-1611-minimal.json -var "iso_path=/home/tshen/Downloads" -var "kickstart=centos/c7-sata-ks.cfg" centos.json

Use the following command to build CentOS 7.3.1611 for qemu

    packer build -only virtualbox-iso -var-file conf/centos/c7-1611-minimal.json -var "kickstart=centos/c7-kvm-ks.cfg" centos.json

## Build alpine

More boot time is required for virtualbox-iso.

The following information is required for build

* DNS nameserver
* Proxy for apk

### Build ova or qcow2 file

The following command for build virtualbox-iso, iso_path is provide at last so that is will overwrite that in conf/alpine/3.6.2.json

    export http_proxy=http://10.182.172.49:3128
    packer build -only virtualbox-iso -var-file conf/alpine/3.6.2.json -var "nameserver=10.182.244.34" -var "iso_path=/home/tshen/Downloads" alpine.json

The following command for build qemu

    export http_proxy=http://10.113.69.79:3128
    packer build -only qemu -var-file conf/alpine/3.6.2.json -var-file "nameserver=10.182.244.34" alpine.json

### Build vagrant box

The following command for build virtualbox-iso, iso_path is provide at last so that is will overwrite that in conf/3.6.2.json

    export http_proxy=http://10.182.172.49:3128
    packer build -only virtualbox-iso -var-file conf/alpine/3.6.2.json -var "nameserver=10.182.244.34" -var "iso_path=/home/tshen/Downloads" alpine-vagrant.json

The following command for build qemu

    export http_proxy=http://10.113.69.79:3128
    packer build -only qemu -var-file conf/alpine/3.6.2.json -var-file "nameserver=10.182.244.34" alpine-vagrant.json

## Build CentOS

The following command is used for

## Build Fedora


The following command is used for
