# README

Oracle does not provide qcow2 image for oracle linux after 7.4 any more.

##

```bash
export PACKER_KEY_INTERVAL=10ms
packer build -var "headless=false" -var "os_dist=ol76" -var-file conf/ol76.json -var "iso_path=/root/.cache/packer" ol7-kvm-minimal.json
```

```bash
packer build -var "headless=false" -var "custom_group=nncentral" -var "custom_user=nncentral" -var "os_dist=ol76" -var "vm_name=nncentral" -var-file conf/ol76.json -var "iso_path=/root/.cache/packer" ol7-kvm-minimal.json
```
