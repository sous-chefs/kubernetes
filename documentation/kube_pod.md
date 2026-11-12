# kube_pod

Create, update or delete a core/v1 Pod in the selected namespace.

## Actions

* `:create` (default): create a missing Pod or update changed managed fields.
* `:destroy`, `:delete`: remove the Pod. An absent Pod requires no change.

Kubernetes rejects changes to immutable Pod fields. Those errors are returned to Chef rather
than deleting and replacing a running Pod automatically.

## Properties

Use the shared [connection properties](connection.md), plus:

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `containers` | Hash, Array | `[]` | One or more core/v1 container specifications; required for create |
| `volumes` | Hash, Array | `[]` | Core/v1 volume specifications |

```ruby
kube_pod 'web' do
  kubeconfig '/etc/chef/kubernetes.conf'
  namespace 'applications'
  containers [{ name: 'web', image: 'nginx:stable' }]
  labels 'app' => 'web'
end
```

Deletion needs no container specification:

```ruby
kube_pod 'web' do
  kubeconfig '/etc/chef/kubernetes.conf'
  namespace 'applications'
  action :delete
end
```
