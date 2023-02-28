# Debugging Crashed API Server Exercises

This repo contains six crashed API server scenarios that you may encounter when seating for CKA or CKS exams. Knowing how to solve an issue with the API server not coming up can save a question in these exams, since it may be something as straight forward as you have made an error when editing the manifest file. If you fail to recover a crashed API server it is very likely you'll lose all marks for the question!

The general technique for what you need to do is discussed on [this page](https://github.com/kodekloudhub/community-faq/blob/main/docs/diagnose-crashed-apiserver.md).

## Running the scenarios

1. Start a Kubernetes playground
1. Clone this repo

    ```
    git clone https://github.com/kodekloudhub/cka-debugging-api-server.git
    ```

1. Run each scenario in turn, and solve them. Don't look at the setup scripts and solutions in the `scenarios` directory unless you are stuck! You can do them in any order.

    ```
    ./cka-debugging-api-server/setup.sh 1
    ```

    It may take up to a minute before the API server crashes.

    Now solve it!

    ```
    ./cka-debugging-api-server/setup.sh 2
    ```

    etc. through 3, 4 and 5 to

    ```
    ./cka-debugging-api-server/setup.sh 6
    ```
1. When you think you have completed a resolution, run the following to speed up reloading of API server, then check it's working.

    ```bash
    systemctl restart kubelet
    # Wait 10 seconds or so, then
    kubectl get pods -n kube-system
    ```

    If you fixed it, then pods will be listed. If you are still getting an error, redo the [debugging process](https://github.com/kodekloudhub/community-faq/blob/main/docs/diagnose-crashed-apiserver.md) until you have fixed it.