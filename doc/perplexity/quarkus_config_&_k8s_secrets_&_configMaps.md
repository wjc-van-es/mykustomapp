<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" class="logo" width="120"/>

# what are the ways to link kubernetes secrets and configMaps to Quarkus application.properties

To link Kubernetes Secrets and ConfigMaps to a Quarkus application's `application.properties`, you can use the **quarkus-kubernetes-config** extension. This extension allows Quarkus to read configuration values directly from Kubernetes ConfigMaps and Secrets, integrating them as configuration sources for the application.

## Main Ways to Link Kubernetes Secrets and ConfigMaps to Quarkus

### 1. Using the `quarkus-kubernetes-config` Extension

- **Add the extension** to your Quarkus project:

```
./mvnw quarkus:add-extension -Dextensions="kubernetes-config"
```

- **Enable the extension** in your `application.properties`:

```
quarkus.kubernetes-config.enabled=true
```

- **Specify which ConfigMaps and Secrets to use** by naming them:

```
quarkus.kubernetes-config.config-maps=app-config
quarkus.kubernetes-config.secrets=db-credentials
```

These ConfigMaps and Secrets must exist in the same Kubernetes namespace where the application runs[^1_1][^1_2][^1_3].
- **Access configuration values** in your Quarkus code using MicroProfile Config's `@ConfigProperty` annotation:

```java
@ConfigProperty(name = "greeting")
String greeting;

@ConfigProperty(name = "database-password")
String dbPassword;
```

Here, `greeting` or `database-password` correspond to keys in the ConfigMap or Secret respectively[^1_2][^1_3].


### 2. Mounting ConfigMaps and Secrets as Environment Variables or Files

Alternatively, Kubernetes allows mounting ConfigMaps and Secrets into the Pod as environment variables or files, which Quarkus can then read:

- **Mount as environment variables** in your Pod spec:

