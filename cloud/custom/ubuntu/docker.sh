#!/bin/bash -eux

echo "==> Install Docker"

if [[ -n $OFFICIAL_DOCKER && "$OFFICIAL_DOCKER" == "true" ]]; then
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    echo "deb [arch=amd64] http://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
    apt-get update -qq
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" docker-ce >/dev/null
else
    apt-get install -y -qq -o "Dpkg::Use-Pty=0" docker.io >/dev/null
fi

curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
