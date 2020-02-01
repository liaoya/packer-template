#!/bin/bash -eux

if [[ "$DESKTOP" =~ ^(true|yes|on|1|TRUE|YES|ON])$ ]]; then
  exit
fi

echo "==> Disk usage before minimization"
df -h

echo "==> Installed packages before cleanup"
dpkg --get-selections | grep -v deinstall

# Remove some packages to get a minimal install
echo "==> Removing all linux kernels except the currrent one"
dpkg --list | awk '{ print $2 }' | grep -e 'linux-\(headers\|image\)-.*[0-9]\($\|-generic\)' | grep -v "$(uname -r | sed 's/-generic//')" | xargs apt-get -y -qq purge
echo "==> Removing linux source"
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y -qq purge
echo "==> Removing development packages"
dpkg --list | awk '{ print $2 }' | grep -- '-dev$' | xargs apt-get -y -qq purge
echo "==> Removing documentation"
dpkg --list | awk '{ print $2 }' | grep -- '-doc$' | xargs apt-get -y -qq purge
echo "==> Removing development tools"
#dpkg --list | grep -i compiler | awk '{ print $2 }' | xargs apt-get -y -qq purge
#apt-get -y -qq purge cpp gcc g++ 
apt-get -y -qq purge build-essential git
echo "==> Removing default system Ruby"
apt-get -y -qq purge ruby ri doc
echo "==> Removing default system Python"
apt-get -y -qq purge python-dbus libnl1 python-smartpm python-twisted-core libiw30 python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl libffi5
echo "==> Removing X11 libraries"
apt-get -y -qq purge libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6
echo "==> Removing obsolete networking components"
apt-get -y -qq purge ppp pppconfig pppoeconf
echo "==> Removing other oddities"
apt-get -y -qq purge popularity-contest installation-report landscape-common wireless-tools wpasupplicant ubuntu-serverguide

# Clean up the apt cache
apt-get -y -qq autoremove --purge
apt-get -y -qq autoclean
apt-get -y -qq clean

# Clean up orphaned packages with deborphan
apt-get -y -qq install deborphan
while [ -n "$(deborphan --guess-all --libdevel)" ]; do
    deborphan --guess-all --libdevel | xargs apt-get -y -qq purge
done
apt-get -y -qq purge deborphan dialog

# echo "==> Removing man pages"
# rm -rf /usr/share/man/*
echo "==> Removing APT files"
find /var/lib/apt -type f -exec rm -f {} \;
# echo "==> Removing any docs"
# rm -rf /usr/share/doc/*
echo "==> Removing caches"
find /var/cache -type f -exec rm -rf {} \;

echo "==> Disk usage after cleanup"
df -h
