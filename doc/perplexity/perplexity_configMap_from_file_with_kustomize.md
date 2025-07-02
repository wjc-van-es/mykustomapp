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


---

# I am a bit confused with the first answer: is it

@ConfigProperty(name = "identification.json")
String identificationJson;
or
@GET
public String getConfig() {
return identificationJson; // Returns dev or prod JSON
}
to refer to the file content as String in the code?

Great question! Let me clarify the distinction:

## 1. **@ConfigProperty(name = "identification.json") String identificationJson;**

This is a **field injection** using MicroProfile Config (supported by Quarkus).
It tells Quarkus:

- "Inject the value of the configuration property named `identification.json` into this Java field."

**Example:**

```java
import org.eclipse.microprofile.config.inject.ConfigProperty;

@ApplicationScoped
public class MyService {

    @ConfigProperty(name = "identification.json")
    String identificationJson;

    // ... use identificationJson in your logic
}
```

This makes the value (from environment variable, ConfigMap, `.env`, etc.) available as a String in your code.

## 2. **@GET public String getConfig() { ... }**

This is a **REST endpoint method** (using JAX-RS or RESTEasy).
It simply returns the value of `identificationJson` (which was injected above) when someone calls this endpoint.

**Example:**

```java
import javax.ws.rs.GET;
import javax.ws.rs.Path;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import org.eclipse.microprofile.config.inject.ConfigProperty;

@Path("/config")
public class ConfigResource {

    @ConfigProperty(name = "identification.json")
    String identificationJson;

    @GET
    @Produces(MediaType.APPLICATION_JSON)
    public String getConfig() {
        return identificationJson;
    }
}
```

- When you `GET /config`, you receive the JSON content as a String.


## **Summary**

- `@ConfigProperty(name = "identification.json") String identificationJson;`
  **Injects the config value** into your code.
- `@GET public String getConfig() { return identificationJson; }`
  **Exposes the injected value** via a REST endpoint.

**You need both** if you want to inject the config value and then expose it via REST.
If you just want to use the value in your business logic, you only need the first part.

**Let me know if you'd like a complete code example or further details!**

---

# OK, thank you The first example was a bit terse. Now it makes sense.

You're welcome—I'm glad the explanation clarified things for you. If you have more questions about using `@ConfigProperty`, integrating Kubernetes ConfigMaps, or any other configuration scenarios in Quarkus, feel free to ask[^5_1].

<div style="text-align: center">⁂</div>

[^5_1]: programming.configuration


---

# Is the quarkus-kubernetes-config extension also the best option for OpenShift or does  OpenShift has its own quarkus config variant?

The **quarkus-kubernetes-config** extension is fully supported and works on both **Kubernetes** and **OpenShift** for consuming ConfigMaps and Secrets as configuration sources in Quarkus applications[^6_1]. There is **no separate OpenShift-specific variant** for configuration—OpenShift is Kubernetes-compatible, and the extension works the same way on both platforms.

However, OpenShift does offer its own Quarkus extension, **quarkus-openshift**, but this is focused on generating OpenShift-specific deployment resources (like Routes, BuildConfigs, and ImageStreams), not on configuration management[^6_2][^6_3][^6_4][^6_5]. The **quarkus-openshift** extension is essentially a wrapper around the Kubernetes extension for deployment resource generation and does not replace or duplicate the functionality of `quarkus-kubernetes-config`[^6_6][^6_3][^6_4][^6_5].

**Summary Table**


| Use Case | Recommended Extension |
| :-- | :-- |
| ConfigMaps/Secrets as config | quarkus-kubernetes-config |
| OpenShift deployment resources | quarkus-openshift |

**Best Practice:**

- Use **quarkus-kubernetes-config** for loading ConfigMaps and Secrets as configuration sources on both Kubernetes and OpenShift[^6_1].
- Use **quarkus-openshift** if you want Quarkus to generate OpenShift-specific manifests and resources for deployment[^6_2][^6_3][^6_4][^6_5].

**You do not need a separate OpenShift configuration extension for ConfigMaps/Secrets.** The existing Kubernetes config extension is the recommended and supported approach on OpenShift.

<div style="text-align: center">⁂</div>

[^6_1]: https://quarkus.io/guides/kubernetes-config

[^6_2]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/2.7/html/deploying_your_quarkus_applications_to_openshift_container_platform/assembly_quarkus-openshift_quarkus-openshift

[^6_3]: https://quarkus.io/extensions/io.quarkus/quarkus-openshift/

[^6_4]: https://quarkus.io/guides/deploying-to-openshift

[^6_5]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/2.2/html-single/deploying_your_quarkus_applications_to_openshift_container_platform/index

[^6_6]: https://quarkus.io/guides/deploying-to-kubernetes

[^6_7]: https://quarkus.io/guides/deploying-to-openshift-howto

[^6_8]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/2.7/html-single/deploying_your_quarkus_applications_to_openshift_container_platform/index

[^6_9]: https://developers.redhat.com/blog/2021/01/15/10-reasons-to-develop-quarkus-applications-on-red-hat-openshift

[^6_10]: https://docs.redhat.com/de/documentation/red_hat_build_of_quarkus/2.2/html-single/deploying_your_quarkus_applications_to_openshift_container_platform/index

[^6_11]: https://www.opensourcerers.org/2020/11/23/how-to-pimp-your-quarkus-application-to-benefit-from-kubernetes/

[^6_12]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/2.13/html/deploying_your_quarkus_applications_to_openshift_container_platform/assembly_quarkus-openshift_quarkus-openshift

