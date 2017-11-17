set -exu

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
apk update -q --no-progress
apk add -q --no-progress bash curl

SSH_USER="vagrant"
SSH_GROUP="users"
SSH_PASS="vagrant"

adduser -D -s /bin/bash -G $SSH_GROUP $SSH_USER
echo "$SSH_USER:$SSH_PASS" | chpasswd

mkdir -pm 700 /home/vagrant/.ssh

# VAGRANT_INSECURE_KEY="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
# echo "${VAGRANT_INSECURE_KEY}" > /home/$SSH_USER/.ssh/authorized_keys
curl -sSo /home/$SSH_USER/.ssh/authorized_keys 'https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub'
cp /home/$SSH_USER/.ssh/authorized_keys /home/$SSH_USER/.ssh/id_rsa.pub
curl -s -S -L https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant -o /home/$SSH_USER/.ssh/id_rsa

chown -R $SSH_USER:$SSH_GROUP /home/$SSH_USER/.ssh
chmod -R go-rwsx /home/$SSH_USER/.ssh
chmod 644 /home/$SSH_USER/.ssh/authorized_keys
chmod 644 /home/$SSH_USER/.ssh/id_rsa.pub
chmod 600 /home/$SSH_USER/.ssh/id_rsa

cat << 'EOF' >> /home/$SSH_USER/.bashrc
# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific aliases and functions
EOF

cat << 'EOF' >> /home/$SSH_USER/.bash_profile
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
    . ~/.bashrc
fi

# User specific environment and startup programs
# export PATH=/usr/local/bin:/usr/local/sbin:/usr/bin:/usr/sbin:/bin:/sbin
EOF

chown $SSH_USER:$SSH_GROUP /home/$SSH_USER/.bashrc /home/$SSH_USER/.bash_profile
