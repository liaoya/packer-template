#!/bin/bash -eux

# Depreciate it

[[ -n ${CUSTOM_PYTHON_VIRTUALENV} && "${CUSTOM_PYTHON_VIRTUALENV}" == "true" ]] || exit 0
echo "==> Install Ubuntu virtualenv packages"

apt install -y python-virtualenv python3-virtualenv virtualenv gcc make

VPY_DIR=vpy2
PYTHON_EXEC=/usr/bin/python2
if [[ -x ${PYTHON_EXEC} ]]; then
    [[ -d /opt/${VPY_DIR} ]] && rm -fr "/opt/${VPY_DIR}"
    virtualenv -p ${PYTHON_EXEC} --system-site-packages "/opt/${VPY_DIR}"
    if [[ -n ${SUDO_USER} ]]; then
        real_user=$(id -u "${SUDO_USER}")
        real_group=$(id -g "${SUDO_USER}")
        chown -R "${real_user}:${real_group}" "/opt/${VPY_DIR}"
    fi
fi

VPY_DIR=vpy3
PYTHON_EXEC=/usr/bin/python3
if [[ -x ${PYTHON_EXEC} ]]; then
    [[ -d /opt/${VPY_DIR} ]] && rm -fr "/opt/${VPY_DIR}"
    virtualenv -p ${PYTHON_EXEC} --system-site-packages "/opt/${VPY_DIR}"
    if [[ -n ${SUDO_USER} ]]; then
        real_user=$(id -u "${SUDO_USER}")
        real_group=$(id -g "${SUDO_USER}")
        chown -R "${real_user}:${real_group}" "/opt/${VPY_DIR}"
    fi
fi
