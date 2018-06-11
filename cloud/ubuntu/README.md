# README

## Scripts

```bash
export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

bash ../seed/gen.sh
```

```bash
packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/ubuntu-1804.json ubuntu.json
packer build -only qemu -var "vm_name=minikube" -var "custom_libvirt=true" -var "custom_docker=true" -var "disk_size=65536"  -var-file ../conf/jaist.json -var-file ../conf/lab.json -var-file ../conf/ubuntu-1804.json ubuntu.json
```

Download the latest official **ubuntu/xenial64** vagrant box and export for packer virtualbox-ovf build.
The official ova image can not be used since it contain cloud-init service which will block the boot for ever and I have not way to hack it.

The main changes refer to `script.sh`

- Enable root ssh login and change its password to vagrant
- Change Ethernet interface naming rule (eth0 like)
- Disable `cloud-init`
- Add vagrant user

Run the command `bash gen-ova.sh` to generate ova file
