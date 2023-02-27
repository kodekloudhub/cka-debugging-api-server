#!/usr/bin/env bash

yq -i e 'del (.spec.containers[].command[] | select (. == "--cert-file=/etc/kubernetes/pki/etcd/server.crt"))' /etc/kubernetes/manifests/etcd.yaml
yq -i e '.spec.containers[0].command += ["--cert-file=/etc/kubernetes/pki/etcd/etcd-server.crt"]' /etc/kubernetes/manifests/etcd.yaml
