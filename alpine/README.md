# Build Alpine Images with Packer

## What's Packer

## How wo build

### Prepare

Packer 1.1.3 is required.

```bash
version=1.1.3
curl -s -L -O "https://releases.hashicorp.com/packer/${version}/packer_${version}_linux_amd64.zip"
unzip "packer_${version}_linux_amd64.zip"
strip packer
mv -f packer /usr/local/bin
```

Put the following in `~/.bash_profile` or in command line.
If iso file hosts in intranet server, please add that server in no_proxy list.

```bash
export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false
```

More boot time is required for virtualbox-iso. Setup proper `http_proxy` if behind a firewall.

if build at home, use `-var "iso_url=http://mirrors.ustc.edu.cn/alpine/v3.7.0/releases/x86_64/alpine-virt-3.7.0.0-x86_64.iso"`

### Build qcow2 file and its corresponding vagrant box

Use the following command to build at Nanjing site, qcow2 file is under image/ and vagrant box is under box/

```bash
export http_proxy=
rm -fr qemu/* image/* box/*
packer build -only qemu -var-file conf/3.7.0.json alpine.json
```

### Build virtualbox ova and its corresponding vagrant box

Use the following command to build at Nanjing site, ova file is under image/ and vagrant box is under box/

```bash
export http_proxy=
rm -fr virtualbox/* image/* box/*
packer build -only virtualbox-iso -var-file conf/3.7.0.json alpine.json
```

The root is disabled via ssh from remote. Please use vagrant/vagrant for login.

### Generate json file for `vagrant box add`

```bash
rm -f vagrant-box-def.json
python ../gen-vagrant-def.py -n "alpine/3.7.0" -v "20171016" -p "virtualbox" -u "box/alpine-3.7.0/alpine-3.7.0-virtualbox-20171016.box"
python ../gen-vagrant-def.py -n "alpine/3.7.0" -v "20171016" -p "libvirt" -u "box/alpine-3.7.0/alpine-3.7.0-libvirt-20171016.box"
```

### Import

#### Import OVA

You can use GUI to import ova file from Menu **File** -> **Import Applicance** or by the command `vboxmanage import alpine-3.7.0-virtualbox.ova`

If you want to give another name, e.g. alpine instead of alpine-3.7.0, use the following command, the demo is on Linux

```bash
mkdir -p "/home/tshen/VirtualBox VMs/alpine"
vboxmanage import alpine-3.7.0-virtualbox.ova --vsys 0 --vmname alpine --unit 9 --disk "/home/tshen/VirtualBox VMs/alpine/alpine.vmdk"
```

#### Import qcow2

Use `virtual-install` or **Virtual Manager**

#### Import to Vagrant

**vagrant-alpine** and **vagrant-libvirt**(only for libvirt) are required. Run the following commands on RHEL like OS

```bash
yum install -y libvirt-devel
vagrant plugin install vagrant-libvirt vagrant-alpine
```

Modify `vagrant.json` change the following

- **name** of **providers**, `virtualbox` or `libvirt`
- **url** of **providers**, use correct the relative path

Then run `vagrant box add --insecure vagrant.json`
