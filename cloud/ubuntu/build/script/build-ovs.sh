#!/bin/bash

apt-get install -qq -y -o "Dpkg::Use-Pty=0" module-assistant build-essential fakeroot git graphviz autoconf automake bzip2 \
    debhelper dh-autoreconf libssl-dev libtool openssl procps \
    python-all python-qt4 python-twisted-conch python-zopeinterface python-six libcap-ng-dev >/dev/null

cd ~

VERSION=2.8.1
[ -d ~/openvswitch-${VERSION} ] && rm -fr ~/openvswitch-${VERSION}
URL=http://openvswitch.org/releases/openvswitch-${VERSION}.tar.gz
[ -f $(basename $URL) ] || curl -L -s -O $URL
tar -xf $(basename $URL)
cd openvswitch-${VERSION}
dpkg-checkbuilddeps
DEB_BUILD_OPTIONS="-s parallel=${NUM_CPUS} nocheck" fakeroot debian/rules binary
cp -pr ../*.deb /vagrant/output

(dpkg -i ~/openvswitch-datapath-source_2*_all.deb && \
    m-a --text-mode prepare && \
    m-a --text-mode build openvswitch-datapath) ||
    { echo >&2 "Unable to build kernel modules"; exit 1; }
cp -v /usr/src/openvswitch-datapath-module-*.deb /vagrant/output

echo "==> Succeed to build openvswitch $VERSION"
