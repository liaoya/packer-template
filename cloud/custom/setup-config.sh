#!/bin/bash

# Run this script after all the software installed

if [[ $UID -eq 0 ]]; then
    if [[ -n "${SUDO_USER}" ]]; then
        su -l "${SUDO_USER}" -c "set -a -x; source /etc/environment; bash -e -x ${THIS_FILE}"
        exit 0
    fi
fi

if ! grep -s -q "^pathmunge () {" "${HOME}/.bashrc"; then
    cat <<'EOF' >> "${HOME}/.bashrc"
pathmunge () {
    case ":${PATH}:" in
        *:"$1":*)
        ;;
        *)
            if [ "$2" = "after" ] ; then
                PATH=$PATH:$1
            else
                PATH=$1:$PATH
            fi
    esac
}
EOF
fi

if [[ -n $(command -v tmux) ]]; then
    cat <<EOF >> "${HOME}/.tmux.conf"
set -g buffer-limit 10000
set -g history-limit 5000
set -g renumber-windows on
EOF
    [[ -n $(command -v fish) ]] && echo "set -g default-shell $(command -v fish)" > "${HOME}/.tmux.conf"
fi
