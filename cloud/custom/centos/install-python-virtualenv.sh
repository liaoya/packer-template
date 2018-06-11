#!/bin/bash -eux

[[ -n ${CUSTOM_PYTHON_VIRTUALENV} && "${CUSTOM_PYTHON_VIRTUALENV}" == "true" ]] || exit 0
echo "==> Install CentOS virtualenv packages"

yum install -y -q python-devel python-virtualenv gcc

VPY2_DIR=$(mktemp -d)
virtualenv --system-site-packages --no-setuptools --no-pip ${VPY2_DIR}
source ${VPY2_DIR}/bin/activate
curl -L -s https://bootstrap.pypa.io/get-pip.py | python
pip install -U virtualenv setuptools
virtualenv --system-site-packages /opt/vpy2
deactivate
rm -fr ${VPY2_DIR}
[[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" /opt/vpy2
