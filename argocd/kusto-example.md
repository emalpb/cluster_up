apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kustomize-inline-guestbook
  namespace: argocd
  finalizers:
    - resources-finalizer.argocd.argoproj.io
spec:
  destination:
    namespace: test1
    server: https://kubernetes.default.svc
  project: default
  source:
    path: kustomize-guestbook
    repoURL: https://github.com/argoproj/argocd-example-apps.git
    targetRevision: master
    kustomize:
      patches:
        - target:
            kind: Deployment
            name: guestbook-ui
          patch: |-
            - op: replace
              path: /spec/template/spec/containers/0/ports/0/containerPort
              value: 443

---
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: kustomize-example
spec:
  project: default
  source:
    path: examples/helloWorld
    repoURL: 'https://github.com/kubernetes-sigs/kustomize'
    targetRevision: HEAD
  destination:
    namespace: default
    server: 'https://kubernetes.default.svc'

If the `kustomization.yaml` file exists at the location pointed to by `repoURL` and `path`, Argo CD will render the manifests using Kustomize.

The following configuration options are available for Kustomize:

* `namePrefix` is a prefix appended to resources for Kustomize apps
* `nameSuffix` is a suffix appended to resources for Kustomize apps
* `images` is a list of Kustomize image overrides
* `replicas` is a list of Kustomize replica overrides
* `commonLabels` is a string map of additional labels
* `labelWithoutSelector` is a boolean value which defines if the common label(s) should be applied to resource selectors and templates.
* `forceCommonLabels` is a boolean value which defines if it's allowed to override existing labels
* `commonAnnotations` is a string map of additional annotations
* `namespace` is a Kubernetes resources namespace
* `forceCommonAnnotations` is a boolean value which defines if it's allowed to override existing annotations
* `commonAnnotationsEnvsubst` is a boolean value which enables env variables substition in annotation  values
* `patches` is a list of Kustomize patches that supports inline updates
* `components` is a list of Kustomize components

To use Kustomize with an overlay, point your path to the overlay.

!!! tip
    If you're generating resources, you should read up how to ignore those generated resources using the [`IgnoreExtraneous` compare option](compare-options.md).

## Patches
Patches are a way to kustomize resources using inline configurations in Argo CD applications.  `patches`  follow the same logic as the corresponding Kustomization.  Any patches that target existing Kustomization file will be merged.

This Kustomize example sources manifests from the `/kustomize-guestbook` folder of the `argoproj/argocd-example-apps` repository, and patches the `Deployment` to use port `443` on the container.
```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
metadata:
  name: kustomize-inline-example
namespace: test1
resources:
  - https://github.com/argoproj/argocd-example-apps//kustomize-guestbook/
patches:
  - target:
      kind: Deployment
      name: guestbook-ui
    patch: |-
      - op: replace
        path: /spec/template/spec/containers/0/ports/0/containerPort
        value: 443

---

apiVersion: argoproj.io/v1alpha1
kind: ApplicationSet
metadata:
  name: external-dns
spec:
  goTemplate: true
  goTemplateOptions: ["missingkey=error"]
  generators:
  - clusters: {}
  template:
    metadata:
      name: 'external-dns'
    spec:
      project: default
      source:
        repoURL: https://github.com/kubernetes-sigs/external-dns/
        targetRevision: v0.14.0
        path: kustomize
        kustomize:
          patches:
          - target:
              kind: Deployment
              name: external-dns
            patch: |-
              - op: add
                path: /spec/template/spec/containers/0/args/3
                value: --txt-owner-id={{.name}}   # patch using attribute from generator
      destination:
        name: 'in-cluster'
        namespace: default

---

apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-cm
  namespace: argocd
data:
  kustomize.buildOptions: --enable-helm