# README

Oracle does not provide qcow2 image for oracle linux after 7.4 any more.
Refer <https://github.com/CentOS/sig-cloud-instance-build/blob/master/cloudimg/CentOS-7-x86_64-GenericCloud-201606-r1.ks>

## Build

We need packer 1.3.0 and CentOS 7.5 build these images. packer 1.3.2 will not work.

```bash
export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false
```

```bash
packer build -var "headless=false" -var "os_dist=ol76" -var-file conf/ol76.json ol7-kvm-minimal.json
```

```bash
packer build -var "headless=false" -var "custom_group=nncentral" -var "custom_user=nncentral" -var "os_dist=ol76" -var "vm_name=nncentral" -var-file conf/ol76.json ol7-kvm-minimal.json
```

Change the following

```text
repo --name=ol7_latest --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/ --proxy=http://10.113.69.101:5900
repo --name=ol7_optional_latest --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/optional/latest/x86_64 --proxy=http://10.113.69.101:5900
repo --name=ol7_addons --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/ --proxy=http://10.113.69.101:5900
repo --name=ol7_UEKR5 --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/UEKR5/x86_64/ --proxy=http://10.113.69.101:5900
```

## Explaination

- `create-user.sh` help to create a customized user, you choose `vagrant`

## Limitation

- Openstack image has not been verified
