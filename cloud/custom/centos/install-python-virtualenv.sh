#!/bin/bash -eux

[[ -n ${CUSTOM_PYTHON_VIRTUALENV} && "${CUSTOM_PYTHON_VIRTUALENV}" == "true" ]] || exit 0
echo "==> Install CentOS virtualenv packages"

# yum install -y -q python-devel python-virtualenv gcc
# VPY_DIR=/opt/vpy2
# PYTHON_EXEC=/usr/bin/python2
# [[ -d /opt/${VPY_DIR} ]] && rm -fr ${VPY_DIR}
# virtualenv -p ${PYTHON_EXEC} ${VPY_DIR}
# source ${VPY_DIR}/bin/activate
# curl -L -s https://bootstrap.pypa.io/get-pip.py | python2
# pip install -U virtualenv setuptools
# pip install -U six ipython requests pylint flake8 httpie
# [[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" ${VPY_DIR}

yum install -y -q python36-devel gcc
VPY_DIR=/opt/vpy3
PYTHON_EXEC=/usr/bin/python3.6
[[ -d /opt/${VPY_DIR} ]] && rm -fr ${VPY_DIR}
${PYTHON_EXEC} -m venv --clear --without-pip ${VPY_DIR}
source ${VPY_DIR}/bin/activate
curl -L -s https://bootstrap.pypa.io/get-pip.py | python3
pip install -U six ipython requests pylint flake8 httpie
[[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" ${VPY_DIR}
