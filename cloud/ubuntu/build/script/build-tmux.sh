#!/bin/bash

rm -fr /usr/local/*
cd ~

apt-get install -y -qq -o "Dpkg::Use-Pty=0" libevent-dev libncurses-dev >/dev/null

VERSION=2.6
[ -d ~/tmux-${VERSION} ] && rm -fr ~/tmux-${VERSION}
URL=https://github.com/tmux/tmux/releases/download/${VERSION}/tmux-${VERSION}.tar.gz
[ -f $(basename $URL) ] || curl -L -s -O $URL
tar -xf $(basename $URL)
cd tmux-${VERSION}
./configure -q --build=x86_64-pc-linux --host=x86_64-pc-linux --target=x86_64-pc-linux
make -s -j $(nproc) install-strip

cat <<EOF >>/usr/local/bin/install-tmux.sh
#!/bin/sh
if [ $UID -eq 0 ]; then
    apt-get update -qq
    apt-get install -qq -y libpcre2-32-0
    [ -f /etc/ld.so.conf.d/usr-local.conf ] || touch /etc/ld.so.conf.d/usr-local.conf
    grep -s -q -w "/usr/local/lib" /etc/ld.so.conf.d/usr-local.conf || echo "/usr/local/lib" >> /etc/ld.so.conf.d/usr-local.conf
    grep -s -q -w "/usr/local/lib64" /etc/ld.so.conf.d/usr-local.conf || echo "/usr/local/lib64" >> /etc/ld.so.conf.d/usr-local.conf
    ldconfig
fi
[ -f ~/.tmux.conf ] || touch ~/.tmux.conf
grep -s -q "set-option -g allow-rename off" ~/.tmux.conf || echo "set-option -g allow-rename off" >> ~/.tmux.conf
grep -s -q "set-option -g history-limit 10000" ~/.tmux.conf || echo "set-option -g history-limit 10000" >> ~/.tmux.conf
EOF

chmod a+x /usr/local/bin/install-tmux.sh

tar -C /usr/local -Jcf /vagrant/output/tmux-$VERSION.txz .

echo "==> Succeed to build tmux $VERSION"
