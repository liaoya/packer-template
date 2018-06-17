#!/bin/bash -eux

[[ -n ${CUSTOM_PYTHON_VIRTUALENV} && "${CUSTOM_PYTHON_VIRTUALENV}" == "true" ]] || exit 0
echo "==> Install Ubuntu virtualenv packages"

apt install -y python-virtualenv python3-virtualenv virtualenv gcc

VPY_DIR=vpy2
PYTHON_EXEC=/usr/bin/python2
if [[ -x ${PYTHON_EXEC} ]]; then
    [[ -d /opt/${VPY_DIR} ]] && rm -fr /opt/${VPY_DIR}
    virtualenv -p ${PYTHON_EXEC} --system-site-packages /opt/${VPY_DIR}
    [[ -n ${SSH_USERNAME} ]] && chown -R "$(id -un ${SSH_USERNAME}):$(id -gn ${SSH_USERNAME})" /opt/${VPY_DIR}
fi

VPY_DIR=vpy3
PYTHON_EXEC=/usr/bin/python3
if [[ -x ${PYTHON_EXEC} ]]; then
    [[ -d /opt/${VPY_DIR} ]] && rm -fr /opt/${VPY_DIR}
    virtualenv -p ${PYTHON_EXEC} --system-site-packages /opt/${VPY_DIR}
    [[ -n ${SSH_USERNAME} ]] && chown -R "$(id -un ${SSH_USERNAME}):$(id -gn ${SSH_USERNAME})" /opt/${VPY_DIR}
fi
