#!/bin/bash -eux
#shellcheck disable=SC1090,SC2086

[[ -n ${CUSTOM_PYTHON_VIRTUALENV} && "${CUSTOM_PYTHON_VIRTUALENV}" == "true" ]] || exit 0
echo "==> Install Orace Linux virtualenv packages"

# yum install -y -q python-devel python-virtualenv gcc
# VPY2_DIR=$(mktemp -d)
# virtualenv --system-site-packages --no-setuptools --no-pip ${VPY2_DIR}
# source ${VPY2_DIR}/bin/activate
# curl -L -s https://bootstrap.pypa.io/get-pip.py | python
# pip install -U virtualenv setuptools
# virtualenv --system-site-packages /opt/vpy2
# [[ -n ${SUDO_USER} ]] && chown -R "$(id -u ${SUDO_USER}):$(id -g ${SUDO_USER})" /opt/vpy2

yum install -y -q python36-devel gcc
VPY_DIR=/opt/vpy3
PYTHON_EXEC=/usr/bin/python3.6
[[ -d "/opt/${VPY_DIR}" ]] && rm -fr "${VPY_DIR}"
"${PYTHON_EXEC}" -m venv --clear --without-pip "${VPY_DIR}"
source ${VPY_DIR}/bin/activate
curl -L -s https://bootstrap.pypa.io/get-pip.py | python3
pip install -U six ipython requests pylint flake8 httpie
[[ -n ${SUDO_USER} ]] && chown -R "$(id -u ${SUDO_USER}):$(id -g ${SUDO_USER})" "${VPY_DIR}"