```yaml
env:
  - name: APP_MODE
    valueFrom:
      configMapKeyRef:
        name: app-config
        key: APP_MODE
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

- Quarkus can then read these environment variables as configuration properties by naming them accordingly or by using the environment variable names directly.
- **Mount as files** (volumes) under a path like `/mnt/app-secret` or `/mnt/app-config-map`, then configure Quarkus to read from these paths if needed[^1_4].


### 3. Example Configuration in `application.properties`

For example, to enable reading from a Secret named `db-credentials` and a ConfigMap named `app-config`:

```properties
quarkus.kubernetes-config.enabled=true
quarkus.kubernetes-config.config-maps=app-config
quarkus.kubernetes-config.secrets=db-credentials
```

This tells Quarkus to fetch configuration keys from those Kubernetes resources and make them available as configuration properties[^1_1][^1_2][^1_3].

### 4. Best Practices

- Use **ConfigMaps** for non-sensitive configuration data.
- Use **Secrets** for sensitive data like passwords and tokens.
- Avoid storing sensitive data in version control.
- Use different ConfigMaps and Secrets per environment (dev, staging, prod)[^1_5].

In summary, the primary and recommended way to link Kubernetes Secrets and ConfigMaps to a Quarkus application is by using the `quarkus-kubernetes-config` extension, enabling it in your `application.properties`, and specifying which ConfigMaps and Secrets to use. Quarkus will then fetch these values directly from the Kubernetes API and inject them as configuration properties accessible via `@ConfigProperty`. Alternatively, you can mount ConfigMaps and Secrets as environment variables or files in the Pod and configure Quarkus to read them accordingly[^1_1][^1_2][^1_3][^1_4].

<div style="text-align: center">⁂</div>

[^1_1]: https://quarkus.io/guides/kubernetes-config

[^1_2]: http://galeaaugustin.blogspot.com/2024/12/get-information-from-with-quarkus-from.html

[^1_3]: https://opensource.com/article/22/5/quarkus-kubernetes-secrets

[^1_4]: https://quarkus.io/guides/deploying-to-kubernetes

[^1_5]: https://dev.to/denish3436/securing-configurations-managing-configmaps-and-secrets-in-kubernetes-1jn

[^1_6]: https://docs.quarkiverse.io/quarkus-helm/dev/example-config.html

[^1_7]: https://stackoverflow.com/questions/73443428/how-to-generate-kubernetes-configmap-from-the-quarkus-application-properties-w

[^1_8]: https://github.com/quarkusio/quarkus/issues/38604

[^1_9]: https://github.com/quarkusio/quarkus/issues/25058

[^1_10]: https://quarkus.io/guides/deploying-to-openshift


---

# The example application.properties under section 3 used the kubernetes-config extension mentioned under section 1. What does the application.properties look like when linking properties to environment variables or (the content of) files as mentioned under section 2?

When linking properties to environment variables or file content (as opposed to using the `quarkus-kubernetes-config` extension), your `application.properties` file in Quarkus typically serves as a fallback or as a way to provide default values. The actual values are injected at runtime via environment variables or files mounted in the container. Here’s how you can structure your `application.properties` and configure your deployment:

## Linking to Environment Variables

You can reference environment variables in `application.properties` using the `${ENV_VAR:default}` syntax. For example:

```properties
quarkus.datasource.username=${DB_USER:defaultuser}
quarkus.datasource.password=${DB_PASSWORD:defaultpass}
my.custom.property=${MY_ENV_VAR:defaultvalue}
```

- Here, `DB_USER`, `DB_PASSWORD`, and `MY_ENV_VAR` are environment variables that you would set in your Kubernetes deployment (or locally).
- If the environment variable is not set, Quarkus uses the provided default value (`defaultuser`, `defaultpass`, `defaultvalue`)[^2_1][^2_2].

**Kubernetes Deployment Example:**

```yaml
env:
  - name: DB_USER
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: username
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```


## Linking to File Content (Mounted Secrets/ConfigMaps)

If you mount a Secret or ConfigMap as a file (for example, as `/etc/secrets/db-password`), you can instruct Quarkus to read the value from the file by referencing it in your deployment as an environment variable using the `valueFrom` and the `subPath` feature, or by using the `file:` prefix in your configuration (if supported by the property).

**Example using environment variable referencing file content:**

```yaml
env:
  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

**Example using file mount:**

Mount the file in your deployment:

```yaml
volumeMounts:
  - name: db-secret
    mountPath: /etc/secrets
    readOnly: true
volumes:
  - name: db-secret
    secret:
      secretName: db-secret
```

Then, in your `application.properties`, you could use:

```properties
quarkus.datasource.password=${DB_PASSWORD}
```

And set `DB_PASSWORD` via an init container or entrypoint script to read the file content and export it as an environment variable.

Alternatively, for properties that support file-based configuration (like some database drivers), you can point directly to the file path if the property allows it.

## Overriding Precedence

Quarkus uses the following precedence for configuration sources (highest to lowest):

1. System properties (`-D` flags)
2. Environment variables
3. `.env` file in the working directory
4. External `application.properties` in `$PWD/config/application.properties`
5. Internal `application.properties` in the classpath

This means environment variables will override values in `application.properties`[^2_3].

## Summary Table

| Approach | application.properties Example | Kubernetes Example |
| :-- | :-- | :-- |
| Environment variable | `my.prop=${MY_ENV_VAR:default}` | `env: [{ name: MY_ENV_VAR, value: ... }]` |
| File content (indirect) | `my.prop=${MY_ENV_VAR}` (set by entrypoint script) | Mount file, read in script, export as env var |
| File override | (no change; mount as `/deployments/config/application.properties`) | Mount ConfigMap/Secret as file at `/deployments/config` |

## Using External application.properties

You can also mount an entire `application.properties` from a ConfigMap or Secret at `/deployments/config/application.properties` (for JVM mode) or `/work/config/application.properties` (for native mode). Quarkus will automatically pick up this file and override any internal configuration[^2_4].

