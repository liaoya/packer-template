#!/bin/bash -eux

[[ -n ${CUSTOM_LIBVIRT} && "${CUSTOM_LIBVIRT}" == "true" ]] || exit 0

echo "==> Install Ubuntu docker"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" docker.io >/dev/null
[[ -n ${SSH_USERNAME} ]] && getent group docker && usermod -aG docker ${SSH_USERNAME} || true

curl -LsS https://raw.githubusercontent.com/openvswitch/ovs/master/utilities/ovs-docker -o /usr/local/bin/ovs-docker && chmod a+x /usr/local/bin/ovs-docker || true
curl -LsS https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework -o /usr/local/bin/pipework && chmod a+x /usr/local/bin/pipework || true
