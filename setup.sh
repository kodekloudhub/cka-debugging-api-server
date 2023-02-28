#!/usr/bin/env bash

# Perform restore if we have a backup, else make a backup
[ -f /etc/kubernetes/kube-apiserver.bak ] && cp /etc/kubernetes/kube-apiserver.bak /etc/kubernetes/manifests/kube-apiserver.yaml
[ ! -f /etc/kubernetes/kube-apiserver.bak ] && cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.bak

if [ "$1" = "" ]
then
    echo "Usage: setup <scenario>"
    echo
    echo "Where <scenario> is the number of the scenario to install"
    exit 1
fi

basedir=$(dirname "${BASH_SOURCE[0]}")

if [ ! -d "$basedir/scenarios/scenario-$1" ]
then
    echo "No scenario $1 found."
    exit 1
fi

if ! command -v yq > /dev/null
then
    # Install YQ for patching YAML if not present
    curl -LO https://github.com/mikefarah/yq/releases/download/v4.31.1/yq_linux_amd64
    mv yq_linux_amd64 /usr/local/bin
fi

echo "Setting up scenario $1 and crashing that API server!"

source $basedir/scenarios/scenario-$1/setup.sh

echo "Waiting for kubelet to see the change and API server to crash"

# Have seen behaviour where the kubelet does NOT replace the API server if the manifest is dodgy,
# so force a stop and restart
mv /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml
sleep 1
rm -f /etc/kubernetes/manifests/kube-apiserver.*
systemctl restart kubelet
while crictl ps | grep apiserver > /dev/null ; do sleep 0.25s ; done
mv /etc/kubernetes/kube-apiserver.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
kubectl get pods -n kube-system
echo
echo "The scene is set!"

