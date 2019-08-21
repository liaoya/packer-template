#!/bin/bash

[[ -n ${CUSTOM_MINIKUBE} && "${CUSTOM_MINIKUBE^^}" == "TRUE" ]] || exit 0

if [[ ! $(command -v minikube) ]]; then
    MINIKUBE_VERSION=$(curl -sL "https://api.github.com/repos/kubernetes/minikube/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    MINIKUBE_VERSION=${MINIKUBE_VERSION:-1.3.1}
    curl -sLo minikube "https://storage.googleapis.com/minikube/releases/${MINIKUBE_VERSION}/minikube-linux-amd64"
    chmod a+x minikube
    mv minikube /usr/local/bin
fi

if [[ ! $(command -v kubectl) ]]; then
    KUBECTL_VERSION=$(curl -sL https://storage.googleapis.com/kubernetes-release/release/stable.txt)
    KUBECTL_VERSION=${KUBECTL_VERSION:-v1.15.3}
    curl -sLO "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    chmod a+x kubectl
    mv kubectl /usr/local/bin
fi

if [[ ! $(command -v jq) ]]; then
    JQ_VERSION=$(curl -sL "https://api.github.com/repos/stedolan/jq/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    JQ_VERSION=${JQ_VERSION:-jq-1.6}
    curl -sL "https://github.com/stedolan/jq/releases/download/${JQ_VERSION}/jq-linux64" -o jq
    chmod a+x jq
    [[ $(command -v strip) ]] && strip jq
    mv jq /usr/local/bin/
fi

if [[ ! $(command -v kubeval) ]]; then
    KUBEVAL_VERSION=$(curl -sL "https://api.github.com/repos/instrumenta/kubeval/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    KUBEVAL_VERSION=${KUBEVAL_VERSION:0.13.0}
    curl -sLO "https://github.com/instrumenta/kubeval/releases/download/${KUBEVAL_VERSION}/kubeval-linux-amd64.tar.gz"
    tar -xf kubeval-linux-amd64.tar.gz
    chmod a+x kubeval
    [[ $(command -v strip) ]] && strip kubeval
    mv kubeval /usr/local/bin
    chown "root:root" /usr/local/bin/kubeval
    rm -f kubeval-linux-amd64.tar.gz
fi

if [[ ! $(command -v yq) ]]; then
    YQ_VERSION=$(curl -sL https://api.github.com/repos/mikefarah/yq/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    YQ_VERSION=${YQ_VERSION:-2.4.0}
    curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64" -o yq
    chmod a+x yq
    [[ $(command -v strip) ]] && strip yq
    mv yq /usr/local/bin
fi
