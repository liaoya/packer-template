#!/bin/bash -eux

echo "==> Install self built software"
declare -a pkgs=( $(ls -1 /tmp/output/tmux*.txz | sort | tail -n 1) )
for elem in ${pkgs[@]}; do [[ -n $elem ]] && [ -f $elem ] && echo "==> Uncompress $elem" && tar -C /usr/local -xf $elem; done

echo "==> Install addtional software for all the boxes"
apt-get install -y -qq -o "Dpkg::Use-Pty=0" nmap net-tools sshpass libpcre2-32-0 >/dev/null

[[ -n $http_proxy ]] && apt-key adv --keyserver-options http-proxy="$http_proxy" --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 59FDA1CE1B84B3FAD89366C027557F056DC33CA5
[[ -n $http_proxy ]] || apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 59FDA1CE1B84B3FAD89366C027557F056DC33CA5
add-apt-repository -y ppa:fish-shell/release-2
apt-get update -qq
apt-get install -y -qq -o "Dpkg::Use-Pty=0" fish >/dev/null

# deb_file=$(ls -1 /tmp/download/docker-ce*.deb | sort | tail -n 1)
# [[ -f $deb_file ]] && echo "==> Install $deb_file" && apt-get install -y -qq -o "Dpkg::Use-Pty=0" $deb_file >/dev/null
# curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
# echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
