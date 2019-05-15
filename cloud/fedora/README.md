# Fedora Build

```bash
dnf install -y -q cloud-utils
bash ../seed/gen.sh

export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

packer build -var-file ../conf/fedora30.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json fedora.json

packer build -var "vm_name=minikube" -var "custom_docker_ce=true" -var "custom_libvirt=true" -var "custom_python_virtualenv=true" -var-file ../conf/fedora30.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json fedora.json

packer build -var "vm_name=develop" -var "custom_docker_ce=true" -var "custom_java=true" -var "custom_nvm=true" -var-file ../conf/fedora30.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json fedora.json

packer build -var "vm_name=libvirt" -var "custom_libvirt=true" -var-file ../conf/fedora30.json -var-file ../conf/jaist.json -var-file ../conf/proxy.json fedora.json
```

The following command can help to setup a new virtual machine

```bash
base_image=$(find /var/lib/libvirt/images -iname 'fedora30-base-*.qcow2c' -printf "%T@ %p\n" | sort -r | head -1 | cut -d' ' -f2)
vm_name=fedora30-base
virsh list --name | grep -s -q ${vm_name} && virsh destroy ${vm_name}
virsh list --inactive --name | grep ${vm_name} && virsh undefine --remove-all-storage "${vm_name}"
qemu-img convert -f qcow2 "${base_image}" "/var/lib/libvirt/images/${vm_name}.qcow2"
qemu-img resize "/var/lib/libvirt/images/${vm_name}.qcow2" 64G

ROOT_DIR=$(mktemp -d)
mkdir -p "${ROOT_DIR}/etc/sysconfig/network-scripts"
cat <<EOF > "${ROOT_DIR}/etc/sysconfig/network-scripts/ifcfg-eth0"
BOOTPROTO=none
DEVICE=eth0
ONBOOT=yes
TYPE=Ethernet
IPADDR=10.113.20.31
PREFIX=22
GATEWAY=10.113.20.1
EOF
cp /etc/resolv.conf "${ROOT_DIR}/etc"
echo "${vm_name}" > "${ROOT_DIR}/etc/hostname"
tar -cf "${vm_name}.tar" -C "${ROOT_DIR}/etc" .
virt-tar-in -a "/var/lib/libvirt/images/${vm_name}.qcow2" "${vm_name}.tar" /etc
rm -fr "${vm_name}.tar" "${ROOT_DIR}"

virt-install --name "${vm_name}" --memory=16384 --vcpus=4 --cpu host --disk "/var/lib/libvirt/images/${vm_name}.qcow2" --os-variant fedora30 --network bridge=ovsbr0-506,model=virtio,virtualport_type=openvswitch --noautoconsole --import
```

On CentOS, can't call virt-resize since its `e2fsck` is too old. Run `parted`, `cdisk` and `resize2fs` to use the whole disk.
Refer to <https://techtitbits.com/2018/12/using-parteds-resizepart-non-interactively-on-a-busy-partition/>

```bash
size=$(sudo parted /dev/vda -m print | head -n 2 | tail -n 1 | cut -d ':' -f 2)
echo -e "Yes\n$size\n" | sudo parted ---pretend-input-tty /dev/vda resizepart 1
sudo resize2fs /dev/vda1
```
