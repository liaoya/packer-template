#!/bin/bash

download_url() {
    [[ ! -f $(basename $1) ]] && { echo "Download $1"; curl -L -O $1; }
}

download_url "https://dl.influxdata.com/influxdb/releases/influxdb_1.3.7_amd64.deb"

download_url "https://s3-us-west-2.amazonaws.com/grafana-releases/release/grafana_4.6.0_amd64.deb"

download_url "https://download.docker.com/linux/ubuntu/dists/xenial/pool/stable/amd64/docker-ce_17.09.0~ce-0~ubuntu_amd64.deb"

