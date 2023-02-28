#!/usr/bin/env bash

sed -ie 's/        cpu:/\t\t\t\tcpu:/' /etc/kubernetes/manifests/kube-apiserver.yaml
