# CentOS Build

```bash
yum install -y -q cloud-utils
bash ../seed/gen.sh

export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

packer build -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json centos.json

packer build -var "vm_name=develop" -var "custom_asdf=true" -var "custom_docker_ce=true" -var "custom_java=true" -var "custom_nvm=true" -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json centos.json

packer build -var "vm_name=kubernetes"  -var "custom_docker=true" -var "custom_kubernetes=true" -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json centos.json

packer build -var "vm_name=minikube" -var "custom_docker_ce=true" -var "custom_minikube=true" -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json centos.json

packer build -var "vm_name=libvirt" -var "custom_libvirt=true" -var-file ../conf/centos7.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json centos.json
```

The following command can help to setup a new virtual machine

```bash
base_image=$(find /var/lib/libvirt/images -iname 'centos7-develop-*.qcow2c' -printf "%T@ %p\n" | sort -r | head -1 | cut -d' ' -f2)

vm_name=c7-develop
virsh list --name | grep -s -q "${vm_name}" && virsh destroy "${vm_name}"
virsh list --inactive --name | grep "${vm_name}" && virsh undefine --remove-all-storage "${vm_name}"

qemu-img create -f qcow2 "/var/lib/libvirt/images/${vm_name}.qcow2" 64G
virt-resize --expand /dev/sda1 "${base_image}" "/var/lib/libvirt/images/${vm_name}.qcow2"

ROOT_DIR=$(mktemp -d)
mkdir -p "${ROOT_DIR}/etc/sysconfig/network-scripts"
cat <<EOF > "${ROOT_DIR}/etc/sysconfig/network-scripts/ifcfg-eth0"
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.113.20.28
PREFIX=22
GATEWAY=10.113.20.1
EOF
cp /etc/resolv.conf "${ROOT_DIR}/etc/"
echo "${vm_name}" > "${ROOT_DIR}/etc/hostname"
tar -cf "${vm_name}.tar" -C "${ROOT_DIR}/etc" .
virt-tar-in -a "/var/lib/libvirt/images/${vm_name}.qcow2" "${vm_name}.tar" /etc
rm -fr "${vm_name}.tar" "${ROOT_DIR}"

virt-install --name "${vm_name}" --memory=32768 --vcpus=8 --cpu host-passthrough --disk "/var/lib/libvirt/images/${vm_name}.qcow2" --os-variant centos7.0 --network bridge=ovsbr0-506,model=virtio,virtualport_type=openvswitch --noautoconsole --import
```

## Expand the xfs image

### Method 1

```bash
base_image=$(ls -1 /var/lib/libvirt/images/centos7-libvirt-* | tail -n 1)
vm_name=c7-ovs-testbed
virsh list --name | grep -s -q ${vm_name} && virsh destroy ${vm_name}
virsh list --inactive --name | grep ${vm_name} && virsh undefine --remove-all-storage ${vm_name}
qemu-img create -b $base_image -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 128G

ROOT_DIR=$(mktemp -d)
mkdir -p ${ROOT_DIR}/etc/sysconfig/network-scripts
cat <<EOF > ${ROOT_DIR}/etc/sysconfig/network-scripts/ifcfg-eth0
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.113.20.21
PREFIX=22
GATEWAY=10.113.20.1
EOF
cp /etc/resolv.conf ${ROOT_DIR}/etc/
echo "${vm_name}" > ${ROOT_DIR}/etc/hostname
tar -cf ${vm_name}.tar -C ${ROOT_DIR}/etc .
virt-tar-in -a /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_name}.tar /etc
rm -fr ${vm_name}.tar ${ROOT_DIR}

virt-install --name ${vm_name} --memory=65536 --vcpus=16 --cpu host-passthrough --disk /var/lib/libvirt/images/${vm_name}.qcow2 --os-variant centos7.0 --network bridge=ovsbr506,model=virtio,virtualport_type=openvswitch --network bridge=ovsbr0,model=virtio,virtualport_type=openvswitch --noautoconsole --import
```

Refer to <https://nerdbyday.com/resizing-an-ext4-partition-without-unmounting/> to extend xfs partition

### Method 2

```bash
base_image=$(ls -1 /var/lib/libvirt/images/centos7-libvirt-* | tail -n 1)
vm_name=c7-ovs-testbed
virsh list --name | grep -s -q ${vm_name} && virsh destroy ${vm_name}
virsh list --inactive --name | grep ${vm_name} && virsh undefine --remove-all-storage ${vm_name}
qemu-img create -b $base_image -f qcow2 /var/lib/libvirt/images/${vm_name}.qcow2 256G

ROOT_DIR=$(mktemp -d)
mkdir -p ${ROOT_DIR}/etc/sysconfig/network-scripts
cat <<EOF > ${ROOT_DIR}/etc/sysconfig/network-scripts/ifcfg-eth0
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.113.20.21
PREFIX=22
GATEWAY=10.113.20.1
EOF
cp /etc/resolv.conf ${ROOT_DIR}/etc/
echo "${vm_name}" > ${ROOT_DIR}/etc/hostname
tar -cf ${vm_name}.tar -C ${ROOT_DIR}/etc .
virt-tar-in -a /var/lib/libvirt/images/${vm_name}.qcow2 ${vm_name}.tar /etc
rm -fr ${vm_name}.tar ${ROOT_DIR}

virt-install --name ${vm_name} --memory=65536 --vcpus=16 --cpu host-passthrough --disk /var/lib/libvirt/images/${vm_name}.qcow2 --os-variant centos7.0 --network bridge=ovsbr506,model=virtio,virtualport_type=openvswitch --network bridge=ovsbr0,model=virtio,virtualport_type=openvswitch --noautoconsole --import
```

Run `sudo xfs_growfs /dev/vda1` after ssh login, this is the prefer
