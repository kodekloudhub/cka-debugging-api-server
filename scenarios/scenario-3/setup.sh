#!/usr/bin/env bash

yq -i e '.apiVersion = "v2"' /etc/kubernetes/manifests/kube-apiserver.yaml
