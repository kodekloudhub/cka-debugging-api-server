#!/usr/bin/env bash

sed -ie 's/          cpu: 250m/        \tcpu: 250m/' /etc/kubernetes/manifests/kube-apiserver.yaml
