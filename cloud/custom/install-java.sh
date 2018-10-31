#!/bin/bash -eux

[[ -n ${CUSTOM_JAVA} && "${CUSTOM_JAVA}" == "true" ]] || exit 0

echo "==> Install Jabba"
export JABBA_HOME=/opt/jabba
[ -d ${JABBA_HOME} ] && rm -fr ${JABBA_HOME}
curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash
if [[ -n "$(ls -A ${JABBA_HOME})" ]]; then
    sed -i "/jabba.sh/d" ~/.bashrc
    if [[ -n ${SUDO_USER} ]]; then
        real_user=$(id -u "${SUDO_USER}")
        real_group=$(id -g "${SUDO_USER}")
        chown -R "${real_user}:${real_group}" "${JABBA_HOME}"
        user_home=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
        if [[ -d "${user_home}/.config" ]]; then chown -R "${real_user}:${real_group}" "${user_home}/.config"; fi
    fi
    echo "[ -s \"${JABBA_HOME}\"/jabba.sh ] && export JABBA_HOME=\"${JABBA_HOME}\" && source \"\${JABBA_HOME}\"/jabba.sh" | tee /etc/profile.d/jabba.sh
    [[ -d /etc/fish/conf.d ]] || mkdir -p /etc/fish/conf.d
    echo "[ -s \"${JABBA_HOME}\"/jabba.fish ]; and set -xg JABBA_HOME \"${JABBA_HOME}\"; and source $JABBA_HOME/jabba.fish" | tee /etc/fish/conf.d/jabba.fish
fi

echo "==> Install sdkman"
export SDKMAN_DIR=/opt/sdkman
[[ $(command -v unzip) || $(command -v zip) || $(command -v curl) ]] || { echo "unzip is required"; exit 0; }
[ -d ${SDKMAN_DIR} ] && rm -fr ${SDKMAN_DIR}
curl -sL "https://get.sdkman.io" | bash
if [[ -n "$(ls -A ${SDKMAN_DIR})" ]]; then
    sed -i "/sdkman/Id" ~/.bashrc
    if [[ -n ${SUDO_USER} ]];then
        real_user=$(id -u "${SUDO_USER}")
        real_group=$(id -g "${SUDO_USER}")
        chown -R "${real_user}:${real_group}" "${SDKMAN_DIR}"
    fi
    echo "[[ -s \"${SDKMAN_DIR}\"/bin/sdkman-init.sh ]] && export SDKMAN_DIR=\"${SDKMAN_DIR}\" && source \"\${SDKMAN_DIR}\"/bin/sdkman-init.sh" > /etc/profile.d/sdkman.sh
fi
