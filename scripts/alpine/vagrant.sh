set -exu

date > /etc/vagrant_box_build_time

#
# bash for vagrant (default shell is bash)
#   doesn't look like there is an easy way for vagrant guest
#   plugin to register a default shell. easier than always
#   having to *remember* to configure `ssh.shell` for
#   alpine boxes.
#
# cURL for initial vagrant key install from vagrant github repo.
#   on first 'vagrant up', overwritten with a local, secure key.
#
[ -f /etc/profile.d/proxy.sh ] && . /etc/profile.d/proxy.sh
apk add bash curl

adduser -D vagrant -G users -s /bin/bash
echo "vagrant:vagrant" | chpasswd

mkdir -pm 700 /home/vagrant/.ssh

curl -sSo /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'

chown -R vagrant:users /home/vagrant/.ssh
chmod -R go-rwsx /home/vagrant/.ssh

cat << EOF >> /home/vagrant/.bashrc
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
EOF

cat << EOF >> /home/vagrant/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
EOF

chown vagrant:users /home/vagrant/.bashrc /home/vagrant/.bash_profile