# packer-template

My own packer template repository. I prefer to build a customized image based on official CentOS or Fedora vagrant box, extract qcow2 files.

The only reason I want to build fedora is the official build use plain disk layout

## Prepare

### On Linux

Put the following in `~/.bash_profile` or in command line. 
If iso file hosts in intranet server, please add that server in no_proxy list.

```bash
export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false
```

### On Windows

```dos
set PACKER_KEY_INTERVAL=10ms
set PACKER_CACHE_DIR=%APPDATA%\.packer_cache
mkdir %PACKER_CACHE_DIR%
set CURLOPT_SSL_VERIFYPEER=false
```

## How to build CentOS

I suggest use CentOS official vagrant box since they're always up-to-date

Use the following command to build CentOS 7.3.1611 for virtualbox-iso

```bash
packer build -only virtualbox-iso -var-file conf/centos/c7-1611-minimal.json -var "iso_path=/home/tshen/Downloads" -var "kickstart=centos/c7-sata-ks.cfg" centos.json
```

Use the following command to build CentOS 7.3.1611 for qemu

```bash
packer build -only qemu -var-file conf/centos/c7-1611-minimal.json -var "kickstart=centos/c7-kvm-ks.cfg" centos.json
```

## Build alpine

More boot time is required for virtualbox-iso.

The following information is required for build

* DNS nameserver
* Proxy for apk

### Build qcow2 file and its corresponding vagrant box

Use the following command to build  at Nanjing site, qcow2 file is under images/qemu and vagrant box is under box/

```bash
mkdir -p qemu
rm -fr images/alpine* box/alpine*
packer build -only qemu -var-file conf/alpine/3.6.2.json -var "nameserver=10.182.244.34" alpine.json
```

### Build virtualbox ova and its corresponding vagrant box

Use the following command to build at Nanjing site, ova file is under virtualbox and vagrant box is under box/

```bash
export http_proxy=http://10.182.172.49:3128
mkdir -p virtualbox
rm -fr images/alpine* box/alpine* virtualbox/alpine*
packer build -only virtualbox-iso -var-file conf/alpine/3.6.2.json -var "nameserver=10.182.244.34" alpine.json
```

## Build CentOS

The following command is used for

## Build Fedora

The following command is used for