In summary, when linking properties to environment variables or files, your `application.properties` typically contains property references like `${ENV_VAR:default}`. The actual values are provided at runtime by Kubernetes via environment variables or by mounting files and injecting their content into environment variables or directly as external configuration files[^2_3][^2_1][^2_4][^2_2].

<div style="text-align: center">⁂</div>

[^2_1]: https://copyprogramming.com/howto/quarkus-how-to-set-environment-variables-in-application-properties

[^2_2]: https://stackoverflow.com/questions/55796370/quarkus-how-to-set-environment-variables-in-application-properties

[^2_3]: https://quarkus.io/guides/config-reference

[^2_4]: https://github.com/quarkusio/quarkus/issues/305

[^2_5]: http://galeaaugustin.blogspot.com/2024/12/get-information-from-with-quarkus-from.html

[^2_6]: https://docs.redhat.com/de/documentation/red_hat_build_of_quarkus/2.13/html-single/configuring_your_quarkus_applications_by_using_a_properties_file/index

[^2_7]: https://github.com/quarkusio/quarkus/issues/33321

[^2_8]: https://github.com/quarkusio/quarkus/discussions/40492

[^2_9]: https://stackoverflow.com/a/60007896

[^2_10]: https://stackoverflow.com/questions/66957109/reading-configuration-file-with-a-map-of-properties-in-quarkus

[^2_11]: https://dev.to/yanev/creating-custom-configuration-in-quarkus-loaded-from-json-file-5gee

[^2_12]: https://docs.redhat.com/es/documentation/red_hat_build_of_quarkus/2.13/html-single/configuring_your_quarkus_applications_by_using_a_yaml_file/index

[^2_13]: https://quarkus.io/guides/config

[^2_14]: https://codingtechroom.com/question/how-to-access-environment-variables-in-quarkus

[^2_15]: https://blog.poespas.me/posts/2024/05/20/quarkus-configuring-external-configuration-sources/

[^2_16]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/2.13/html-single/configuring_your_quarkus_applications_by_using_a_properties_file/index

[^2_17]: https://stackoverflow.com/questions/59662044/quarkus-how-to-define-and-read-properties-file-or-application-properties-outs

[^2_18]: https://stackoverflow.com/questions/73443428/how-to-generate-kubernetes-configmap-from-the-quarkus-application-properties-w


---

# So how about specifying a keystore as kubernetes secret. That would be interpreted as a mounted file path when deployed in a pod and a local file path in dev mode?

To use a Kubernetes Secret containing a keystore file in Quarkus, configure it as a mounted volume in production and reference it via a local path in development mode. Here's how to implement this:

### 1. **Kubernetes Secret Setup**

- Store the keystore file (e.g., `keystore.jks`) in a Secret:

```bash
kubectl create secret generic app-keystore --from-file=keystore.jks=/path/to/keystore.jks
```

- Mount the Secret as a volume in your Pod spec:

```yaml
volumes:
  - name: keystore-volume
    secret:
      secretName: app-keystore
containers:
  - volumeMounts:
      - name: keystore-volume
        mountPath: /etc/keystore
```

This makes the keystore available at `/etc/keystore/keystore.jks` in the container[^3_2][^3_3].


### 2. **Quarkus Configuration**

#### For Production (Kubernetes):

- In `application.properties`, reference the mounted keystore path:

```properties
%prod.quarkus.http.ssl.certificate.key-store-file=/etc/keystore/keystore.jks
%prod.quarkus.http.ssl.certificate.key-store-password=${KEYSTORE_PASSWORD}
```

- Set the password via an environment variable sourced from a Kubernetes Secret:

```yaml
env:
  - name: KEYSTORE_PASSWORD
    valueFrom:
      secretKeyRef:
        name: app-secrets
        key: keystore-password
```

