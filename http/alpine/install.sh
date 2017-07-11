#!/bom/sh

# http://www.tutorialspoint.com/unix_commands/getopt.htm

# read the options
TEMP=`getopt -o d:n:p:P:r:z: --long domain:,nameserver:,passwrod:,proxy:,repository:,timezone: -- "$@"`
eval set -- "$TEMP"

# extract options and their arguments into variables.
DOMAIN="local" NAMESERVER="10.182.244.34" PASSWORD="NextGen" PROXY="http://10.113.69.79:3128" REPOSITORY="-1" TIMEZONE="Asia/Shanghai"
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

setup-keymap us us
setup-hostname -n alpine
echo -e "eth0\ndhcp\nno\n" | setup-interfaces
/etc/init.d/networking --quiet start &
sleep 10s
echo -e "$PASSWORD\n$PASSWORD\n" | passwd
setup-dns -d $DOMAIN $NAMESERVER
setup-timezone -z $TIMEZONE
setup-sshd -c openssh
/etc/init.d/hostname --quiet restart
setup-proxy -q $PROXY
. /etc/profile.d/proxy.sh
setup-apkrepos $REPOSITORY
setup-ntp -c chrony
[ -b /dev/vda ] && echo -e "y\n" | setup-disk -m sys -s 0 -L /dev/vda
[ -b /dev/sda ] && echo -e "y\n" | setup-disk -m sys -s 0 -L /dev/sda

# Post Installation
rc-service sshd stop
mount /dev/vg0/lv_root /mnt

# Enable serial console
sed -i 's/\\bdefault_kernel_opts=\"quiet\\b/& console=ttyS0,115200 console=tty0 ignore_loglevel/' /mnt/etc/update-extlinux.conf
sed -i 's/^serial_port=.*/serial_port=0/' /mnt/etc/update-extlinux.conf

SSHD_CONFIG=/mnt/etc/ssh/sshd_config
sed -i 's/^#PermitRootLogin.*/PermitRootLogin yes/g' $SSHD_CONFIG
grep -s -q -w "^UseDNS yes" $SSHD_CONFIG && sed -i "/UseDNS/d" $SSHD_CONFIG && sed -i "/^# no default banner path/i UseDNS no" $SSHD_CONFIG
grep -s -q -w "^GSSAPIAuthentication yes" $SSHD_CONFIG && sed -i "/GSSAPIAuthentication/d" $SSHD_CONFIG && sed -i "/^# no default banner path/i GSSAPIAuthentication no" $SSHD_CONFIG
grep -s -q -w "^GSSAPICleanupCredentials yes" $SSHD_CONFIG && sed -i "/GSSAPICleanupCredentials/d" $SSHD_CONFIG && sed -i "/^# no default banner path/i GSSAPICleanupCredentials no" $SSHD_CONFIG

umount /mnt

reboot
