#!/bin/bash

curl -sL https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python get-pip.py --user
pip install --user powerline-status powerline-shell
mkdir -p ~/.config/powerline-shell && powerline-shell --generate-config > ~/.config/powerline-shell/config.json
jq '.=.+{"vcs":{"show_symbol": true}}' ~/.config/powerline-shell/config.json
jq '.=.+{"cwd":{"max_dir_size":2,"full_cwd":true}}' ~/.config/powerline-shell/config.json | sponge ~/.config/powerline-shell/config.json
cat <<'EOF' >>~/.bashrc
function _update_ps1() {
    PS1=$(powerline-shell $?)
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
