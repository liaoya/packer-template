# CentOS Build

```bash
yum install -y -q cloud-utils
bash ../seed/gen.sh

export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

packer build -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/lab.json centos.json
packer build -var "vm_name=minikube" -var "custom_libvirt=true" -var "custom_docker=true" -var "disk_size=65536" -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/lab.json centos.json
```
