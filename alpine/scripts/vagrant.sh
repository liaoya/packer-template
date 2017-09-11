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
apk update
apk add bash curl

adduser -D -s /bin/bash vagrant
echo "vagrant:vagrant" | chpasswd

mkdir -pm 700 /home/vagrant/.ssh

VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
echo "${VAGRANT_INSECURE_KEY}" > /home/vagrant/.ssh/authorized_keys
#curl -sSo /home/vagrant/.ssh/authorized_keys 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'

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