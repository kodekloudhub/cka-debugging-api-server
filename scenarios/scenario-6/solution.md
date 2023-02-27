# Scenario 6


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
    Feb 27 02:27:23 controlplane kubelet[3682]: E0227 02:27:23.789925    3682 event.go:276] Unable to write event: '&v1.Event{TypeMeta:v1.TypeMeta{Kind:"", APIVersion:""}, <DETAIL SNIPPED>: 'Patch "https://controlplane:6443/api/v1/namespaces/kube-system/events/kube-apiserver-controlplane.17479b829cbdc3e0": dial tcp 10.0.241.8:6443: connect: connection refused'(may retry after sleeping)
    Feb 27 02:27:24 controlplane kubelet[3682]: I0227 02:27:24.133593    3682 status_manager.go:698] "Failed to get status for pod" podUID=b6aa5c51dfc5df190dc9524fdc59172b pod="kube-system/kube-apiserver-controlplane" err="Get \"https://controlplane:6443/api/v1/namespaces/kube-system/pods/kube-apiserver-controlplane\": dial tcp 10.0.241.8:6443: connect: connection refused"
    Feb 27 02:27:24 controlplane kubelet[3682]: E0227 02:27:24.133880    3682 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"kube-apiserver\" with CrashLoopBackOff: \"back-off 1m20s restarting failed container=kube-apiserver pod=kube-apiserver-controlplane_kube-system(b6aa5c51dfc5df190dc9524fdc59172b)\"" pod="kube-system/kube-apiserver-controlplane" podUID=b6aa5c51dfc5df190dc9524fdc59172b
    ```

    There's quite a lot of info here.

    * It can't write an event
    * It can't get the status for a pod
    * Then it crashes

    So API server probably _is_ working, but something it is talking to probably _isn't_ and that is destabilizing it.

    Which component does API server use to track the state of objects in the cluster?

    <details>
    <summary>Reveal</summary>

    > `etcd`

    </detials>

    Let's now examine what containers are actually running. Execute the following and observe it for up to 60 seconds

    ```
    watch crictl ps
    ```

    What have you observed?

    <details>
    <summary>Reveal</summary>

    * There is no evidence of a container for `etcd`
    * `kube-apiserver` is coming and going

    </details>

    <details>
    <summary>Let's fix this!</summary>

    We need to investigate `etcd`, so we apply exactly the same techniques as for debugging API server to etcd.

    ```
    systemctl restart kubelet
    journalctl -fu kubelet | grep etcd
    ```

    Observe in the output

    ```
    Feb 27 02:39:32 controlplane kubelet[3682]: E0227 02:39:32.386661    3682 pod_workers.go:965] "Error syncing pod, skipping" err="failed to \"StartContainer\" for \"etcd\" with CrashLoopBackOff: \"back-off 5m0s restarting failed container=etcd pod=etcd-controlplane_kube-system(6c2684cc7a64810709bc493a7a24a9c2)\"" pod="kube-system/etcd-controlplane" podUID=6c2684cc7a64810709bc493a7a24a9c2
    ```

    `etcd` is CrashLooping, best check the pod logs

    ```bash
    cd /var/log/pods
    ls -ld *etcd*
    ```

    Again, if there's more than one entry, choose the most recent

    ```bash
    cd kube-system_etcd-controlplane_6c2684cc7a64810709bc493a7a24a9c2/etcd
    ```

    View the most recent log file in this directory and notice

    ```
    2023-02-27T02:40:40.894734818-05:00 stderr F {"level":"fatal","ts":"2023-02-27T07:40:40.894Z","caller":"etcdmain/etcd.go:219","msg":"listener failed","error":"open /etc/kubernetes/pki/etcd/etcd-server.crt: no such file or directory","stacktrace":"go.etcd.io/etcd/server/v3/etcdmain.startEtcdOrProxyV2\n\tgo.etcd.io/etcd/server/v3/etcdmain/etcd.go:219\ngo.etcd.io/etcd/server/v3/etcdmain.Main\n\tgo.etcd.io/etcd/server/v3/etcdmain/main.go:40\nmain.main\n\tgo.etcd.io/etcd/server/v3/main.go:32\nruntime.main\n\truntime/proc.go:225"}
    ```

    Certificate filename error! This is just like [scenario 2](../scenario-2/solution.md), so we solve it the same way. This time edit `/etc/kubernetes/manifests/etcd.yaml` and correct the certificate filename.

    Now kick kubelet so we don't have to wait up to 5 min for containers to be restarted, then wait for everything to come back up

    ```
    systemctl restart kubelet
    watch crictl ps
    ```

    Once you can see both `etcd` and `kube-apiserver` in this list, service should be restored.

    ```
    kubectl get pods -A
    ```

    </details>
