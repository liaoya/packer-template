# README

Oracle does not provide qcow2 image for oracle linux after 7.4 for long time so that I want to build by myself.
I find <https://github.com/CentOS/sig-cloud-instance-build/blob/master/cloudimg/CentOS-7-x86_64-GenericCloud-201606-r1.ks> is a good reference.
My build will also use the new way Orace Linux manage its own repo <http://public-yum.oracle.com/getting-started.html>.
Now it has multi .repo files instead of big /etc/yum.repos.d/public-yum-ol7.repo.
Now there is some small issues

1. The user root can login without password on console
2. The openstack image does not finish

## Build

```bash
export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false
```

```bash
packer build -var "headless=false" -var-file conf/ol79.json ol7-qemu.json
```

```bash
packer build -only=qemu -var "headless=true" -var-file conf/ol83.json ol8-qemu.json
```

```bash
packer build -var "headless=false" -var "custom_group=nncentral" -var "custom_user=nncentral" -var "vm_name=nncentral" -var-file conf/ol76.json ol7-qemu.json
```

Change the following to use proxy

```text
repo --name=ol7_latest --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/latest/x86_64/ --cost=100 --proxy=http://10.113.69.101:5900
repo --name=ol7_optional_latest --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/optional/latest/x86_64/ --cost=100 --proxy=http://10.113.69.101:5900
repo --name=ol7_addons --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/addons/x86_64/ --cost=100 --proxy=http://10.113.69.101:5900
repo --name=ol7_UEKR5 --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/UEKR5/x86_64/ --cost=100 --proxy=http://10.113.69.101:5900
repo --name=ol7_developer_EPEL --baseurl=http://yum.oracle.com/repo/OracleLinux/OL7/developer_EPEL/x86_64/ --cost=100 --proxy=http://10.113.69.101:5900
```

## Explaination

- `create-user.sh` help to create a customized user, you choose `vagrant`

## Limitation

- Openstack image has not been verified
