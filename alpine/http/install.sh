#!/bin/sh
#shellcheck disable=SC1091,SC2039
# http://www.tutorialspoint.com/unix_commands/getopt.htm

# read the options
TEMP=$(getopt -o d:n:p:P:r:z: --long domain:,nameserver:,passwrod:,proxy:,repository:,timezone: -- "$@")
eval set -- "$TEMP"

# extract options and their arguments into variables.
DOMAIN="" NAMESERVER="" PASSWORD="alpine" PROXY="" REPOSITORY="-1" TIMEZONE=""
while true ; do
    case "$1" in
        -d|--domain)
            DOMAIN=$2 ; shift 2 ;;
        -n|--nameserver)
            NAMESERVER=$2 ; shift 2 ;;
        -p|--password)
            PASSWORD=$2 ; shift 2 ;;
        -P|--proxy)
            PROXY=$2 ; shift 2 ;;
        -r|--repository)
            REPOSITORY=$2 ; shift 2 ;;
        -z|--timezone)
            TIMEZONE=$2 ; shift 2 ;;
        --) shift ; break ;;
        *) echo "Internal error!" ; exit 1 ;;
    esac
done

echo DOMAIN is \""$DOMAIN"\" NAMESERVER is \""$NAMESERVER"\" PASSWORD is \""$PASSWORD"\" PROXY is \""$PROXY"\" REPOSITORY is \""$REPOSITORY"\" TIMEZONE is \""$TIMEZONE"\"

set -e -x

setup-keymap us us
setup-hostname -n alpine
echo -e "eth0\\ndhcp\\nno\\n" | setup-interfaces
/etc/init.d/networking --quiet start &
sleep 10s
echo -e "$PASSWORD\\n$PASSWORD\\n" | passwd
[ ! -z "$NAMESERVER" ] && setup-dns -d "$DOMAIN" "$NAMESERVER"
[ ! -z "$TIMEZONE" ] && setup-timezone -z "$TIMEZONE"
setup-sshd -c openssh
/etc/init.d/hostname --quiet restart
if [ -n "$PROXY" ]; then
    setup-proxy -q "$PROXY"
    [ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh
fi
#shellcheck disable=2086
setup-apkrepos "$REPOSITORY" "$(dirname $REPOSITORY)/community"
setup-ntp -c chrony
# For virtualbox
[ -b /dev/vda ] && echo -e "y\\n" | setup-disk -m sys -s 0 -L /dev/vda
# For qemu
[ -b /dev/sda ] && echo -e "y\\n" | setup-disk -m sys -s 0 -L /dev/sda

# Post Installation
rc-service sshd stop
mount /dev/vg0/lv_root /mnt

# Enable serial console
sed -i 's/^default_kernel_opts=\"quiet/& console=ttyS0,115200 console=tty0 ignore_loglevel/' /mnt/etc/update-extlinux.conf
sed -i 's/^serial_port=.*/serial_port=0/' /mnt/etc/update-extlinux.conf

# Enable all stable repository
sed -i '/^#http.*edge.*/! s/#//g' /mnt/etc/apk/repositories
sed -i '/\/media/ s//#\/media/g' /mnt/etc/apk/repositories

SSHD_CONFIG=/mnt/etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' "$SSHD_CONFIG"
grep -s -q -w "^UseDNS yes" "$SSHD_CONFIG" && sed -i "/UseDNS/d" "$SSHD_CONFIG" && sed -i "/^# no default banner path/i UseDNS no" "$SSHD_CONFIG"
grep -s -q -w "^GSSAPIAuthentication yes" "$SSHD_CONFIG" && sed -i "/GSSAPIAuthentication/d" "$SSHD_CONFIG" && sed -i "/^# no default banner path/i GSSAPIAuthentication no" "$SSHD_CONFIG"
grep -s -q -w "^GSSAPICleanupCredentials yes" "$SSHD_CONFIG" && sed -i "/GSSAPICleanupCredentials/d" "$SSHD_CONFIG" && sed -i "/^# no default banner path/i GSSAPICleanupCredentials no" "$SSHD_CONFIG"

umount /mnt

reboot