[^6_13]: https://redhat-scholars.github.io/openshift-apps-resource-management/openshift-apps-resource-management/openshift.html

[^6_14]: https://quarkus.io/extensions/io.quarkus/quarkus-container-image-openshift/

[^6_15]: https://developers.redhat.com/articles/2024/06/12/4-ways-deploy-quarkus-applications-openshift-container-platform-4

[^6_16]: https://quarkus.io/extensions/io.quarkus/quarkus-openshift-client/

[^6_17]: https://redhat-scholars.github.io/inner-loop-guide/inner-loop/6.0/app-config.html


---

# Thank you that's a clear answer

You're very welcome! 😊
I'm glad the answer was clear and helpful. If you have any more questions about Quarkus, Kubernetes, OpenShift, or anything else, just let me know. Happy coding! 🚀

---

# I foresee one more difficulty:

when we use a kustomize configMapGenerator with the specified name bos-herken-tbg-rfh2-xml it generates a deployment of a configMap with a name that is extended with a random string like -6644946d2d that will change with a new deployment.
Therefore, having to map this name in application.properties as
%prod.quarkus.kubernetes-config.config-maps=bos-herken-tbg-rfh2-xml-6644946d2d is not so future proof. Is there a way where the fixed bos-herken-tbg-rfh2-xml is sufficient?

You are correct: by default, **Kustomize’s `configMapGenerator` appends a hash to the ConfigMap name** (e.g., `bos-herken-tbg-rfh2-xml-6644946d2d`). This hash changes whenever the ConfigMap content changes, ensuring rolling updates of dependent workloads[^8_5][^8_7]. This behavior is intended for immutability and automatic rollout of changes.

### **Referencing the ConfigMap in Workloads**

**Kustomize automatically rewrites references** to the generated ConfigMap name in your workload manifests (like Deployments or StatefulSets) if you refer to the base name (e.g., `bos-herken-tbg-rfh2-xml`).

- **You should reference the base name** in your manifests, and Kustomize will update it to the full name with the hash[^8_2][^8_5].

**However, Quarkus’s `quarkus-kubernetes-config.config-maps` property cannot be dynamically rewritten by Kustomize** because it is a value inside your `application.properties` file, not a Kubernetes manifest reference. This means you would have to manually update the property with each deployment if you use the full hashed name.

### **How to Avoid Manual Updates**

#### **Option 1: Disable Hash Suffixing for the ConfigMap**

You can **disable the hash suffix** for a specific ConfigMap in Kustomize by setting the `options: { disableNameSuffixHash: true }` field:

```yaml
configMapGenerator:
  - name: bos-herken-tbg-rfh2-xml
    files:
      - identification.json
    options:
      disableNameSuffixHash: true
```

This will generate a ConfigMap named exactly `bos-herken-tbg-rfh2-xml` **without any hash**, so you can safely reference it in your Quarkus configuration as:

```properties
%prod.quarkus.kubernetes-config.config-maps=bos-herken-tbg-rfh2-xml
```

**Drawback:**

- Disabling the hash means changes to the ConfigMap will not automatically trigger rolling updates of your pods. You’ll need to handle rollout manually if the config changes.


#### **Option 2: Use Environment Variable or Volume Mount Instead**

Instead of relying on the Quarkus extension for reading ConfigMaps by name, you can:

- Mount the ConfigMap as a file or inject it as an environment variable in your Deployment manifest (which Kustomize will rewrite for you).
- Reference the mounted file or environment variable in your Quarkus application.

This avoids the need to specify the ConfigMap name in `application.properties` at all.

### **Summary Table**

| Approach | ConfigMap Name Stable? | Auto Rollout on Change? | Quarkus Config Needed? |
| :-- | :-- | :-- | :-- |
| Default `configMapGenerator` (with hash) | ❌ No | ✅ Yes | Manual update or automation of property needed |
| `disableNameSuffixHash: true` | ✅ Yes | ❌ No | Reference base name in Quarkus property |
| Use env var or file mount (recommended) | ✅ Yes | ✅/❌ (depends on rollout strategy) | No need to specify ConfigMap name in Quarkus config |

**In summary:**

- **If you want to use a fixed name in Quarkus, set `disableNameSuffixHash: true` for your ConfigMapGenerator.**
- **If you want automatic rollouts, use the default hash behavior and automate updating the property, or use environment variables/file mounts instead of the Quarkus Kubernetes Config extension.**

[^8_5][^8_7][^8_2]

<div style="text-align: center">⁂</div>

[^8_1]: https://stackoverflow.com/questions/77606656/generate-configmap-using-kustomization-but-the-name-in-configmapref-doesnt-i

[^8_2]: https://kubernetes.io/docs/tasks/manage-kubernetes-objects/kustomization/

[^8_3]: https://github.com/kubernetes-sigs/kustomize/issues/1301

[^8_4]: https://github.com/kubernetes-sigs/kustomize/issues/4674

[^8_5]: https://kubectl-book-ja.netlify.app/pages/reference/kustomize.html

[^8_6]: https://kubectl.docs.kubernetes.io/references/kustomize/builtins/

[^8_7]: https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/configmapgenerator/

[^8_8]: https://glasskube.dev/blog/patching-with-kustomize/


---

# OK Thank you, that is a clear summary of options and their consequences

You're very welcome! I'm glad the summary helped clarify your options and the trade-offs involved. If you have any more questions about Kustomize, Quarkus, Kubernetes, or deployment strategies, feel free to ask. Good luck with your project and happy deploying! 🚀

