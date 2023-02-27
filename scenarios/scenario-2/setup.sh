#!/usr/bin/env bash

yq -i e 'del (.spec.containers[].command[] | select (. == "--client-ca-file=/etc/kubernetes/pki/ca.crt"))' /etc/kubernetes/manifests/kube-apiserver.yaml
yq -i e '.spec.containers[0].command += ["--client-ca-file=/etc/kubernetes/pki/ca-authority.crt"]' /etc/kubernetes/manifests/kube-apiserver.yaml
