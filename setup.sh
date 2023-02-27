#!/usr/bin/env bash

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
systemctl restart kubelet
while crictl ps | grep apiserver > /dev/null ; do sleep 0.25s ; done
kubectl get pods -n kube-system
echo
echo "The scene is set!"

