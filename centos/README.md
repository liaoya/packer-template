# CentOS

```bash
packer build -only=qemu -var "headless=false" -var-file conf/centos-80.json centos8-qemu.json
```
