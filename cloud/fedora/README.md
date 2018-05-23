# Fedora Build

```bash
yum install -y cloud-utils

bash ../seed/gen.sh
bash build/download.sh

packer build -var-file ../conf/fedora26.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var "disk_size=32768" -var-file ../conf/fedora26.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora-kubernetes.json

packer build -var-file ../conf/fedora27.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var "disk_size=32768" -var-file ../conf/fedora27.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora-kubernetes.json

packer build -var-file ../conf/fedora28.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var "disk_size=32768"  -var-file ../conf/fedora28.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora-kubernetes.json
```
