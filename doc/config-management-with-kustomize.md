<style>
body {
  font-family: "Gentium Basic", Cardo , "Linux Libertine o", "Palatino Linotype", Cambria, serif;
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

# Configuration management with Kustomize
summary of §14.3 of 

#### Cloud Native Spring in Action
_WITH SPRING BOOT AND KUBERNETES_
_THOMAS VITALE_
©2023 by Manning Publications Co. All rights reserved.

## Purpose
- we need a tool that treats multiple k8s manifests as a single entity, and
- customize parts of the configuration depending on the deployment environment

## Features
- distinguishes among different environments via a layering approach
  - configurations that are the same for all environments are defined in a `base/` directory
  - configurations per environment are in an `overlays/{environment-name}/` directory
- It is based on standard k8s manifest yaml syntax
- It can be used with `kubectl` and `oc` commands, so no other tools need to be installed

## General steps to introduce kustomize
- compose related k8s manifests and handle them as a single unit within a `base/` directory, using a 
  - `kustumization.yml` to
    - declare k8s manifest files under `base/` as resources
    - declare base customizations these resources should be submitted to
    
- compose related k8s manifests and handle them as a single unit per environment within an 
  `overlays/{environment-name}/` directory
  - In these per environment overlays, you don't have to repeat everything, just the parts that will differ per
    environment
  - declare generators like a `configMapGenerator` that may use a property file as input as these usually have
    different values per environment
