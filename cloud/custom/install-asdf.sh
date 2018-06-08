#!/bin/bash -eux

if [[ -n ${CUSTOM_ASDF} && ${CUSTOM_ASDF} == true ]] || exit 0
echo "==> Install asdf"

[[ $(command -v git) ]] || (echo "git is required"; exit 0)
git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.5.0
if [[ -n ${SSH_USERNAME} ]]; then
    chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" /opt/asdf
    su -l "$SSH_USER" -c "echo -e '\n. /opt/asdf/asdf.sh' >> ~/.bashrc"
    su -l "$SSH_USER" -c "echo -e '. /opt/asdf/completions/asdf.bash' >> ~/.bashrc"
fi
