#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

function check_centos7() {
    local iso_checksum iso_name iso_url
    iso_checksum=$(curl -sL https://cloud.centos.org/centos/7/images/sha256sum.txt)
    iso_name=$(echo "${iso_checksum}" | grep '.qcow2c' | tail -1 | tr -s ' ' | cut -d' ' -f2)
    iso_checksum=$(echo "${iso_checksum}" | grep '.qcow2c' | tail -1 | tr -s ' ' | cut -d' ' -f1)
    iso_url="https://cloud.centos.org/centos/7/images/${image_name}"
    if [[ ${iso_checksum} != $(jq '.iso_checksum' "${THIS_DIR}/centos7.json" | tr -d '"') ]]; then
        jq ".iso_checksum=\"${checksum}\"" "${THIS_DIR}/centos7.json" | sponge "${THIS_DIR}/centos7.json"
        jq ".iso_name=\"${iso_name}\"" "${THIS_DIR}/centos7.json" | sponge "${THIS_DIR}/centos7.json"
        jq ".iso_url=\"${iso_url}\"" "${THIS_DIR}/centos7.json" | sponge "${THIS_DIR}/centos7.json"
    fi
}

check_centos7
