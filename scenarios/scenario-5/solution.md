# Scenario 5

This scenario has been configured with a favourite topic of CKS students - API server auditing!

Don't worry if you're only doing CKA here, we're still debugging the API server, not any kind of policy failure. How it works is this:

* There is an audit policy document created at `/etc/kubernetes/prod-audit.yaml`
* This needs to be volume-mounted inside the API server container at the same path `/etc/kubernetes/prod-audit.yaml` using a volume of type `File` and the appropriate volume mount
* The API server loads this file using the `--audit-policy-file` argument

So, on with the task!

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

1. Check kubelet logs for a possible reason. We will follow the log to see up to date messages

    ```
    journalctl -fu kubelet | grep apiserver
    ```

    ```
    Feb 26 13:41:02 controlplane kubelet[17057]: E0226 13:41:02.112981   17057 nestedpendingoperations.go:348] Operation for "{volumeName:kubernetes.io/host-path/5a5fb26ce98b248d1257ea78eeb44853-audit podName:5a5fb26ce98b248d1257ea78eeb44853 nodeName:}" failed. No retries permitted until 2023-02-26 13:42:06.112953147 -0500 EST m=+128.529171844 (durationBeforeRetry 1m4s). Error: MountVolume.SetUp failed for volume "audit" (UniqueName: "kubernetes.io/host-path/5a5fb26ce98b248d1257ea78eeb44853-audit") pod "kube-apiserver-controlplane" (UID: "5a5fb26ce98b248d1257ea78eeb44853") : hostPath type check failed: /etc/kubernetes/dev-audit.yaml is not a file
    ```

    <details>
    <summary>Reveal solution</summary>

    Here's an issue. It is telling us that `/etc/kubernetes/dev-audit.yaml` is not a file. HOLD ON! What file are we actually supposed to be mounting? See above.

    <details>
    <summary>Fix it</summary>

    Edit `/etc/kubernetes/manifests/kube-apiserver.yaml`

    Examine the `volumes` section. What are we trying to mount? Is it the correct file? Correct this.

    </details>
    </details>

1.  Wait for apiserver to restart.

        ```
        watch crictl ps
        ```

    Ah wait - it's still not starting!

    You may have seen it flash up and go again. That means there must be another issue! To find another issue, we restart the debugging process from the beginning.

1. Check kubelet logs for a possible reason. We will follow the log to see up to date messages

    ```
    journalctl -fu kubelet | grep apiserver
    ```

    ```
    Feb 26 14:33:58 controlplane kubelet[8382]: E0226 14:33:58.180882    8382 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"kube-apiserver\" with CrashLoopBackOff: \"back-off 1m20s restarting failed container=kube-apiserver pod=kube-apiserver-controlplane_kube-system(6c73a29b92cd90029304bc9ea2ae6330)\"" pod="kube-system/kube-apiserver-controlplane" podUID=6c73a29b92cd90029304bc9ea2ae6330
    ```

    This time we see it is in CrashLoop. So now we need to go look at the pod logs as we have in previous scenarios.

    Go to the correct directory beneath `/var/log/pods` as I've decribed how to do previously and examine the latest log.

    <details>
    <summary>Fix it</summary>

    The log is telling us that there's an error in the audit policy file `/etc/kubernetes/prod-audit.yaml`. Since API server is trying to load this every time the pod gets restarted, we only need to edit the policy file directly, and then the next time API server is started it will work.

    ```
    2023-02-27T00:40:12.30810451-05:00 stderr F E0227 05:40:12.307931       1 run.go:74] "command failed" err="loading audit policy file: failed decoding: yaml: line 7: found character that cannot start any token: from file /etc/kubernetes/prod-audit.yaml"
    ```

    We have a syntax issue with `/etc/kubernetes/prod-audit.yaml`

    ```
    vi /etc/kubernetes/prod-audit.yaml
    ```

    Turn on line numbers

    ```
    :set nu
    ```

    Go to line 7 and see that the issue is a pesky `TAB` character! Remove this and replace with spaces, then save the file.

    ```
    systemctl restart kubelet
    ```

    Wait for API server to come up

    ```
    watch crictl ps
    ```

    </details>

