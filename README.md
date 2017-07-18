# packer-template

My own packer template repository

## Prepare

Set `PACKER_KEY_INTERVAL`=10ms to speed console input

Use packer to build TPD images. Please set `CURLOPT_SSL_VERIFYPEER` to false and the http server host ISO in no_proxy list

## How to build CentOS

I suggest use CentOS official vagrant box since they're always up-to-date

Use the following command to build CentOS 7.3.1611 for virtualbox-iso

    packer build -only virtualbox-iso -var-file conf/centos/c7-1611-minimal.json -var "iso_path=/home/tshen/Downloads" -var "kickstart=centos/c7-sata-ks.cfg" centos.json

Use the following command to build CentOS 7.3.1611 for qemu

    packer build -only qemu -var-file conf/centos/c7-1611-minimal.json -var "kickstart=centos/c7-kvm-ks.cfg" centos.json

## Build alpine

More boot time is required for virtualbox-iso.

The following information is required for build

* DNS nameserver
* Proxy for apk

### Build qcow2 file and its corresponding vagrant box

Use the following command to build, you will find qcow2 file under images/qemu and ova file under box/

    export http_proxy=http://10.113.69.79:3128
    packer build -only qemu -var-file conf/alpine/3.6.2.json -var-file "nameserver=10.182.244.34" alpine.json

### Build virtualbox ova and its corresponding vagrant box

Use the following command to build

    export http_proxy=http://10.182.172.49:3128
    packer build -only virtualbox-iso -var-file conf/alpine/3.6.2.json -var "nameserver=10.182.244.34" -var "iso_path=/home/tshen/Downloads" alpine-vagrant.json

## Build CentOS

The following command is used for

## Build Fedora

The following command is used for
