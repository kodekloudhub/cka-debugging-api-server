#!/usr/bin/env bash

yq -i e '.spec.containers[0].command += ["--this-is-an-invalid-argument"]' /etc/kubernetes/manifests/kube-apiserver.yaml
