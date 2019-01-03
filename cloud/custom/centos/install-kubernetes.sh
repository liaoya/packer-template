#!/bin/bash -eux

[[ -n ${CUSTOM_KUBERNETES} && "${CUSTOM_KUBERNETES}" == "true" ]] || exit 0
echo "==> Install CentOS Kubernetes packages"

cat <<EOF > /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

cat <<'EOF' > /etc/yum.repos.d/kubernetes.repo

[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-$basearch
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF

yum -y install kubeadm kubelet kubectl

JQ_VERSION=$(curl --silent "https://api.github.com/repos/stedolan/jq/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
JQ_VERSION=${JQ_VERSION:-jq-1.6}
curl -sL "https://github.com/stedolan/jq/releases/download/${JQ_VERSION}/jq-linux64" -o jq
chmod a+x jq
[[ $(command -v strip) ]] && strip jq
mv jq /usr/local/bin/

KUBEVAL_VERSION=$(curl --silent "https://api.github.com/repos/garethr/kubeval/releases/latest" | jq .tag_name | sed 's/"//g')
KUBEVAL_VERSION=${KUBEVAL_VERSION:-0.7.3}
curl -sLO "https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz"
tar -xf kubeval-linux-amd64.tar.gz
chmod a+x kubeval
[[ $(command -v strip) ]] && strip kubeval
mv kubeval /usr/local/bin
chown "root:root" /usr/local/bin/kubeval

YQ_VERSION=$(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
YQ_VERSION=${YQ_VERSION:-2.2.0}
curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o yq
chmod a+x yq
[[ $(command -v strip) ]] && strip yq
mv yq /usr/local/bin
