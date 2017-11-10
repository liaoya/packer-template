#!/bin/bash -eux

echo "==> Install Docker"

deb_file=$(ls -1 /tmp/download/docker-ce*.deb | sort | tail -n 1)
[[ -f $deb_file ]] && echo "==> Install $deb_file" && apt-get install -y -qq -o "Dpkg::Use-Pty=0" $deb_file >/dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
