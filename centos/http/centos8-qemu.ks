# Install OS instead of upgrade
install
# Keyboard layouts
# old format: keyboard us
# new format:
keyboard --vckeymap=us --xlayouts='us'
# Root password
rootpw --plaintext centos
# System language
lang en_US

# System authorization information
auth --useshadow  --passalgo=sha512
# Use CDROM installation media
cdrom
# Use graphical install
graphical
# Run the Setup Agent on first boot
firstboot --enable
# SELinux configuration
selinux --disabled
# Do not configure the X Window System
skipx

# System services
services --disabled="chronyd"
ignoredisk --only-use=vda
# Firewall configuration
firewall --disabled
# Network information
network  --bootproto=dhcp --device=None
# Reboot after installation
reboot
# System timezone
timezone Asia/Shanghai --nontp
# System bootloader configuration
bootloader --append="crashkernel=auto console=tty1 console=ttyS0,115200 net.ifnames=0 biosdevname=0" --location=mbr
# Clear the Master Boot Record
zerombr
# Partition clearing information
clearpart --all --initlabel --drives=vda
# Disk partitioning information
part / --fstype="xfs" --grow --size=1

%packages
@^minimal-environment

-biosdevname
-iwl100-firmware
-iwl1000-firmware
-iwl105-firmware
-iwl135-firmware
-iwl2000-firmware
-iwl2030-firmware
-iwl3160-firmware
-iwl3945-firmware
-iwl4965-firmware
-iwl5000-firmware
-iwl5150-firmware
-iwl6000-firmware
-iwl6000g2a-firmware
-iwl6000g2b-firmware
-iwl6050-firmware
-iwl7260-firmware

%end
%addon com_redhat_kdump --disable --reserve-mb='auto'

%end

%post

# I must make it work again

%end
