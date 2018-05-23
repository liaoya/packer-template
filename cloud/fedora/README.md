# Fedora Build

```bash
bash ../seed/gen.sh
bash build/download.sh

packer build -var-file ../conf/fedora26.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var-file -var "disk_size=32768" ../conf/fedora26.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora-kubernetes.json

packer build -var-file ../conf/fedora27.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var-file -var "disk_size=32768" ../conf/fedora27.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora-kubernetes.json

packer build -var-file ../conf/fedora28.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var-file -var "disk_size=32768" ../conf/fedora27.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora-kubernetes.json
```
