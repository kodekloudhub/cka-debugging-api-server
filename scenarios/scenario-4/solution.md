# Scenario 4

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

    ```
    Feb 25 14:16:02 controlplane kubelet[26952]: E0225 14:16:02.967711   26952 file.go:187] "Could not process manifest file" err="/etc/kubernetes/manifests/kube-apiserver.yaml: couldn't parse as pod(yaml: line 67: found character that cannot start any token), please check config file" path="/etc/kubernetes/manifests/kube-apiserver.yaml"
    ```

    <details>
    <summary>Reveal solution</summary>

    Again we have the answer right here!

    This is a favourite of students when editing any YAML! Clearly we have a YAML error, and it tells us near which line

    Edit the manifest in `vi` and turn on line numbers with the following vi command

    ```
    :set nu
    ```

    Now scroll down to the indicated line. Hmm, it _looks_ ok, but it isnt!

    Put the cursor at the beginning of the line and right arrow it towards the `cpu: 250m`. What do you notice?

    <details>
    <summary>Reveal issue</summary>

    Did you notice that the cursor jumps two spaces at one point? This is because there is a `TAB` character in there. YAML hates tabs! Edit the line to delete the tab and re-indent using spaces.
    </details>
    </details>


