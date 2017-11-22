# README

## Scripts

### 17.10

```shell
bash build/download.sh

packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/artful.json ubuntu.json
packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/artful.json ubuntu-docker.json
packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/artful.json ubuntu-kvm.json
```

### 16.04

```shell
bash build/download.sh

packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/xenial.json ubuntu.json
packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/xenial.json ubuntu-docker.json
packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/xenial.json ubuntu-kvm.json
```

Download the latest official **ubuntu/xenial64** vagrant box and export for packer virtualbox-ovf build.
The official ova image can not be used since it contain cloud-init service which will block the boot for ever and I have not way to hack it.

The main changes refer to `script.sh`

- Enable root ssh login and change its password to vagrant
- Change Ethernet interface naming rule (eth0 like)
- Disable `cloud-init`
- Add vagrant user

Run the command `bash gen-ova.sh` to generate ova file
