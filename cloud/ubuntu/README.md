# README

## Scripts

```bash
export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

bash ../seed/gen.sh
```

```bash
packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/proxy.json -var-file ../conf/ubuntu-1804.json ubuntu.json

packer build -only qemu -var "vm_name=minikube" -var "custom_docker=true" -var "custom_libvirt=true" -var-file ../conf/jaist.json -var-file ../conf/proxy.json -var-file ../conf/ubuntu-1804.json ubuntu.json

packer build -only qemu -var "vm_name=develop" -var "custom_docker=true" -var "custom_java=true" -var "custom_nvm=true" -var-file ../conf/jaist.json -var-file ../conf/proxy.json -var-file ../conf/ubuntu-1804.json ubuntu.json

packer build -only qemu -var-file ../conf/jaist.json -var-file ../conf/proxy.json -var-file ../conf/ubuntu-1804-i386.json ubuntu.json
```

Download the latest official **ubuntu/bionic64** vagrant box and export for packer virtualbox-ovf build.
The official ova image can not be used since it contain cloud-init service which will block the boot for ever and I have not way to hack it.

The main changes refer to `script.sh`

- Enable root ssh login and change its password to vagrant
- Change Ethernet interface naming rule (eth0 like)
- Disable `cloud-init`
- Add vagrant user

Run the command `bash gen-ova.sh` to generate ova file

The following command can help to setup a new virtual machine

```bash
base_image=$(find /var/lib/libvirt/images -iname 'bionic-develop-*.qcow2c' -printf "%T@ %p\n" | sort -r | head -1 | cut -d' ' -f2)
vm_name=bionic-develop
virsh list --name | grep -s -q "${vm_name}" && virsh destroy "${vm_name}"
virsh list --inactive --name | grep "${vm_name}" && virsh undefine --remove-all-storage "${vm_name}"
qemu-img convert -f qcow2 "${base_image}" "/var/lib/libvirt/images/${vm_name}.qcow2"
qemu-img resize "/var/lib/libvirt/images/${vm_name}.qcow2" 64G

# The following will not work if the host is RHEL 7.x family
#qemu-img create -f qcow2 "/var/lib/libvirt/images/${vm_name}.qcow2" 64G
#virt-resize --expand /dev/sda1 "${base_image}" "/var/lib/libvirt/images/${vm_name}.qcow2"

ROOT_DIR=$(mktemp -d)
mkdir -p ${ROOT_DIR}/etc/netplan/
cat <<EOF > ${ROOT_DIR}/etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      addresses: [10.113.20.21/22]
      gateway4: 10.113.20.1
      nameservers:
        addresses: [10.182.244.34]
        search: [cn.oracle.com,jp.oracle.com,us.oracle.com,oracle.com]
      dhcp6: no
EOF
echo ${vm_name} > ${ROOT_DIR}/etc/hostname
tar -cf ${vm_name}.tar -C ${ROOT_DIR}/etc .
virt-tar-in -a /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_name}.tar /etc
rm -fr ${vm_name}.tar ${ROOT_DIR}

virt-install --name ${vm_name} --memory=32768 --vcpus=8 --cpu host-passthrough --disk /var/lib/libvirt/images/${vm_name}.qcow2 --os-variant ubuntu18.04 --network bridge=ovsbr0-506,model=virtio,virtualport_type=openvswitch --noautoconsole --import
```

On CentOS, can't call virt-resize since its `e2fsck` is too old. Run `parted`, `cdisk` and `resize2fs` to use the whole disk.
