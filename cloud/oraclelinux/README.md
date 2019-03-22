# Oracle Build

```bash
yum install -y -q cloud-utils
bash ../seed/gen.sh

export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

packer build -var-file ../conf/oraclelinux76.json -var-file ../conf/proxy.json oraclelinux.json

packer build -var "vm_name=minikube" -var "custom_docker=true" -var "custom_libvirt=true" -var-file ../conf/oraclelinux76.json -var-file ../conf/proxy.json oraclelinux.json

packer build -var "vm_name=develop" -var "custom_docker=true" -var "custom_java=true" -var "custom_nvm=true" -var-file ../conf/oraclelinux76.json -var-file ../conf/proxy.json oraclelinux.json
```

## Use our own image

Oracle has not provide openstack image after oracle linux 7.4 for long time (Now 7.5 and 7.6 image come out).
I have to build by myself.

```bash
image_name=ol76-kvm-minimal-20190314.qcow2c
image_checksum=$(sha256sum ~/.cache/packer/${image_name} | cut -d' ' -f 1)
packer build -var "vm_name=develop" -var "custom_docker=true" -var "custom_java=true" -var "custom_nvm=true" -var "iso_name=${image_name}" -var "iso_checksum=${image_checksum}" -var "oracle_name=ol76" -var "ssh_password=vagrant" -var "ssh_username=vagrant" -var-file ../conf/proxy.json oraclelinux.json
```

The following command can help to setup a new virtual machine

```bash
base_image=$(ls -1 /var/lib/libvirt/images/ol74-minikube-*)
vm_name=oraclelinux76
virsh list --name | grep -s -q "${vm_name}" && virsh destroy "${vm_name}"
virsh list --inactive --name | grep "${vm_name}" && virsh undefine --remove-all-storage "${vm_name}"
qemu-img create -f qcow2 "/var/lib/libvirt/images/${vm_name}.qcow2" 64G
virt-resize --expand /dev/sda1 "${base_image}" "/var/lib/libvirt/images/${vm_name}.qcow2"


ROOT_DIR=$(mktemp -d)
mkdir -p "${ROOT_DIR}/etc/sysconfig/network-scripts"
cat <<EOF > ${ROOT_DIR}/etc/sysconfig/network-scripts/ifcfg-eth0
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.113.20.29
PREFIX=22
GATEWAY=10.113.20.1
EOF
cp /etc/resolv.conf "${ROOT_DIR}/etc/"
echo "${vm_name}" > "${ROOT_DIR}/etc/hostname"
tar -cf "${vm_name}.tar" -C "${ROOT_DIR}/etc" .
virt-tar-in -a "/var/lib/libvirt/images/${vm_name}.qcow2" "${vm_name}.tar" /etc
rm -fr "${vm_name}.tar" "${ROOT_DIR}"

virt-install --name ${vm_name} --memory=32768 --vcpus=8 --cpu host --disk "/var/lib/libvirt/images/${vm_name}.qcow2" --os-variant ol7.6 --network bridge=ovsbr506,model=virtio,virtualport_type=openvswitch --noautoconsole --import
```
