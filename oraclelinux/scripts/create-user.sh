#!/bin/bash

if [[ -n ${CUSTOM_USER} && -n ${CUSTOM_GROUP} ]]; then
    if ! getent group "${CUSTOM_GROUP}"; then
        groupadd "${CUSTOM_GROUP}"
    fi
    if ! getent passwd "${CUSTOM_USER}"; then
        useradd -g "${CUSTOM_GROUP}" "${CUSTOM_USER}"
    fi
    echo "${CUSTOM_USER}   ALL=(ALL)   NOPASSWD: ALL" > "/etc/sudoers.d/${CUSTOM_USER}"
    chmod 0440 "/etc/sudoers.d/${CUSTOM_USER}"
    echo "${CUSTOM_USER}:${CUSTOM_USER}" | chpasswd
fi
