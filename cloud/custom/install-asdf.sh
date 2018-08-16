#!/bin/bash -eux

[[ -n ${CUSTOM_ASDF} && ${CUSTOM_ASDF} == true ]] || exit 0
echo "==> Install asdf"

[[ $(command -v git) ]] || { echo "git is required"; exit 0; }
git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.5.1
if [[ -n "$(ls -A /opt/asdf)" ]]; then
    [[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" /opt/asdf

    echo '[[ -s /opt/asdf/asdf.sh ]] && export ASDF_HOME=/opt/asdf && . ${ASDF_HOME}/asdf.sh' | tee /etc/profile.d/asdf.sh
    [[ -d /etc/bash_completion.d ]] || mkdir -p /etc/bash_completion.d
    [[ -f ${ASDF_HOME}/completions/asdf.bash ]] && cp -pr ${ASDF_HOME}/completions/asdf.bash /etc/bash_completion.d

    [[ -d /etc/fish/conf.d ]] || mkdir -p /etc/fish/conf.d
    echo '[ -s /opt/asdf/asdf.fish ]; and set -xg ASDF_HOME /opt/asdf; and source $ASDF_HOME/asdf.fish' | tee /etc/fish/conf.d/asdf.fish
    [[ -d /etc/fish/completions ]] || mkdir -p /etc/fish/completions
    [[ -f /opt/asdf/completions/asdf.fish ]] && cp -pr /opt/asdf/completions/asdf.fish /etc/fish/completions
fi
