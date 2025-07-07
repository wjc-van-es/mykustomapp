<style>
body {
  font-family: Spectral, "Gentium Basic", Cardo , "Linux Libertine o", "Palatino Linotype", Cambria, serif;
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

# Minikube & kubectl re-install

## Context
For `@mint-22` we postponed a complete re-install, but `@willem-Latitude-5590` is one more behind, so here we are
going to test it again for this project.
Also, we have to check the version and update kubectl. I think this is done automatically with updates on `@mint-22`,
but we will check that.

## Resources
- [https://stackoverflow.com/questions/57821066/how-to-update-minikube-latest-version](https://stackoverflow.com/questions/57821066/how-to-update-minikube-latest-version)
  - its script is added as [../scripts/minikube-reinstall.sh](../scripts/minikube-reinstall.sh), which we are going
    to inspect and tweak first, as it is more than 4 years old.
- [https://github.com/wjc-van-es/cnsia/blob/main/doc/k8s-minikube.md](https://github.com/wjc-van-es/cnsia/blob/main/doc/k8s-minikube.md)
- [https://github.com/wjc-van-es/quia/blob/main/docs/%C2%A711.3-kubectl_%26_minikube-install.md](https://github.com/wjc-van-es/quia/blob/main/docs/%C2%A711.3-kubectl_%26_minikube-install.md)
- [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

## First update kubectl
- Found a script at 
  [https://gist.github.com/QaiserAli/18926b5bd9ca7a0551195d449bf31eb6](https://gist.github.com/QaiserAli/18926b5bd9ca7a0551195d449bf31eb6)
- copied it into [../scripts/update-kubectl.sh](../scripts/update-kubectl.sh)
- `~/git/mykustomapp/scripts$ chmod +x *`
- `~/git/mykustomapp/scripts$ ./update-kubectl.sh` did not change the _Client Version: v1.31.0, Kustomize Version: v5.4.2_
- checking with 
  [https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
  reveals a different URL for downloading the new version, we updated
  [../scripts/update-kubectl.sh](../scripts/update-kubectl.sh) with that
- rerunning the script now reveals _Client Version: v1.33.2, Kustomize Version: v5.6.0_

## Inspect and update [../scripts/minikube-reinstall.sh](../scripts/minikube-reinstall.sh)
- with info from 
  [https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download](https://minikube.sigs.k8s.io/docs/start/?arch=%2Flinux%2Fx86-64%2Fstable%2Fbinary+download)
- we adapted the [../scripts/minikube-reinstall.sh](../scripts/minikube-reinstall.sh) in particular the URL to download
  the binary from

## Delete and Reinstall
- run the script `~/git/mykustomapp/scripts$ ./minikube-reinstall.sh`
- `~/git/mykustomapp$ minikube start -p kustomize` get complaints that the cluster with profile kustomize is not 
  compatible with the current (upgraded) minikube version 1.33.2 vs 1.31.0
- we remove the old cluster and recreate it
  - `minikube delete -p kustomize`
  - `minikube start --cpus 2 --memory 4g --driver docker -p kustomize`

## Set up the kustomize profile cluster with the right image
- check pulled images `minikube -p kustomize image ls`
- pull the docker image for the kustomize tutorial `minikube image pull devopsjourney1/mywebapp:latest -p kustomize`

## Check both the `dev` and `prod` overlays
- `~/git/mykustomapp$ kubectl kustomize work-02/overlays/dev > work-02/overlays/dev/gen.yaml`
- `~/git/mykustomapp$ kubectl kustomize work-02/overlays/prod > work-02/overlays/prod/gen.yaml`

## Set up the `dev` and the `prod` namespace
- `kubectl create namespace dev`
- `kubectl create namespace prod`
- check with `kubectl get namespaces`

## Apply the `dev` and `prod` overlays
- `~/git/mykustomapp$ kubectl apply -k work-02/overlays/dev`
- `~/git/mykustomapp$ kubectl apply -k work-02/overlays/prod`
- check all artefacts with label `app=mywebapp` on all namespaces (currently default & dev) with
  - `kubectl get all -l app=mywebapp --all-namespaces`
- open the homepages in a browser with
  - `minikube service kustom-mywebapp-v1 -n dev -p kustomize`
  - `minikube service kustom-mywebapp-v1 -n prod -p kustomize`
- Run `minikube -p kustomize addons enable metrics-server` to enable all dashboard features
- Open the dashboard `~/git/mykustomapp$ minikube dashboard -p kustomize`

## Problem with `dev` namespace
- As we added the `IDENTIFICATION_JSON` env var in `work-02/base/deployment.yaml` pointing to configMapRef 
  `bos-herken-tbg-rfh2-xml`, which was added to `work-02/overlays/prod/kustomization.yaml`, but not yet to
  `work-02/overlays/dev/kustomization.yaml` the pods in the `dev` namespace failed.
- We added the changes made to `work-02/overlays/prod/kustomization.yaml` to `work-02/overlays/dev/kustomization.yaml`
  as well and reran
  - `~/git/mykustomapp$ kubectl kustomize work-02/overlays/dev > work-02/overlays/dev/gen.yaml` and
  - `~/git/mykustomapp$ kubectl apply -k work-02/overlays/prod`
- Now we could see everything was running fine with 
  - the dashboard
  - `kubectl get all -l app=mywebapp --all-namespaces` and
  - opening the dev homepage with `minikube service kustom-mywebapp-v1 -n dev -p kustomize`

## Check that the environment variable is visible in an interactive pod shell session
- we can now select a `dev` namespace pod from `kubectl get all -l app=mywebapp --all-namespaces` as well:
- `~/git/mykustomapp$ kubectl -n dev exec --stdin --tty kustom-mywebapp-v1-7766596489-k84rv -- sh`
  - then 
    ```bash
    /code # printenv IDENTIFICATION_JSON
    {
      "K102_WHK": {
        "berichtStroom": "LH",
        "berichtSoort": "K102_WHK",
        "berichtVersie": "1"
      }
    }
    /code #
    ```
- end interactive session with Ctrl-D
- stop kustomize profile cluster with `~/git/mykustomapp$ minikube -p kustomize stop`
