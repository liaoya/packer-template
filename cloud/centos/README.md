# CentOS Build

```shell
packer build -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/lab.json centos.json
packer build -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/lab.json centos-docker.json
packer build -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/lab.json centos-kvm.json
```
