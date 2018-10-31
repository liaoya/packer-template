#!/bin/bash -eux

[[ -n ${CUSTOM_ASDF} && "${CUSTOM_ASDF}" == "true" ]] || exit 0
echo "==> Install asdf"

[[ $(command -v git) ]] || { echo "git is required"; exit 0; }
export ASDF_DATA_DIR=/opt/asdf
git clone https://github.com/asdf-vm/asdf.git ${ASDF_DATA_DIR} --branch v0.6.0
if [[ -n "$(ls -A ${ASDF_DATA_DIR})" ]]; then
    if [[ -n ${SUDO_USER} ]]; then
        real_user=$(id -u "${SUDO_USER}")
        real_group=$(id -g "${SUDO_USER}")
        chown -R "${real_user}:${real_group}" "${ASDF_DATA_DIR}"
    fi

    echo "[[ -s \"${ASDF_DATA_DIR}\"/asdf.sh ]] && export ASDF_DATA_DIR=\"${ASDF_DATA_DIR}\" && source \"\${ASDF_DATA_DIR}\"/asdf.sh" | tee /etc/profile.d/asdf.sh
    [[ -d /etc/bash_completion.d ]] || mkdir -p /etc/bash_completion.d
    [[ -f ${ASDF_DATA_DIR}/completions/asdf.bash ]] && cp -pr "${ASDF_DATA_DIR}/completions/asdf.bash" /etc/bash_completion.d

    [[ -d /etc/fish/conf.d ]] || mkdir -p /etc/fish/conf.d
    echo "[ -s \"${ASDF_DATA_DIR}\"/asdf.fish ]; and set -xg ASDF_DATA_DIR \"${ASDF_DATA_DIR}\"; and source \$ASDF_DATA_DIR/asdf.fish" | tee /etc/fish/conf.d/asdf.fish
    [[ -d /etc/fish/completions ]] || mkdir -p /etc/fish/completions
    [[ -f ${ASDF_DATA_DIR}/completions/asdf.fish ]] && cp -pr "${ASDF_DATA_DIR}/completions/asdf.fish" /etc/fish/completions
fi
