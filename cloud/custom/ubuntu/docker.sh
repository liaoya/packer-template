#!/bin/bash -eux

echo "==> Install Docker"

deb_file=$(ls -1 /tmp/download/docker-ce*.deb | sort | tail -n 1)
[[ -f $deb_file ]] && echo "==> Install $deb_file" && apt-get install -y -qq -o "Dpkg::Use-Pty=0" $deb_file >/dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
echo "deb [arch=amd64] http://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
apt-get update -qq
apt-get install -y -qq -o "Dpkg::Use-Pty=0" docker-ce >/dev/null

curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
