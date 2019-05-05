#!/bin/bash -eux

echo "==> Install Fedora common packages"

dnf install -y -q bzip2 fish fish git jq moreutils nano screen sshpass tig tmux unzip vim xz zip

if [[ -n ${CUSTOM_UPDATE} && "${CUSTOM_UPDATE}" == "true" ]]; then dnf -y -q update; fi
