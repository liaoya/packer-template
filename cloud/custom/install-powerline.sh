#!/bin/bash
#shellcheck disable=SC1090,SC1091

[[ -n ${CUSTOM_POWERLINE} && "${CUSTOM_POWERLINE^^}" == "TRUE" ]] || exit 0

if [[ ! -f /tmp/get-pip.py ]]; then
    curl -sL https://bootstrap.pypa.io/get-pip.py -o /tmp/get-pip.py
fi

if [[ ! -f /tmp/get-pip.py ]]; then
    echo "Fail to download /tmp/get-pip.py"
    exit 0
fi

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

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")

if [[ $UID -eq 0 ]]; then
    if [[ -n "${SUDO_USER}" ]]; then
        su -l "${SUDO_USER}" -c "set -a -x; export CUSTOM_POWERLINE=true; source /etc/environment; bash -e -x ${THIS_FILE}"
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
#[[ -d "${HOME}/.local/bin" ]] && pathmunge "${HOME}/.local/bin"
EOF
    [[ -d "${HOME}/.local/bin" ]] || mkdir -p "${HOME}/.local/bin"
    pathmunge "${HOME}/.local/bin"
fi

PYTHON_EXEC=$(find /usr/bin -type f -iname "python3.*" | grep -v "m$" | tail -1)
if [[ -z ${PYTHON_EXEC} ]]; then
    PYTHON_EXEC=$(find /usr/bin -type f -iname "python2.*" | tail -1)
fi
eval "${PYTHON_EXEC}" /tmp/get-pip.py --user
pip install --user --upgrade powerline-status powerline-shell

mkdir -p ~/.config/powerline-shell && powerline-shell --generate-config > ~/.config/powerline-shell/config.json
if [[ $(command -v jq) && $(command -v sponge) ]]; then
    jq 'del(.segments[1]) | del(.segments[2])' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
    jq '.=.+{"vcs":{"show_symbol": true}}' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
    jq '.=.+{"cwd":{"max_depth":1,"max_dir_size":2,"full_cwd":true}}' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
fi
cat <<'EOF' >>~/.bashrc
function _update_ps1() {
    [[ $(command -v powerline-shell) ]] && PS1=$(powerline-shell $?)
}
if [[ $TERM != linux && ! $PROMPT_COMMAND =~ _update_ps1 ]]; then
    PROMPT_COMMAND="_update_ps1; $PROMPT_COMMAND"
fi
EOF
[[ -d ~/.config/fish ]] || mkdir -p ~/.config/fish
cat <<'EOF' >>~/.config/fish/config.fish
function fish_prompt
    powerline-shell --shell bare $status
end
EOF

tmuxfile=$(find ~/.local/lib -iname powerline.conf)
touch ~/.tmux.conf
sed -i "/tmux\\/powerline\\.conf/d" ~/.tmux.conf
if [[ -z $(tail -1 ~/.tmux.conf | tr -s "[:blank:]") ]]; then
    echo "source $tmuxfile" >> ~/.tmux.conf
else
    echo -e "\\nsource $tmuxfile" >> ~/.tmux.conf
fi

vimfolder=$(find ~/.local/lib -iname vim | grep powerline | grep bindings)
cat <<EOF >> ~/.vimrc
set rtp+=$vimfolder
set laststatus=2
set t_Co=256
EOF

if [[ $(command -v git) ]]; then
    [[ -d ~/.emacs.d/vendor ]] || mkdir -p ~/.emacs.d/vendor
    (cd ~/.emacs.d/vendor || exit 0; git clone https://github.com/milkypostman/powerline.git)
    cat <<EOF >> ~/.emacs
(add-to-list 'load-path "~/.emacs.d/vendor/powerline")
(require 'powerline)
(powerline-default-theme)
EOF
fi
