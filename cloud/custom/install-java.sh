#!/bin/bash -eux

[[ -n ${CUSTOM_JAVA} && "${CUSTOM_JAVA}" == "true" ]] || exit 0
echo "==> Run custom Java script"

echo "==> Install Jabba"
export JABBA_HOME=/opt/jabba
[ -d ${JABBA_HOME} ] && rm -fr ${JABBA_HOME}
curl -sL https://github.com/shyiko/jabba/raw/master/install.sh | bash
if [[ -n "$(ls -A ${JABBA_HOME})" ]]; then
    sed -i "/jabba.sh/d" ~/.bashrc
    [[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" ${JABBA_HOME}
    echo '[ -s "$JABBA_HOME/jabba.sh" ] && export JABBA_HOME=/opt/jabba && source "$JABBA_HOME/jabba.sh"' | tee /etc/profile.d/jabba.sh
    [[ -d /etc/fish/conf.d ]] || mkdir -p /etc/fish/conf.d
    echo '[ -s /opt/jabba/jabba.fish ]; and set -xg JABBA_HOME /opt/jabba; and source $JABBA_HOME/jabba.fish' | tee /etc/fish/conf.d/jabba.fish
fi

echo "==> Install sdkman"
export SDKMAN_DIR=/opt/sdkman
[[ $(command -v unzip) || $(command -v zip) ]] || { echo "unzip is required"; exit 0; }
[ -d ${SDKMAN_DIR} ] && rm -fr ${SDKMAN_DIR}
curl -sL "https://get.sdkman.io" | bash
if [[ -n "$(ls -A ${SDKMAN_DIR})" ]]; then
    sed -i "/sdkman/Id" ~/.bashrc
    [[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" ${SDKMAN_DIR}
    echo '[[ -s /opt/sdkman/bin/sdkman-init.sh ]] && export SDKMAN_DIR=/opt/sdkman && source ${SDKMAN_DIR}/bin/sdkman-init.sh' > /etc/profile.d/sdkman.sh
fi
