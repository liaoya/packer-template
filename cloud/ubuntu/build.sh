#!/bin/bash

usage="Usage: -h(help) -c[lean] -f[orce] -n [name] -s[unsparsify] -t [qemu|virtualbox] -u [ubuntu code name] -v [version]"

clean=0
force=0
name=""
sparsify=1
type=""
ubuntu="xenial64"
version=""

PACKERARGS=""
CACHE_SERVER="10.113.69.79"
# https://stackoverflow.com/questions/13322485/how-to-get-the-primary-ip-address-of-the-local-machine-on-linux-and-os-x
IPADDR=$(hostname -I | cut -d' ' -f1)
LOCATION=""
if [[ $IPADDR =~ '10.113' ]]; then LOCATION="lab"; fi
if [[ $IPADDR =~ '10.182.17' ]]; then LOCATION="office"; fi

while getopts "cfsn:t:u:v:h" arg
do
    case $arg in
        c):
            clean=1
            ;;
        f):
            force=1
            ;;
        n):
            name=$OPTARG
            ;;
        s):
            sparsify=0
            ;;
        t):
            type=$OPTARG
            ;;
        u):
            ubuntu=$OPTARG
            ;;
        v):
            version=$OPTARG
            ;;
        h):
            echo $usage
            exit 0
            ;;
        ?):
            echo $usage
            exit 1
            ;;
    esac
done

[[ -z $name || ! -f ${name}.json ]] && { echo "There is no json file \"${name}.json\""; exit 1; }
if [[ -f ../conf/${ubuntu}.json ]]; then
    PACKERARGS="$PACKERARGS -var-file ../conf/${ubuntu}.json -var \"ubuntu_name=$ubuntu\""
else
    echo "There is no ../conf/${ubuntu}.json" && exit 1
fi

if [ $clean -gt 0 ]; then
    echo "==> Clean all the cache and build artifacts"
    rm -fr build/output/* download/*.deb 
    [ -f ../seed/seed.iso ] && rm -f ../seed/seed.iso
    [ -f ova/ubuntu64.ova ] && rm -f ova/ubuntu64.ova
    if [[ -z $type ]] || [[ $type == "qemu" ]]; then
        rm -fr ../qemu/* ../box/* ../image/*
    fi
    if [[ -z $type ]] || [[ $type == "virtualbox" ]]; then
        rm -fr ../virtualbox/* ../box/* ../image/*
    fi
fi

if [[ -n $LOCATION ]]; then
    echo "==> Download Build artifacts"
    scp -pqr root@$CACHE_SERVER:/var/www/html/saas/ovs/16.04-xenial/2.8.1/*.deb build/output/
    scp -pqr root@$CACHE_SERVER:/var/www/html/saas/binary/ubuntu-16.04/*.txz build/output/
    scp -pqr root@$CACHE_SERVER:/var/www/html/saas/binary/docker/xenial/* download/
    [[ $LOCATION == "office" ]] && PACKERARGS="$PACKERARGS -var-file ../conf/office.json -var-file ../conf/jaist.json"
    [[ $LOCATION == "lab" ]] && PACKERARGS="$PACKERARGS -var-file ../conf/lab.json -var-file ../conf/jaist.json"
else
    (cd build; vagrant up && vagrant destory)
    (cd download; bash download.sh)
fi

if [[ -n $version ]]; then PACKERARGS="$PACKERARGS -var version=$version"; fi
if [ $sparsify -eq 0 ]; then PACKERARGS="$PACKERARGS -var sparsify=false"; fi

export PACKER_KEY_INTERVAL=10ms
export PACKER_CACHE_DIR=~/.cache/packer
[ -d $PACKER_CACHE_DIR ] || mkdir -p $PACKER_CACHE_DIR
export CURLOPT_SSL_VERIFYPEER=false

if [[ -z $type ]] || [[ $type == "qemu" ]]; then
    (cd ../seed; [ -f seed.iso ] || sh ./gen.sh)
fi

if [[ -z $type ]] || [[ $type == "virtualbox" ]]; then
    (cd ova; [ -f ubuntu64.ova ] || bash gen-ova.sh)
    export OVA_FILE=$(readlink -f ova/ubuntu64.ova)
fi

if [[ -z $type ]] || [[ $type == "qemu" ]]; then 
    if [[ -d ../qemu/$name ]]; then
        if [[ $force -eq 0 ]]; then echo "../qemu/$name exist"; else rm -fr ../qemu/$name; fi
    fi
    echo packer build -on-error=ask -only qemu $PACKERARGS $name.json
    packer build -on-error=ask -only qemu $PACKERARGS $name.json
fi
if [[ -z $type ]] || [[ $type == "virtualbox" ]]; then
    if [[ -d ../virtualbox/$name ]]; then
        if [[ $force -eq 0 ]]; then echo "../virtualbox/$name exist"; else rm -fr ../virtualbox/$name; fi
    fi
    echo packer build -on-error=ask -only virtualbox-ovf $PACKERARGS -var source_path=$OVA_FILE -var checksum=$(sha256sum $OVA_FILE | cut -d ' ' -f 1) $name.json
    packer build -on-error= -only virtualbox-ovf $PACKERARGS -var source_path=$OVA_FILE -var checksum=$(sha256sum $OVA_FILE | cut -d ' ' -f 1) $name.json
fi