This avoids hardcoding sensitive data[^3_1][^3_4][^3_5].


#### For Development (Local):

- Override the keystore path using a `%dev` profile:

```properties
%dev.quarkus.http.ssl.certificate.key-store-file=src/main/resources/keystore-dev.jks
%dev.quarkus.http.ssl.certificate.key-store-password=dev-password
```

- Place a development keystore at `src/main/resources/keystore-dev.jks`.


### 3. **Key Considerations**

- **Security**:
    - In production, the keystore file and password are decoupled. The file is mounted from the Secret, while the password is injected via environment variables[^3_1][^3_4].
    - Never commit production secrets or keystores to version control.
- **Path Handling**:
Quarkus resolves `key-store-file` by first checking the filesystem, then classpath resources[^3_5]. This ensures compatibility across environments.
- **Password Management**:
Use Kubernetes Secrets for passwords in production. For local development, store passwords in `application.properties` under `%dev` or use `.env` files[^3_4][^3_5].


### Example Workflow

1. **Production Deployment**:
    - Keystore file mounted from Secret at `/etc/keystore/keystore.jks`.
    - Password injected via `KEYSTORE_PASSWORD` env var.
2. **Local Development**:
    - Keystore file at `src/main/resources/keystore-dev.jks`.
    - Password set in `application.properties` under `%dev` profile.

This approach ensures consistent keystore handling across environments while maintaining security best practices[^3_1][^3_2][^3_5].

<div style="text-align: center">⁂</div>

[^3_1]: https://quarkus.io/guides/config-secrets

[^3_2]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/3.15/html/management_of_security_keys_and_certificates_with_the_tls_registry/tls-registry-reference

[^3_3]: https://github.com/quarkusio/quarkus/issues/25058

[^3_4]: https://stackoverflow.com/questions/78203941/quarkus-keystore-password-file

[^3_5]: https://quarkus.io/guides/http-reference

[^3_6]: https://quarkus.io/guides/security-oidc-configuration-properties-reference

[^3_7]: https://quarkus.io/guides/native-and-ssl

[^3_8]: https://stackoverflow.com/questions/76390340/mounting-or-file-mapping-into-quarkus-app-testcontainer-during-dev-mode

[^3_9]: https://www.keycloak.org/server/configuration

[^3_10]: https://quarkus.io/guides/deploying-to-kubernetes


---

# So secrets for local dev mode development can be store in a .env file, which you won't commit to version control. What would be the proper location in a maven project iow its working directory when running quarkus in dev mode?

Yes, for **local development in Quarkus dev mode**, you can store secrets in a `.env` file placed in the **root directory of your Maven project** (i.e., the project’s base directory, where your `pom.xml` is located)[^4_1][^4_3][^4_7]. This file is automatically picked up by Quarkus when you run `mvn quarkus:dev`, and its variables can be referenced in your `application.properties` using the `${ENV_VAR}` syntax.

**Key points:**

- The `.env` file should be in the **project root** (the working directory when running Quarkus in dev mode)[^4_1][^4_3][^4_7].
- Do **not** commit `.env` to version control; add it to your `.gitignore`[^4_1][^4_3][^4_7].
- Example structure:

```
my-secret-key=supersecret
db.password=devpassword
```

And in `application.properties`:

```
app.secret=${my-secret-key}
quarkus.datasource.password=${db.password}
```

- When running `mvn quarkus:dev`, the working directory is typically the project root, so Quarkus finds and loads the `.env` file from there[^4_1][^4_3][^4_7].

**Summary:**
**Place your `.env` file in the Maven project’s root directory** for local development. This is the proper location, as it matches Quarkus’s expected working directory in dev mode and ensures your secrets are loaded securely and conveniently[^4_1][^4_3][^4_7].

<div style="text-align: center">⁂</div>

[^4_1]: https://quarkus.io/guides/config-reference

[^4_2]: https://github.com/quarkusio/quarkus/issues/3670

