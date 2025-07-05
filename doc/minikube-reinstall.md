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

## Inspect [../scripts/minikube-reinstall.sh](../scripts/minikube-reinstall.sh)

