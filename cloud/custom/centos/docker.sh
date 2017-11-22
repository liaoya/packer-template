#!/bin/bash -eux

yum install -y -q bridge-utils

if [[ -n $OFFICIAL_DOCKER && "$OFFICIAL_DOCKER" == "true" ]]; then
    echo '==> Install docker-ce for centos'
    yum install -y -q yum-utils
    yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo
    yum install -y -q docker-ce
fi

[[ $(command -v docker) ]] || { echo '==> Install CentOS docker'; yum install -y -q docker; }
systemctl enable docker

[[ -n $SSH_USERNAME ]] && getent group docker && usermod -aG docker $SSH_USERNAME || true

curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
