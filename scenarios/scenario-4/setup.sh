#!/usr/bin/env bash

sed -ie 's/        cpu: 250m/\t\t\t\tcpu: 250m/' /etc/kubernetes/manifests/kube-apiserver.yaml
