# Kubernetes cookbook

## Scope and release

* Owner confirmed Full Migration, Kubernetes repair with real tests, retirement of obsolete CI
  versions while retaining newer versions/platform families, and replacement of patch release
  PR #84 with a major release on 2026-11-12.
* Version 3 removes root attributes and the unsupported v1beta1 wire format. Do not restore
  global client state, insecure localhost defaults or node-attribute configuration.
* Deliver the breaking feature against main first. Keep its existing released version; a
  `feat!` commit triggers Release Please to regenerate major release 3.0.0 after feature merge.
  Do not place implementation commits on the generated release branch or merge patch PR #84.

## Product and implementation

* This cookbook manages remote Kubernetes core/v1 Pods, Services and ReplicationControllers.
  It does not install a cluster. The client runs wherever Ruby and kubeclient dependencies run;
  the existing `supports 'all'` contract remains.
* kubeclient 4.13.0 requires Ruby 2.7+. Chef 17+ supplies a supported Ruby runtime. Its Config
  reader handles trusted kubeconfig credentials, certificate verification and context selection.
  Kubeconfigs may execute credential plugins: accept only operator-controlled files.
* No package repositories or source-built Kubernetes components are required by the cookbook.
  Chef's native build_essential resource supplies the compiler for kubeclient's HTTP native gem
  dependency. The first real arm64 Kitchen run proved that omitting it fails gem installation.
* Current Kubernetes supports these resources in core/v1. ReplicationController is retained for
  API compatibility; new applications should generally use Deployments outside this cookbook.
* Only ResourceNotFoundError means absent. Authentication, authorisation, validation, network
  and conflict errors must fail convergence. Never swallow them to make tests pass.
* Server-side apply owns declared fields under a stable manager; foreign-owned fields and
  admission defaults remain. A server dry-run previews both values and this manager's ownership
  fieldset, ignoring timestamps/status. Ownership-only changes must trigger a real apply.
* kubeclient 4.13 lacks a dry-run apply argument. A per-instance extension adds only `dryRun=All`
  to its upstream apply transport; real writes still use kubeclient's normal implementation.
  Do not replace this with manual array merges: admission-injected Pod mounts/volumes and
  allocated Service fields must survive updates. Force defaults false; conflicts propagate.
* Preserve Kubernetes default deletion grace. Callers may explicitly supply delete_options.

## Test strategy

* Kind supplies a real Kubernetes API. Dokken clients join its `kind` Docker network and mount
  an ephemeral internal kubeconfig read-only. Never commit kubeconfigs, keys or tokens.
* The default suite covers create, update, delete, repeated convergence and namespace isolation.
* Core/v1 behaviour is platform independent. Preserve current Linux families in Kitchen/CI;
  retire obsolete versions, not their platform families. Unsupported test-image availability is
  a verification limitation rather than proof that the client cannot run on a platform.
* Grounded Docs was unavailable; Context7 and the official kubeclient README/source were used.
* kubeclient itself is Ruby; HTTP/FFI dependencies use native code. Both x86_64 and arm64
  require the platform's Ruby/native toolchain. Local real-API tests use arm64 Docker; hosted
  Linux jobs use x86_64. Native Windows/macOS support remains declared but is not claimed as
  hosted Kitchen coverage. Keep their separate exec configuration rather than silently
  narrowing `supports 'all'`.
* Dokken has no `opensuse-leap-16` image. The verified vendor image `opensuse/leap:16.0`
  preserves current openSUSE-family client coverage. The cookbook needs no systemd daemon,
  so client containers can use a sleeping PID 1.

## Sources

* [kubeclient configuration and operations](https://github.com/ManageIQ/kubeclient)
* [kubeclient 4.13.0 runtime requirements](https://rubygems.org/gems/kubeclient/versions/4.13.0)
* [Kubernetes core API](https://kubernetes.io/docs/reference/kubernetes-api/)
* [Kind v0.33.0 images](https://github.com/kubernetes-sigs/kind/releases/tag/v0.33.0)
* [Server-side apply and ownership](https://kubernetes.io/docs/reference/using-api/server-side-apply/)
* [Server dry-run](https://kubernetes.io/docs/reference/using-api/api-concepts/#dry-run)
