#! /bin/bash

echo "==> Install Fedora docker packages"

if [[ -n $OFFICIAL_DOCKER && "$OFFICIAL_DOCKER" == "true" ]]; then
    dnf -y -q install dnf-plugins-core
    dnf config-manager --add-repo https://download.docker.com/linux/fedora/docker-ce.repo
    dnf -y -q install docker-ce
else
    dnf install -y -q docker
fi

[[ $(command -v docker) ]] && systemctl enable docker && [[ -n $SSH_USERNAME ]] && getent group docker && usermod -aG docker $SSH_USERNAME || true

curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
