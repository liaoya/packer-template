#!/bin/bash

# Remove Bash history
unset HISTFILE
rm -f /root/.bash_history
if [[ -n ${SUDO_USER} ]]; then
    user_home=$(getent passwd "${SUDO_USER}" | cut -d: -f6)
    rm -f "${user_home}/.bash_history"
fi
