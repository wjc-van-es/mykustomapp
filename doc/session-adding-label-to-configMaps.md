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

# Adding label to overlay namespace configMaps

## Context
- It appears that the default customizations in [`base/kustomization.yaml`](../work-02/base/kustomization.yaml) are not
  inherited in the overlays/{environment-namespace-name} as far as the generated configMap is concerned.
- specifically
  - `commonLabels`
  - `commonAnnotations`
  - `namePrefix`
  - `nameSuffix`
- It should be noted that these customizations are indeed inherited for the static resources
  - [`work-02/base/deployment.yaml`](../work-02/base/deployment.yaml) and
  - [`work-02/base/service.yaml`](../work-02/base/service.yaml)
- Thus, the deployment and the service have the base label and name-prefix and suffix in both 
  - [`work-02/overlays/dev/gen.yaml`](../work-02/overlays/dev/gen.yaml) and
  - [`work-02/overlays/prod/gen.yaml`](../work-02/overlays/prod/gen.yaml)
- The configMap entries, however, have not

## Adding the `app=mywebapp` label to the generated configMaps in both the `dev` and `prod` overlays / namespaces
- We add
  ```yaml
  options:
    labels:
      app: mywebapp
  ```
  to the `configMapGenerator` in both
  - [work-02/overlays/dev/kustomization.yaml](../work-02/overlays/dev/kustomization.yaml) and
  - [work-02/overlays/prod/kustomization.yaml](../work-02/overlays/prod/kustomization.yaml)
- `~/git/mykustomapp$ kubectl kustomize work-02/overlays/dev > work-02/overlays/dev/gen.yaml`
- `~/git/mykustomapp$ kubectl kustomize work-02/overlays/prod > work-02/overlays/prod/gen.yaml`
- `~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces` does not contain `dev` or `prod` items
- `~/git/mykustomapp$ kubectl apply -k work-02/overlays/dev`
- `~/git/mykustomapp$ kubectl apply -k work-02/overlays/prod`
- `~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces` now contains both a `dev` and `prod` item
- To display the details of the configMap:
  - `kubectl describe configmap mykustom-map-9486f9m9dh -n dev` 
    - the name of the configmap retrieved from the output of the previous command and 
    - do not forget to specify the corresponding namespace `-n dev`
  

<details>

