#!/bin/bash -eux

[[ -n ${CUSTOM_DOCKER} && "${CUSTOM_DOCKER}" == "true" ]] || [[ -n ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]] || exit 0
echo "==> Install CentOS docker packages"

yum install -y -q bridge-utils

if [[ -n  ${CUSTOM_DOCKER_CE} && "${CUSTOM_DOCKER_CE}" == "true" ]]; then
    echo '==> Install docker-ce for CentOS'
    yum install -y -q yum-utils
    yum-config-manager --add-repo http://download.docker.com/linux/centos/docker-ce.repo
    yum install -y -q docker-ce
else
    yum install -y -q docker
fi

[[ $(command -v docker) ]] && systemctl enable docker && [[ -n ${SSH_USERNAME} ]] && getent group docker && usermod -aG docker ${SSH_USERNAME} || true

curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