[^4_3]: https://quarkus.io/guides/config

[^4_4]: https://github.com/quarkusio/quarkus/issues/7519

[^4_5]: https://stackoverflow.com/questions/77217217/what-is-the-equivalent-of-the-application-local-properties-file-in-quarkus

[^4_6]: https://stackoverflow.com/questions/79210101/handle-environment-variables-in-quarkus-for-local-development-and-production-usi

[^4_7]: https://docs.redhat.com/en/documentation/red_hat_build_of_quarkus/1.3/html/configuring_your_quarkus_applications/proc-setting-configuration-properties_quarkus-configuration-guide

[^4_8]: https://github.com/dmarrazzo/quarkus-env-config


---

# Thank you, taht was most helpful

You're welcome! I'm glad the information was helpful. If you have any more questions about Quarkus, Kubernetes, or anything else, feel free to ask. Happy coding!

---

# Making the keystore content stored as kubernetes secret available to the pod as volume mount

To make the **keystore content stored as a Kubernetes Secret available to your pod as a mounted file**, follow these steps:

## 1. Create the Secret with the Keystore File

First, create a Kubernetes Secret from your keystore file (e.g., `keystore.jks`):

```bash
kubectl create secret generic my-keystore-secret --from-file=keystore.jks=/path/to/keystore.jks
```


## 2. Mount the Secret as a Volume in the Pod

Add the following to your Pod or Deployment YAML. This mounts the secret as a volume, making the keystore file available at a specific path inside the container:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-app
spec:
  containers:
    - name: my-container
      image: my-image
      volumeMounts:
        - name: keystore-volume
          mountPath: /etc/keystore
          readOnly: true
  volumes:
    - name: keystore-volume
      secret:
        secretName: my-keystore-secret
```

- The `keystore.jks` file will be available inside the container at `/etc/keystore/keystore.jks`[^6_1][^6_5][^6_8].


## 3. Reference the Mounted Keystore in Quarkus

In your `application.properties` (typically using the `%prod` profile for production), configure Quarkus to use the mounted keystore file:

```properties
%prod.quarkus.http.ssl.certificate.key-store-file=/etc/keystore/keystore.jks
%prod.quarkus.http.ssl.certificate.key-store-password=${KEYSTORE_PASSWORD}
```

- Set the `KEYSTORE_PASSWORD` as an environment variable, ideally also sourced from a Kubernetes Secret.


## 4. Notes and Best Practices

- **File Permissions**: By default, files from Secrets are mounted with permissions `0444` (read-only). You can adjust this using the `defaultMode` field if needed[^6_2].
- **Secret Updates**: If the Secret is updated, Kubernetes will eventually update the mounted file in the running pod (with some delay)[^6_4].
- **Security**: Mounting the keystore as a file avoids exposing sensitive binary data as environment variables and is the recommended approach for binary secrets like keystores[^6_4][^6_8].

This setup is the standard and secure way to make a keystore (or any binary secret) available to your application running in a Kubernetes pod.

<div style="text-align: center">⁂</div>

[^6_1]: https://github.com/justsomedevnotes/kubernetes-volumes-secret

[^6_2]: https://www.jeffgeerling.com/blog/2019/mounting-kubernetes-secret-single-file-inside-pod

[^6_3]: https://kubernetes.io/docs/concepts/storage/volumes/

[^6_4]: https://kubernetes.io/docs/concepts/configuration/secret/

[^6_5]: https://labex.io/questions/how-to-mount-a-kubernetes-secret-as-a-volume-in-a-pod-8448

[^6_6]: https://www.alibabacloud.com/help/en/ack/ack-managed-and-ack-dedicated/user-guide/configure-a-pod-to-use-a-secret

[^6_7]: https://kubernetes.io/docs/tasks/configure-pod-container/configure-projected-volume-storage/

[^6_8]: https://spacelift.io/blog/kubernetes-secrets

