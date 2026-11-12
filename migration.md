# Migrating to Kubernetes cookbook 3

Version 3 repairs the previously non-functional resources and replaces the removed v1beta1 API
with core/v1. It removes the root attributes directory and requires Chef 17 or later.
The unused legacy `apiserver.erb` template is removed; cluster installation remains external.

## Connection configuration

Replace `node['kubernetes']['master']['ip']`, `master.port` and `client_version` attributes with
resource properties. Supply a kubeconfig that contains the cluster endpoint, CA and credentials.
There is no default unauthenticated HTTP connection to localhost.

```ruby
kube_service 'backend' do
  kubeconfig '/etc/chef/kubernetes.conf'
  context 'production'
  namespace 'applications'
  port 80
  container_port 8080
  selector 'app=backend'
end
```

The kubeconfig is operator-managed and may contain credential plugins. Do not pass untrusted
configuration. The old unused `disable_selinux` attribute has no replacement: this cookbook
manages a remote API and does not change host security settings.

## Resource inputs and behaviour

* Existing resource names, `id`, label formats and `:create` / `:destroy` actions remain.
* `:delete` is also accepted. Deletion no longer requires create-only ports or containers.
* Container and volume properties now contain core/v1 specifications. Legacy `desiredState`,
  `manifest`, `replicaSelector` and v1beta1 field names are removed.
* Labels, selectors and declared fields are reconciled when an object exists. API defaults,
  assigned Service addresses and object metadata remain intact.
* Resource errors fail convergence. Only HTTP 404 means that an object is absent.
* Immutable Pod changes require an explicit operator replacement; they do not trigger an
  automatic destructive replacement.
* The cookbook installs kubeclient 4.13.0 and native build tools. Kubernetes itself remains
  separately installed and operated.
