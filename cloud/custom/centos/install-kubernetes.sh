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

KUBEVAL_VERSION=$(curl --silent "https://api.github.com/repos/garethr/kubeval/releases/latest" | jq .tag_name | sed 's/"//g')
curl -sLO "https://github.com/garethr/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz"
tar -xf kubeval-linux-amd64.tar.gz
chmod a+x kubeval
mv kubeval /usr/local/bin
chown "root:root" /usr/local/bin/kubeval

YQ_VERSION=$(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o yq
chmod a+x yq
mv yq /usr/local/bin
