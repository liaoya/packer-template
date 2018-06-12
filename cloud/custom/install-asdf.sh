#!/bin/bash -eux

[[ -n ${CUSTOM_ASDF} && ${CUSTOM_ASDF} == true ]] || exit 0
echo "==> Install asdf"

[[ $(command -v git) ]] || (echo "git is required"; exit 1)
git clone https://github.com/asdf-vm/asdf.git /opt/asdf --branch v0.5.0

cat <<'EOF' > /etc/profile.d/asdf.sh
export ASDF_HOME=/opt/asdf
[[ -f ${ASDF_HOME}/asdf.sh ]] && . ${ASDF_HOME}/asdf.sh
[[ -f ${ASDF_HOME}/completions/asdf.bash ]] && . ${ASDF_HOME}/completions/asdf.bash
EOF

[[ -n ${SSH_USERNAME} ]] && chown -R "$(id -u ${SSH_USERNAME}):$(id -g ${SSH_USERNAME})" /opt/asdf
