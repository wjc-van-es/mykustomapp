<style>
body {
  font-family: "Spectral", "Gentium Basic", Cardo , "Linux Libertine o", "Palatino Linotype", Cambria, serif;
  font-size: 100% !important;
  padding-right: 12%;
}
code {
  padding: 0.25em;
	
  white-space: pre;
  font-family: "Tlwg mono", Consolas, "Liberation Mono", Menlo, Courier, monospace;
	
  background-color: #ECFFFA;
  //border: 1px solid #ccc;
  //border-radius: 3px;
}

kbd {
  display: inline-block;
  padding: 3px 5px;
  font-family: "Tlwg mono", Consolas, "Liberation Mono", Menlo, Courier, monospace;
  line-height: 10px;
  color: #555;
  vertical-align: middle;
  background-color: #ECFFFA;
  border: solid 1px #ccc;
  border-bottom-color: #bbb;
  border-radius: 3px;
  box-shadow: inset 0 -1px 0 #bbb;
}

h1,h2,h3,h4,h5 {
  color: #269B7D; 
  font-family: "fira sans", "Latin Modern Sans", Calibri, "Trebuchet MS", sans-serif;
}

</style>

# Adding the content of a file `identification.json` to a configMap

## Resources
- [https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/](https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/)
- [https://www.perplexity.ai/search/in-a-kubernetes-configmap-i-ha-1PcSxBkrS0yGoHwM4xdxoQ](https://www.perplexity.ai/search/in-a-kubernetes-configmap-i-ha-1PcSxBkrS0yGoHwM4xdxoQ)
- 

## Context
- Starting minikube: `~/git/mykustomapp$ minikube start -p kustomize`
- We added the content of [`work-02/overlays/prod/identification.json`](../work-02/overlays/prod/identification.json)
- and added this entry under the `configMapGenerator` of 
  [`work-02/overlays/prod/kustomization.yaml`](../work-02/overlays/prod/kustomization.yaml)
  ```yaml
  - name: bos-herken-tbg-rfh2-xml
    files:
      - identification.json
    options:
      labels:
        app: mywebapp
  ```
- Now `~/git/mykustomapp$ kubectl kustomize work-02/overlays/prod > work-02/overlays/prod/gen.yaml` yield
  [`work-02/overlays/prod/gen.yaml`](../work-02/overlays/prod/gen.yaml) with the configMap:
  ```yaml
  apiVersion: v1
  data:
    identification.json: |-
      {
        "origin": {
          "berichtStroom": "UWV_GLV_IN_S",
          "berichtSoort": "GLVIV",
          "berichtVersie": "1"
        }
      }
  kind: ConfigMap
  metadata:
    labels:
      app: mywebapp
    name: bos-herken-tbg-rfh2-xml-6644946d2d
    namespace: prod
  ---
  ```
  
- This result cannot really be accessed as an environment variable and not as a file either without a proper volume
  mount.
- adding the configMap to the running minikube cluster (with the `kustomize` profile):
  `~/git/mykustomapp$ kubectl apply -k work-02/overlays/prod`
- starting an interactive shell session within a running pod
  - `~/git/mykustomapp$ kubectl get all -l app=mywebapp --all-namespaces` reveals two pods on `-n prod`
  - `~/git/mykustomapp$ kubectl -n prod get pod kustom-mywebapp-v1-5df468f984-mtq7q` zooms in on one of them
  - `~/git/mykustomapp$ kubectl -n prod exec --stdin --tty kustom-mywebapp-v1-5df468f984-mtq7q -- sh` opens an 
    interactive shell
  - `printenv` reveals all available environment variables
 - Ctrl-D terminates the session


<details>

```bash
willem@mint-22:~/git/mykustomapp$ minikube start -p kustomize
😄  [kustomize] minikube v1.35.0 on Linuxmint 22
✨  Using the docker driver based on existing profile
🎉  minikube 1.36.0 is available! Download it: https://github.com/kubernetes/minikube/releases/tag/v1.36.0
💡  To disable this notice, run: 'minikube config set WantUpdateNotification false'

👍  Starting "kustomize" primary control-plane node in "kustomize" cluster
🚜  Pulling base image v0.0.46 ...
🔄  Restarting existing docker container for "kustomize" ...
🐳  Preparing Kubernetes v1.32.0 on Docker 27.4.1 ...
🔎  Verifying Kubernetes components...
    ▪ Using image docker.io/kubernetesui/dashboard:v2.7.0
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
    ▪ Using image docker.io/kubernetesui/metrics-scraper:v1.0.8
💡  Some dashboard features require the metrics-server addon. To enable all features please run:

        minikube -p kustomize addons enable metrics-server

🌟  Enabled addons: default-storageclass, storage-provisioner, dashboard
🏄  Done! kubectl is now configured to use "kustomize" cluster and "default" namespace by default
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                DATA   AGE
default     kustom-mykustom-map-v1-bht92hd6gm   3      25d
default     kustom-mykustom-map-v1-k98kg64km2   3      25d
dev         mykustom-map-9486f9m9dh             3      25d
prod        mykustom-map-kcc8f98gcc             3      24d
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap -n prod mykustom-map-kcc8f98gcc
Name:         mykustom-map-kcc8f98gcc
Namespace:    prod
Labels:       app=mywebapp
Annotations:  <none>

Data
====
FONT_COLOR:
----
#FFFFFF

BG_COLOR:
----
#961212

CUSTOM_HEADER:
----
welcome to the kustomized PROD environment


BinaryData
====

Events:  <none>
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap -n prod mykustom-map-kcc8f98gcc
Name:         mykustom-map-kcc8f98gcc
Namespace:    prod
Labels:       app=mywebapp
Annotations:  <none>

Data
====
BG_COLOR:
----
#961212

CUSTOM_HEADER:
----
welcome to the kustomized PROD environment

FONT_COLOR:
----
#FFFFFF


BinaryData
====

Events:  <none>
(base) willem@mint-22:~/git/mykustomapp$ kubectl apply -k work-02/overlays/prod
# Warning: 'bases' is deprecated. Please use 'resources' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
# Warning: 'commonLabels' is deprecated. Please use 'labels' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
configmap/bos-herken-tbg-rfh2-xml-6644946d2d created
configmap/mykustom-map-kcc8f98gcc unchanged
service/kustom-mywebapp-v1 unchanged
deployment.apps/kustom-mywebapp-v1 unchanged
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                 DATA   AGE
default     kustom-mykustom-map-v1-bht92hd6gm    3      25d
default     kustom-mykustom-map-v1-k98kg64km2    3      25d
dev         mykustom-map-9486f9m9dh              3      25d
prod        bos-herken-tbg-rfh2-xml-6644946d2d   1      28s
prod        mykustom-map-kcc8f98gcc              3      24d
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap -n prod bos-herken-tbg-rfh2-xml-6644946d2d
Name:         bos-herken-tbg-rfh2-xml-6644946d2d
Namespace:    prod
Labels:       app=mywebapp
Annotations:  <none>

Data
====
identification.json:
----
{
  "origin": {
    "berichtStroom": "UWV_GLV_IN_S",
    "berichtSoort": "GLVIV",
    "berichtVersie": "1"
  }
}


BinaryData
====

Events:  <none>
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps  --all-namespaces
NAMESPACE              NAME                                                   DATA   AGE
default                kube-root-ca.crt                                       1      26d
default                kustom-mykustom-map-v1-bht92hd6gm                      3      25d
default                kustom-mykustom-map-v1-k98kg64km2                      3      25d
dev                    kube-root-ca.crt                                       1      25d
dev                    mykustom-map-9486f9m9dh                                3      25d
kube-node-lease        kube-root-ca.crt                                       1      26d
kube-public            cluster-info                                           1      26d
kube-public            kube-root-ca.crt                                       1      26d
kube-system            coredns                                                1      26d
kube-system            extension-apiserver-authentication                     6      26d
kube-system            kube-apiserver-legacy-service-account-token-tracking   1      26d
kube-system            kube-proxy                                             2      26d
kube-system            kube-root-ca.crt                                       1      26d
kube-system            kubeadm-config                                         1      26d
kube-system            kubelet-config                                         1      26d
kubernetes-dashboard   kube-root-ca.crt                                       1      26d
kubernetes-dashboard   kubernetes-dashboard-settings                          0      26d
prod                   bos-herken-tbg-rfh2-xml-6644946d2d                     1      41m
prod                   kube-root-ca.crt                                       1      25d
prod                   mykustom-map-kcc8f98gcc                                3      24d
(base) willem@mint-22:~/git/mykustomapp$ kubectl get all -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                      READY   STATUS    RESTARTS      AGE
default     pod/kustom-mywebapp-v1-f875df8b-d8h2c     1/1     Running   4 (19d ago)   25d
dev         pod/kustom-mywebapp-v1-67889f7d79-wrvjc   1/1     Running   4 (19d ago)   25d
dev         pod/kustom-mywebapp-v1-67889f7d79-wsms6   1/1     Running   4 (19d ago)   25d
prod        pod/kustom-mywebapp-v1-5df468f984-4cc97   1/1     Running   3 (19d ago)   24d
prod        pod/kustom-mywebapp-v1-5df468f984-4tb6p   1/1     Running   3 (19d ago)   24d
prod        pod/kustom-mywebapp-v1-5df468f984-mtq7q   1/1     Running   3 (19d ago)   24d

NAMESPACE   NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
default     service/kustom-mywebapp-v1   LoadBalancer   10.98.186.162   <pending>     80:31683/TCP   25d
dev         service/kustom-mywebapp-v1   LoadBalancer   10.105.206.96   <pending>     80:31425/TCP   25d
prod        service/kustom-mywebapp-v1   LoadBalancer   10.101.99.212   <pending>     80:32523/TCP   24d

NAMESPACE   NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
default     deployment.apps/kustom-mywebapp-v1   1/1     1            1           25d
dev         deployment.apps/kustom-mywebapp-v1   2/2     2            2           25d
prod        deployment.apps/kustom-mywebapp-v1   3/3     3            3           24d

NAMESPACE   NAME                                            DESIRED   CURRENT   READY   AGE
default     replicaset.apps/kustom-mywebapp-v1-59565b8f7c   0         0         0       25d
default     replicaset.apps/kustom-mywebapp-v1-f875df8b     1         1         1       25d
dev         replicaset.apps/kustom-mywebapp-v1-67889f7d79   2         2         2       25d
prod        replicaset.apps/kustom-mywebapp-v1-5df468f984   3         3         3       24d
(base) willem@mint-22:~/git/mykustomapp$ get pod kustom-mywebapp-v1-5df468f984-mtq7q
Command 'get' not found, but there are 18 similar ones.
(base) willem@mint-22:~/git/mykustomapp$ kubectl get pod kustom-mywebapp-v1-5df468f984-mtq7q
Error from server (NotFound): pods "kustom-mywebapp-v1-5df468f984-mtq7q" not found
(base) willem@mint-22:~/git/mykustomapp$ kubectl -n prod get pod kustom-mywebapp-v1-5df468f984-mtq7q
NAME                                  READY   STATUS    RESTARTS      AGE
kustom-mywebapp-v1-5df468f984-mtq7q   1/1     Running   3 (19d ago)   24d
(base) willem@mint-22:~/git/mykustomapp$ kubectl -n prod exec --stdin --tty kustom-mywebapp-v1-5df468f984-mtq7q -- /bin/bash
OCI runtime exec failed: exec failed: unable to start container process: exec: "/bin/bash": stat /bin/bash: no such file or directory: unknown
command terminated with exit code 126
(base) willem@mint-22:~/git/mykustomapp$ kubectl -n prod exec --stdin --tty kustom-mywebapp-v1-5df468f984-mtq7q 
error: you must specify at least one command for the container
(base) willem@mint-22:~/git/mykustomapp$ kubectl -n prod exec --stdin --tty kustom-mywebapp-v1-5df468f984-mtq7q -- sh
/code # pwd
/code
/code # ls -la
total 24
drwxr-xr-x    1 root     root          4096 Jun 30 20:26 .
drwxr-xr-x    1 root     root          4096 Jun 30 20:26 ..
-rwxr-xr-x    1 root     root           512 Aug 11  2022 Dockerfile
drwxr-xr-x    2 root     root          4096 Jun 30 20:26 __pycache__
-rwxr-xr-x    1 root     root           496 Aug 11  2022 app.py
-rwxr-xr-x    1 root     root             5 Aug 11  2022 requirements.txt
/code # cat requirements.txt 
Flask/code # printenv
CUSTOM_HEADER=welcome to the kustomized PROD environment
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
HOSTNAME=kustom-mywebapp-v1-5df468f984-mtq7q
KUSTOM_MYWEBAPP_V1_PORT_80_TCP_ADDR=10.101.99.212
PYTHON_PIP_VERSION=22.0.4
SHLVL=1
HOME=/root
KUSTOM_MYWEBAPP_V1_PORT_80_TCP_PORT=80
CUSTOM_PHOTO=https://raw.githubusercontent.com/devopsjourney1/assets/main/devops-journey-banner.png
KUSTOM_MYWEBAPP_V1_PORT_80_TCP_PROTO=tcp
GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
FLASK_APP=app.py
KUSTOM_MYWEBAPP_V1_PORT_80_TCP=tcp://10.101.99.212:80
PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/aeca83c7ba7f9cdfd681103c4dcbf0214f6d742e/public/get-pip.py
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
FLASK_RUN_HOST=0.0.0.0
PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
KUBERNETES_PORT_443_TCP_PROTO=tcp
LANG=C.UTF-8
FLASK_RUN_PORT=80
PYTHON_VERSION=3.7.13
PYTHON_SETUPTOOLS_VERSION=57.5.0
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUSTOM_MYWEBAPP_V1_SERVICE_HOST=10.101.99.212
KUBERNETES_SERVICE_PORT_HTTPS=443
BG_COLOR=#961212
KUBERNETES_SERVICE_HOST=10.96.0.1
PWD=/code
KUSTOM_MYWEBAPP_V1_SERVICE_PORT_FLASK=80
PYTHON_GET_PIP_SHA256=d0b5909f3ab32dae9d115aa68a4b763529823ad5589c56af15cf816fca2773d6
FONT_COLOR=#FFFFFF
KUSTOM_MYWEBAPP_V1_SERVICE_PORT=80
KUSTOM_MYWEBAPP_V1_PORT=tcp://10.101.99.212:80
/code # printenv identification.json
/code # 
command terminated with exit code 130
(base) willem@mint-22:~/git/mykustomapp$
```

</details>
