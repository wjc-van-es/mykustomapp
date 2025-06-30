<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# In a kubernetes configMap I have:

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
How would I link the content of identification.json to a property in a Quarkus application.properties and have an alternative dev value for that property defined in a .env file

To link the `identification.json` content from a Kubernetes ConfigMap to a Quarkus property and provide a development alternative via a `.env` file, follow this approach:

### 1. **Enable Kubernetes Config Extension**

Add the `quarkus-kubernetes-config` extension to your project:

```bash  
./mvnw quarkus:add-extension -Dextensions="quarkus-kubernetes-config"
```

This allows Quarkus to read ConfigMaps as configuration sources[^1_1][^1_2][^1_4].

### 2. **Configure ConfigMap in `application.properties`**

Enable the extension and specify your ConfigMap for production:

```properties  
%prod.quarkus.kubernetes-config.enabled=true  
%prod.quarkus.kubernetes-config.config-maps=bos-herken-tbg-rfh2-xml-6644946d2d  
```

This maps the ConfigMap data to Quarkus properties[^1_1][^1_2][^1_4].

### 3. **Map JSON Content to a Property**

In your Quarkus application, access the JSON string directly:

```java  
@ConfigProperty(name = "identification.json")  
String identificationJson;  
```

The ConfigMap key `identification.json` becomes the property `identification.json`[^1_1][^1_4].

### 4. **Override for Development via `.env`**

Create a `.env` file in your project root (add to `.gitignore`):

```env  
IDENTIFICATION_JSON={"origin":{"berichtStroom":"DEV_GLV_IN_S","berichtSoort":"DEV_GLVIV","berichtVersie":"1"}}  
```

Quarkus automatically loads this for the `dev` profile, overriding the ConfigMap property[^1_5][^1_6][^1_7].

### Key Mechanics

- **Production**: The ConfigMap’s `identification.json` value populates the property.
- **Development**: The `.env`’s `IDENTIFICATION_JSON` environment variable takes precedence.
- **Property Resolution**:
    - Environment variables (like those from `.env`) override ConfigMap properties[^1_5][^1_6].
    - Dots in property names (e.g., `identification.json`) become underscores in environment variables (e.g., `IDENTIFICATION_JSON`)[^1_5][^1_7].


### Verification

- **Test the application**:

```bash  
./mvnw quarkus:dev  # Uses .env value  
./mvnw quarkus:dev -Dquarkus.profile=prod  # Uses ConfigMap value (if connected to K8s)  
```

- **Inspect the property**:

```java  
@GET  
public String getConfig() {  
    return identificationJson; // Returns dev or prod JSON  
}  
```


### Notes

- **Namespace**: Ensure the ConfigMap is in the same namespace as your pod (default: `prod`)[^1_1][^1_4].
- **Security**: The `.env` file must not be committed (add to `.gitignore`)[^1_5][^1_6].
- **JSON Handling**: Parse the `identificationJson` string as needed (e.g., using `JsonObject`)[^1_2].

This approach cleanly separates production (ConfigMap) and development (`.env`) configurations while using the same property in code[^1_1][^1_5][^1_6][^1_4].

<div style="text-align: center">⁂</div>

[^1_1]: https://quarkus.io/guides/kubernetes-config

[^1_2]: https://stackoverflow.com/questions/73443428/how-to-generate-kubernetes-configmap-from-the-quarkus-application-properties-w

[^1_3]: https://github.com/shpratee/quarkus-kubernetes-integration

[^1_4]: https://www.bookstack.cn/read/quarkus-1.7-en/5da6ae6d1597aac6.md

[^1_5]: https://quarkus.io/guides/config-reference

[^1_6]: https://quarkus.io/guides/config

[^1_7]: https://stackoverflow.com/questions/61727084/dev-config-overrides-test-config-in-quarkus

[^1_8]: https://quarkus.io/guides/deploying-to-kubernetes

[^1_9]: https://piotrminkowski.com/2020/08/10/guide-to-quarkus-on-kubernetes/

[^1_10]: https://stackoverflow.com/questions/60125394/quarkus-application-properties-as-kubernetes-openshift-config-map-for-native-ima

[^1_11]: https://davidgomes.blog/2022/07/29/quarkus-guide-configuration/

[^1_12]: https://docs.redhat.com/de/documentation/red_hat_build_of_quarkus/2.13/html-single/configuring_your_quarkus_applications_by_using_a_properties_file/index

[^1_13]: https://developers.redhat.com/blog/2020/01/23/using-kubernetes-configmaps-to-define-your-quarkus-applications-properties

[^1_14]: https://redhat-scholars.github.io/inner-loop-guide/inner-loop/6.0/app-config.html

