# Oracle Build

```bash
bash ../seed/gen.sh

packer build -var-file ../conf/oraclelinux74.json -var-file ../conf/lab.json oraclelinux.json
```
