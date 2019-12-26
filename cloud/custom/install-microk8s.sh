#!/bin/bash

[[ -n ${CUSTOM_MICROK8S} && "${CUSTOM_MICROK8S^^}" == "TRUE" ]] || exit 0

if [[ $(command -v snap) ]]; then
    if [[ -n ${CUSTOM_MICROK8S_VERSION} ]]; then
        snap install --classic --channel="${CUSTOM_MICROK8S_VERSION}" microk8s 
    else
        snap install --classic microk8s 
    fi
    getent group microk8s && usermod -aG microk8s "${SUDO_USER}"
    cat <<'EOF' | tee /etc/profile.d/microk8s.sh
if [[ -n ${no_proxy} && ! ${no_proxy} =~ '10.152.183.1' ]]; then
    printf -v microk8s_no_proxy '%s,' 10.152.183.{1..255}
    export no_proxy="$no_proxy,${microk8s_no_proxy%,}"
    export NO_PROXY=$no_proxy
fi
EOF
fi
