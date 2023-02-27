# Scenario 1

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
    Feb 25 13:07:34 controlplane kubelet[6863]: E0225 13:07:34.910485    6863 pod_workers.go:951] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"kube-apiserver\" with CrashLoopBackOff: \"back-off 2m40s restarting failed container=kube-apiserver `pod=kube-apiserver-controlplane_kube-system(004eb3c7cd62ee9dce99d08300c5fd5a)\"" pod="kube-system/kube-apiserver-controlplane" podUID=004eb3c7cd62ee9dce99d08300c5fd5a
    ```

    This is telling us that the pod is crashlooping. This means it starts, and immediately dies.

3. Now check the pod logs

    ```
    cd /var/log/pods
    ls -ld *apiserver*
    ```

    This should return something like

    ```
    drwxr-xr-x 3 root root 4096 Oct 26 04:29 kube-system_kube-apiserver-controlplane_02d13ddeddf8e935ec2407132767aeaa
    ```

    If there's more than one match, choose the one with the most recent timestamp.

    **NOTE**: This directory can change name frequently. If you have to repeat the diagnostic process, don't assume it is the same as last time you did this in the same session. Repeat this step from the top.

    Next, `cd` into the given directory

    ```
    cd kube-system_kube-apiserver-controlplane_02d13ddeddf8e935ec2407132767aeaa
    ls -l
    ```

    You should see

    ```
    drwxr-xr-x 2 root root 4096 Oct 26 04:29 kube-apiserver
    ```

    ```
    cd kube-api-server
    ls -l
    ```

    There will be one or more `.log` files. Examine the content of the most recent log, e.g.

    ```
    cat 1.log
    ```

    The answer is revealed in the log message:

    <details>
    <summary>Reveal log message and solution</summary>

    ```
    2023-02-25T13:13:33.299383568Z stderr F Error: unknown flag: --this-is-an-invalid-argument
    ```

    Now edit the API server manifest and remove this invalid argument.

    This could also be a typo in a real argument you had added/edited as part of an exam question, in which case you'd simply correct the agurment name.

    </details>
