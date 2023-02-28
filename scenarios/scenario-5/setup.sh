#!/usr/bin/env bash

# todo - update for tab in policy

mkdir -p /etc/kubernetes/audit

cat <<EOF > /etc/kubernetes/prod-audit.yaml
apiVersion: audit.k8s.io/v1
kind: Policy
rules:
- level: Metadata
  namespaces: ["prod"]
  verbs: ["delete"]
	resources:
  - group: ""
    resources: ["secrets"]
EOF

yq -i e '.spec.containers[0].command += [
    "--audit-policy-file=/etc/kubernetes/prod-audit.yaml",
    "--audit-log-path=/var/log/prod-secrets.log",
    "--audit-log-maxsize=100"
    ] |
    .spec.volumes += {"name": "audit", "hostPath":{"path":"/etc/kubernetes/dev-audit.yaml", "type":"File"}} |
    .spec.volumes += {"name": "audit-log", "hostPath":{"path":"/var/log/prod-secrets.log", "type":"FileOrCreate"}} |
    .spec.containers[0].volumeMounts += {"mountPath": "/etc/kubernetes/prod-audit.yaml", "name": "audit", "readOnly": true } |
    .spec.containers[0].volumeMounts += {"mountPath": "/var/log/prod-secrets.log", "name": "audit-log"}' \
    /etc/kubernetes/manifests/kube-apiserver.yaml

echo
echo "Hint"
echo "This scenario is configuring APi server auditing. This involves:"
echo
echo "* A file /etc/kubernetes/prod-audit.yaml has been created."
echo "* This file should be correctly mounted as a volume by API server."
echo "* The file is read by api server argument --audit-policy-file."
echo
echo "If you are a CKA student, you don't need to know the details of"
echo "auditing to solve this challenge."
echo
