# Scenario 3

The API server is down! We can see this with

```
controlplane ~ ✖ kubectl get pods
The connection to the server controlplane:6443 was refused - did you specify the right host or port?
```

Let's fix that. You should be on the controlplane node for the cluster. If you are not (e.g. exam student node), SSH there first.

1. Restart the kubelet so that it immediately tries to start API server again. If it's been crashlooping for a while, you might wait several minutes between restart attempts.

    ```
    systemctl restart kubelet
    ```

2. Check kubelet logs for a possible reason. We will follow the log to see up to date

    ```
    journalctl -fu kubelet | grep apiserver
    ```

    <details>
    <summary>Output</summary>

    ```
    Feb 25 13:49:33 controlplane kubelet[20958]: E0225 13:49:33.524864   20958 file.go:187] "Could not process manifest file" err="/etc/kubernetes/manifests/kube-apiserver.yaml: couldn't parse as pod(no kind \"Pod\" is registered for version \"v2\" in scheme \"pkg/api/legacyscheme/scheme.go:30\"), please check config file" path="/etc/kubernetes/manifests/kube-apiserver.yaml"
    ```

    <details>
    <summary>Reveal solution</summary>

    We have the answer right here! The error is with the `apiVersion:`. Edit the manifest and fix.

    </details>


