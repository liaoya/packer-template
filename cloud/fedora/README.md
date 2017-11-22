# Fedora Build

```shell
bash build/download.sh

packer build -var-file ../conf/fedora26.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
packer build -var-file ../conf/fedora27.json -var-file ../conf/jaist.json -var-file ../conf/lab.json fedora.json
```
