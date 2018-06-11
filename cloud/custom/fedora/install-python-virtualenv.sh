#!/bin/bash -eux

[[ -n ${CUSTOM_PYTHON_VIRTUALENV} && "${CUSTOM_PYTHON_VIRTUALENV}" == "true" ]] || exit 0
echo "==> Install Fedora virtualenv packages"