[^1_15]: https://docs.quarkiverse.io/quarkus-helm/dev/example-config.html

[^1_16]: https://stackoverflow.com/questions/77217217/what-is-the-equivalent-of-the-application-local-properties-file-in-quarkus

[^1_17]: https://github.com/quarkusio/quarkus/issues/3670

[^1_18]: https://stackoverflow.com/questions/79601363/does-quarkus-automatically-convert-environment-variables-to-the-application-prop

[^1_19]: https://docs.openrewrite.org/recipes/quarkus/changequarkuspropertyvalue

[^1_20]: https://github.com/quarkusio/quarkus/issues/11438


---

# can we also do this without the quarkus-kubernetes-config extension treating the content of identification.json as an environment variable?

To link the `identification.json` content from a Kubernetes ConfigMap to a Quarkus property without using the `quarkus-kubernetes-config` extension—and while supporting a `.env` override for development—follow this approach:

### 1. **Inject ConfigMap Content as Environment Variable in Kubernetes**

Configure your Kubernetes Deployment manifest to inject the ConfigMap value directly as an environment variable:

```yaml
env:
- name: IDENTIFICATION_JSON  
  valueFrom:
    configMapKeyRef:
      name: bos-herken-tbg-rfh2-xml-6644946d2d
      key: identification.json
```

This maps the ConfigMap's `identification.json` content to the `IDENTIFICATION_JSON` environment variable in the pod[^2_4][^2_6][^2_7].

### 2. **Access the Environment Variable in Quarkus**

In your Quarkus `application.properties`, reference the environment variable:

```properties
myapp.identification.json=${IDENTIFICATION_JSON}
```

Quarkus automatically resolves environment variables using MicroProfile Config rules (dots become underscores, uppercase)[^2_2][^2_5].

### 3. **Override with `.env` for Development**

Create a `.env` file in your project root:

```env
IDENTIFICATION_JSON={"origin":{"berichtStroom":"DEV_GLV_IN_S","berichtSoort":"DEV_GLVIV","berichtVersie":"1"}}
```

During `quarkus:dev`, this overrides the Kubernetes value due to the `.env` file's high configuration ordinal (295)[^2_2].

### Key Mechanics

- **Kubernetes Injection**: The ConfigMap value populates `IDENTIFICATION_JSON` in the container's runtime environment.
- **Quarkus Resolution**:
    - The property `myapp.identification.json` binds to `IDENTIFICATION_JSON`[^2_2][^2_5].
    - In development, `.env` takes precedence over Kubernetes values[^2_2].
- **No Extensions Required**: Avoids `quarkus-kubernetes-config` by relying on native Kubernetes env injection and Quarkus config ordinals.


### Verification

- **Production**: Confirm the env variable exists in the pod:

```bash  
kubectl exec <pod> -- printenv IDENTIFICATION_JSON
```

- **Development**: Run `./mvnw quarkus:dev` and check the log for the dev JSON value.


### Advantages

- **Decoupling**: ConfigMap changes require no application rebuild.
- **Security**: Sensitive values can use Secrets instead of ConfigMaps[^2_4][^2_7].
- **Portability**: Works across any Kubernetes cluster without Quarkus-specific extensions[^2_6][^2_7].

<div style="text-align: center">⁂</div>

[^2_1]: https://quarkus.io/guides/kubernetes-config

[^2_2]: https://quarkus.io/guides/config-reference

[^2_3]: https://dev.to/yanev/creating-custom-configuration-in-quarkus-loaded-from-json-file-5gee

[^2_4]: https://quarkus.io/guides/deploying-to-kubernetes

[^2_5]: https://stackoverflow.com/questions/77135709/using-environment-variables-with-configmapping

[^2_6]: https://developers.redhat.com/blog/2020/01/23/using-kubernetes-configmaps-to-define-your-quarkus-applications-properties

[^2_7]: https://www.golinuxcloud.com/kubernetes-configmaps/

[^2_8]: https://github.com/quarkusio/quarkus/discussions/30353

[^2_9]: https://livebook.manning.com/book/kubernetes-native-microservices/chapter-3

[^2_10]: https://github.com/quarkiverse/quarkus-helm/issues/292

[^2_11]: https://stackoverflow.com/questions/76475625/quarkus-not-picking-up-kubernetes-environment-variable

[^2_12]: https://www.bookstack.cn/read/quarkus-1.7-en/5da6ae6d1597aac6.md

[^2_13]: https://github.com/dmarrazzo/quarkus-env-config

[^2_14]: https://stackoverflow.com/questions/63998501/how-to-load-configmaps-using-kubernetes-config-extension

[^2_15]: https://quarkus.io/guides/config-mappings

