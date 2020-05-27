#!/bin/bash

THIS_FILE=$(readlink -f "${BASH_SOURCE[0]}")
THIS_DIR=$(dirname "${THIS_FILE}")

function check_centos7() {
    local iso_checksum iso_name iso_url
    iso_checksum=$(curl -sL https://cloud.centos.org/centos/7/images/sha256sum.txt)
    iso_name=$(echo "${iso_checksum}" | grep '.qcow2c' | tail -1 | tr -s ' ' | cut -d' ' -f2)
    iso_checksum=$(echo "${iso_checksum}" | grep '.qcow2c' | tail -1 | tr -s ' ' | cut -d' ' -f1)
    iso_url="https://cloud.centos.org/centos/7/images/${iso_name}"
    if [[ ${iso_checksum} != $(jq '.iso_checksum' "${THIS_DIR}/centos7.json" | tr -d '"') ]]; then
        jq ".iso_checksum=\"${iso_checksum}\"" "${THIS_DIR}/centos7.json" | sponge "${THIS_DIR}/centos7.json"
        jq ".iso_name=\"${iso_name}\"" "${THIS_DIR}/centos7.json" | sponge "${THIS_DIR}/centos7.json"
        jq ".iso_url=\"${iso_url}\"" "${THIS_DIR}/centos7.json" | sponge "${THIS_DIR}/centos7.json"
    fi
}

function check_centos8() {
    local iso_checksum iso_name iso_url line
    line=$(curl -sL https://cloud.centos.org/centos/8/x86_64/images/CHECKSUM | grep CentOS-8-GenericCloud | grep -v '^#' | tail -n 1)
    iso_checksum=$(echo "${line}" | cut -d '=' -f2 | tr -d '[:space:]')
    iso_name=$(echo "${line}" | cut -d '=' -f1 | tr -d '()' | cut -d ' ' -f 2 | tr -d '[:space:]')
    iso_url="https://cloud.centos.org/centos/8/images/${image_name}"
    if [[ ${iso_checksum} != $(jq '.iso_checksum' "${THIS_DIR}/centos8.json" | tr -d '"') ]]; then
        jq ".iso_checksum=\"${iso_checksum}\"" "${THIS_DIR}/centos8.json" | sponge "${THIS_DIR}/centos8.json"
        jq ".iso_name=\"${iso_name}\"" "${THIS_DIR}/centos8.json" | sponge "${THIS_DIR}/centos8.json"
        jq ".iso_url=\"${iso_url}\"" "${THIS_DIR}/centos8.json" | sponge "${THIS_DIR}/centos8.json"
    fi
}

function check_ubuntu_image() {
    local json_file url_prefix image_name
    json_file=$1; shift 1
    url_prefix=$1; shift 1
    image_name=$1; shift 1
    release_date=$(curl -sL "${url_prefix}/release/unpacked/build-info.txt" | grep "serial=" | cut -d "=" -f2)
    if [[ $(jq -r '.iso_url' "${json_file}") != "${url_prefix}/release-${release_date}/${image_name}" ]]; then
        eval "jq '.version=\"${release_date}\"' ${json_file}" | sponge "${json_file}"
        sha_value=$(curl -sL "${url_prefix}/release-${release_date}/SHA256SUMS" | grep "${image_name}" | cut -d' ' -f1)
        eval "jq '.iso_url=\"${url_prefix}/release-${release_date}/${image_name}\"' ${json_file}" | sponge "${json_file}"
        eval "jq '.iso_checksum=\"${sha_value}\"' ${json_file}" | sponge "${json_file}"
    fi
}

function check_ubuntu() {
    check_ubuntu_image "${THIS_DIR}/ubuntu-1804.json" https://cloud-images.ubuntu.com/releases/bionic ubuntu-18.04-server-cloudimg-amd64.img
    check_ubuntu_image "${THIS_DIR}/ubuntu-1804-i386.json" https://cloud-images.ubuntu.com/releases/bionic ubuntu-18.04-server-cloudimg-i386.img
    check_ubuntu_image "${THIS_DIR}/ubuntu-minimal-1804.json" https://cloud-images.ubuntu.com/minimal/releases/bionic ubuntu-18.04-minimal-cloudimg-amd64.img

    check_ubuntu_image "${THIS_DIR}/ubuntu-2004.json" https://cloud-images.ubuntu.com/releases/focal ubuntu-20.04-server-cloudimg-amd64.img
    check_ubuntu_image "${THIS_DIR}/ubuntu-minimal-2004.json" https://cloud-images.ubuntu.com/minimal/releases/focal ubuntu-20.04-minimal-cloudimg-amd64.img

    check_ubuntu_image "${THIS_DIR}/ubuntu-1604.json" https://cloud-images.ubuntu.com/releases/xenial ubuntu-16.04-server-cloudimg-amd64-disk1.img
    check_ubuntu_image "${THIS_DIR}/ubuntu-minimal-1604.json" https://cloud-images.ubuntu.com/minimal/releases/xenial ubuntu-16.04-minimal-cloudimg-amd64-disk1.img
}

check_centos7
check_centos8
check_ubuntu