```bash
(base) willem@mint-22:~/git/mykustomapp$ kubectl get all -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                      READY   STATUS    RESTARTS        AGE
default     pod/kustom-mywebapp-v1-f875df8b-d8h2c     1/1     Running   3 (3d22h ago)   5d10h
dev         pod/kustom-mywebapp-v1-67889f7d79-wrvjc   1/1     Running   3 (3d22h ago)   5d
dev         pod/kustom-mywebapp-v1-67889f7d79-wsms6   1/1     Running   3 (3d22h ago)   5d
prod        pod/kustom-mywebapp-v1-5df468f984-4cc97   1/1     Running   2 (3d22h ago)   4d10h
prod        pod/kustom-mywebapp-v1-5df468f984-4tb6p   1/1     Running   2 (3d22h ago)   4d10h
prod        pod/kustom-mywebapp-v1-5df468f984-mtq7q   1/1     Running   2 (3d22h ago)   4d10h

NAMESPACE   NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
default     service/kustom-mywebapp-v1   LoadBalancer   10.98.186.162   <pending>     80:31683/TCP   5d10h
dev         service/kustom-mywebapp-v1   LoadBalancer   10.105.206.96   <pending>     80:31425/TCP   5d
prod        service/kustom-mywebapp-v1   LoadBalancer   10.101.99.212   <pending>     80:32523/TCP   4d10h

NAMESPACE   NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
default     deployment.apps/kustom-mywebapp-v1   1/1     1            1           5d10h
dev         deployment.apps/kustom-mywebapp-v1   2/2     2            2           5d
prod        deployment.apps/kustom-mywebapp-v1   3/3     3            3           4d10h

NAMESPACE   NAME                                            DESIRED   CURRENT   READY   AGE
default     replicaset.apps/kustom-mywebapp-v1-59565b8f7c   0         0         0       5d10h
default     replicaset.apps/kustom-mywebapp-v1-f875df8b     1         1         1       5d10h
dev         replicaset.apps/kustom-mywebapp-v1-67889f7d79   2         2         2       5d
prod        replicaset.apps/kustom-mywebapp-v1-5df468f984   3         3         3       4d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl apply -k work-02/overlays/dev
# Warning: 'bases' is deprecated. Please use 'resources' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
# Warning: 'commonLabels' is deprecated. Please use 'labels' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
configmap/mykustom-map-9486f9m9dh configured
service/kustom-mywebapp-v1 unchanged
deployment.apps/kustom-mywebapp-v1 unchanged
(base) willem@mint-22:~/git/mykustomapp$ kubectl get all -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                      READY   STATUS    RESTARTS        AGE
default     pod/kustom-mywebapp-v1-f875df8b-d8h2c     1/1     Running   3 (3d22h ago)   5d10h
dev         pod/kustom-mywebapp-v1-67889f7d79-wrvjc   1/1     Running   3 (3d22h ago)   5d
dev         pod/kustom-mywebapp-v1-67889f7d79-wsms6   1/1     Running   3 (3d22h ago)   5d
prod        pod/kustom-mywebapp-v1-5df468f984-4cc97   1/1     Running   2 (3d22h ago)   4d10h
prod        pod/kustom-mywebapp-v1-5df468f984-4tb6p   1/1     Running   2 (3d22h ago)   4d10h
prod        pod/kustom-mywebapp-v1-5df468f984-mtq7q   1/1     Running   2 (3d22h ago)   4d10h

NAMESPACE   NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
default     service/kustom-mywebapp-v1   LoadBalancer   10.98.186.162   <pending>     80:31683/TCP   5d10h
dev         service/kustom-mywebapp-v1   LoadBalancer   10.105.206.96   <pending>     80:31425/TCP   5d
prod        service/kustom-mywebapp-v1   LoadBalancer   10.101.99.212   <pending>     80:32523/TCP   4d10h

NAMESPACE   NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
default     deployment.apps/kustom-mywebapp-v1   1/1     1            1           5d10h
dev         deployment.apps/kustom-mywebapp-v1   2/2     2            2           5d
prod        deployment.apps/kustom-mywebapp-v1   3/3     3            3           4d10h

NAMESPACE   NAME                                            DESIRED   CURRENT   READY   AGE
default     replicaset.apps/kustom-mywebapp-v1-59565b8f7c   0         0         0       5d10h
default     replicaset.apps/kustom-mywebapp-v1-f875df8b     1         1         1       5d10h
dev         replicaset.apps/kustom-mywebapp-v1-67889f7d79   2         2         2       5d
prod        replicaset.apps/kustom-mywebapp-v1-5df468f984   3         3         3       4d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps
NAME                                DATA   AGE
kube-root-ca.crt                    1      6d7h
kustom-mykustom-map-v1-bht92hd6gm   3      5d10h
kustom-mykustom-map-v1-k98kg64km2   3      5d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                DATA   AGE
default     kustom-mykustom-map-v1-bht92hd6gm   3      5d10h
default     kustom-mykustom-map-v1-k98kg64km2   3      5d10h
dev         mykustom-map-9486f9m9dh             3      5d
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps  --all-namespaces
NAMESPACE              NAME                                                   DATA   AGE
default                kube-root-ca.crt                                       1      6d7h
default                kustom-mykustom-map-v1-bht92hd6gm                      3      5d10h
default                kustom-mykustom-map-v1-k98kg64km2                      3      5d10h
dev                    kube-root-ca.crt                                       1      5d
dev                    mykustom-map-9486f9m9dh                                3      5d
kube-node-lease        kube-root-ca.crt                                       1      6d7h
kube-public            cluster-info                                           1      6d7h
kube-public            kube-root-ca.crt                                       1      6d7h
kube-system            coredns                                                1      6d7h
kube-system            extension-apiserver-authentication                     6      6d7h
kube-system            kube-apiserver-legacy-service-account-token-tracking   1      6d7h
kube-system            kube-proxy                                             2      6d7h
kube-system            kube-root-ca.crt                                       1      6d7h
kube-system            kubeadm-config                                         1      6d7h
kube-system            kubelet-config                                         1      6d7h
kubernetes-dashboard   kube-root-ca.crt                                       1      6d7h
kubernetes-dashboard   kubernetes-dashboard-settings                          0      6d7h
prod                   kube-root-ca.crt                                       1      5d
prod                   mykustom-map-kcc8f98gcc                                3      4d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl apply -k work-02/overlays/prod
# Warning: 'bases' is deprecated. Please use 'resources' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
# Warning: 'commonLabels' is deprecated. Please use 'labels' instead. Run 'kustomize edit fix' to update your Kustomization automatically.
configmap/mykustom-map-kcc8f98gcc configured
service/kustom-mywebapp-v1 unchanged
deployment.apps/kustom-mywebapp-v1 unchanged
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                DATA   AGE
default     kustom-mykustom-map-v1-bht92hd6gm   3      5d10h
default     kustom-mykustom-map-v1-k98kg64km2   3      5d10h
dev         mykustom-map-9486f9m9dh             3      5d
prod        mykustom-map-kcc8f98gcc             3      4d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl get all -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                      READY   STATUS    RESTARTS        AGE
default     pod/kustom-mywebapp-v1-f875df8b-d8h2c     1/1     Running   3 (3d22h ago)   5d10h
dev         pod/kustom-mywebapp-v1-67889f7d79-wrvjc   1/1     Running   3 (3d22h ago)   5d
dev         pod/kustom-mywebapp-v1-67889f7d79-wsms6   1/1     Running   3 (3d22h ago)   5d
prod        pod/kustom-mywebapp-v1-5df468f984-4cc97   1/1     Running   2 (3d22h ago)   4d10h
prod        pod/kustom-mywebapp-v1-5df468f984-4tb6p   1/1     Running   2 (3d22h ago)   4d10h
prod        pod/kustom-mywebapp-v1-5df468f984-mtq7q   1/1     Running   2 (3d22h ago)   4d10h

NAMESPACE   NAME                         TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
default     service/kustom-mywebapp-v1   LoadBalancer   10.98.186.162   <pending>     80:31683/TCP   5d10h
dev         service/kustom-mywebapp-v1   LoadBalancer   10.105.206.96   <pending>     80:31425/TCP   5d
prod        service/kustom-mywebapp-v1   LoadBalancer   10.101.99.212   <pending>     80:32523/TCP   4d10h

NAMESPACE   NAME                                 READY   UP-TO-DATE   AVAILABLE   AGE
default     deployment.apps/kustom-mywebapp-v1   1/1     1            1           5d10h
dev         deployment.apps/kustom-mywebapp-v1   2/2     2            2           5d
prod        deployment.apps/kustom-mywebapp-v1   3/3     3            3           4d10h

NAMESPACE   NAME                                            DESIRED   CURRENT   READY   AGE
default     replicaset.apps/kustom-mywebapp-v1-59565b8f7c   0         0         0       5d10h
default     replicaset.apps/kustom-mywebapp-v1-f875df8b     1         1         1       5d10h
dev         replicaset.apps/kustom-mywebapp-v1-67889f7d79   2         2         2       5d
prod        replicaset.apps/kustom-mywebapp-v1-5df468f984   3         3         3       4d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl get configmaps -l app=mywebapp --all-namespaces
NAMESPACE   NAME                                DATA   AGE
default     kustom-mykustom-map-v1-bht92hd6gm   3      5d10h
default     kustom-mykustom-map-v1-k98kg64km2   3      5d10h
dev         mykustom-map-9486f9m9dh             3      5d
prod        mykustom-map-kcc8f98gcc             3      4d10h
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap mykustom-map-9486f9m9dh 
Error from server (NotFound): configmaps "mykustom-map-9486f9m9dh" not found
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap mykustom-map-9486f9m9dh -all-namespaces
error: unknown shorthand flag: 'a' in -all-namespaces
See 'kubectl describe --help' for usage.
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap mykustom-map-9486f9m9dh --all-namespaces
error: a resource cannot be retrieved by name across all namespaces
(base) willem@mint-22:~/git/mykustomapp$ kubectl describe configmap mykustom-map-9486f9m9dh -n dev
Name:         mykustom-map-9486f9m9dh
Namespace:    dev
Labels:       app=mywebapp
Annotations:  <none>

Data
====
BG_COLOR:
----
#519162

CUSTOM_HEADER:
----
welcome to the kustomized DEV environment

FONT_COLOR:
----
#FFFFFF


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
(base) willem@mint-22:~/git/mykustomapp$ 

```

</details>