[^2_16]: https://bill.burkecentral.com/2020/12/15/qson-new-java-json-parser-for-quarkus/

[^2_17]: https://quarkus.io/guides/rest-json


---

# In the original configMap definition (from the first question) can I access the content of identification.json from a shell within a running container i.e.

kubectl exec --stdin --tty kustom-mywebapp-v1-5df468f984-mtq7q -- sh

Yes, **you can access the content of `identification.json` from a shell within a running container**, but only if the ConfigMap was mounted as a file (volume) in the pod specification. Here’s how this works and what to check:

### How ConfigMap Data Becomes Accessible in a Container

**ConfigMap data can be made available to containers in two main ways:**

- As **environment variables** (each key becomes an environment variable)
- As **files mounted via a volume** (each key becomes a file at the mount path)

**For your use case (accessing the JSON content from a shell), you need the ConfigMap mounted as a file.**
When mounted this way, each key in the ConfigMap (`identification.json` in your case) appears as a file with its content inside the container[^3_1][^3_2][^3_3].

### How to Check and Access the File

1. **Verify the Pod Spec**
    - The pod/deployment YAML should include something like:

```yaml
volumes:
  - name: config-volume
    configMap:
      name: bos-herken-tbg-rfh2-xml-6644946d2d
containers:
  - name: mywebapp
    volumeMounts:
      - name: config-volume
        mountPath: /etc/config  # Example path
        readOnly: true
```

    - This means `/etc/config/identification.json` will exist in the container[^3_1][^3_3].
2. **Open a Shell in the Container**
    - Use:

```sh
kubectl exec --stdin --tty kustom-mywebapp-v1-5df468f984-mtq7q -- sh
```

3. **List and View the File**
    - List files at the mount path (e.g., `/etc/config`):

```sh
ls /etc/config
```

    - View the content:

```sh
cat /etc/config/identification.json
```


### If the ConfigMap Is Not Mounted as a Volume

- If the ConfigMap is **only used as environment variables**, you **cannot access the file** directly, but you can print the value of the environment variable (if the key name is valid for env vars):

```sh
echo "$IDENTIFICATION_JSON"
```

However, since your key is `identification.json`, it may not be available as an environment variable due to naming restrictions[^3_1].


### Summary Table

| ConfigMap Usage | How to Access in Shell |
| :-- | :-- |
| Mounted as Volume/File | `cat /mount/path/identification.json` |
| Injected as Env Var | `echo "$IDENTIFICATION_JSON"` (if valid) |

**Conclusion:**
If your ConfigMap is mounted as a volume, you can directly access `identification.json` as a file from a shell in the running container. If it’s not, you’ll need to adjust your deployment to mount it as described above[^3_1][^3_2][^3_3].

<div style="text-align: center">⁂</div>

[^3_1]: https://kubernetes.io/docs/concepts/configuration/configmap/

[^3_2]: https://kubernetes.io/docs/tasks/configure-pod-container/configure-pod-configmap/

[^3_3]: https://stackoverflow.com/questions/71426410/how-to-import-a-config-file-into-a-container-from-k8s

[^3_4]: https://kubernetes.io/docs/tasks/debug/debug-application/get-shell-running-container/

[^3_5]: https://www.plural.sh/blog/configmap-kubernetes-guide/

[^3_6]: https://www.howtoforge.com/configmaps-in-kubernetes/

[^3_7]: https://docs.duplocloud.com/docs/kubernetes-overview/configs-and-secrets/mounting-config-as-files

[^3_8]: https://spacelift.io/blog/kubernetes-configmap

[^3_9]: https://docs.garden.io/acorn-0.12/kubernetes-plugins/module-types/configmap

[^3_10]: https://carlos.mendible.com/2019/02/10/kubernetes-mount-file-pod-with-configmap/

[^3_11]: https://www.qovery.com/blog/kubernetes-configmap-our-complete-guide/

[^3_12]: https://stackoverflow.com/questions/53679547/how-to-execute-shell-commands-from-within-a-kubernetes-configmap

[^3_13]: https://itnext.io/kubernetes-tips-using-scripts-inside-configmaps-9df03e17ac35

[^3_14]: https://www.getambassador.io/blog/kubernetes-configurations-secrets-configmaps

[^3_15]: https://www.bookstack.cn/read/kubernetes-1.21-en/a4ff9284bb4c534d.md

[^3_16]: https://www.pulumi.com/answers/mounting-kubernetes-configmaps-as-pod-volumes/

[^3_17]: https://www.golinuxcloud.com/kubernetes-configmaps/

[^3_18]: https://stackoverflow.com/questions/67532600/kubernetes-volume-mount-configmap-to-file-within-the-pod-without-overwriting-all

