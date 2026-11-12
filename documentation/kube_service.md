# kube_service

Manage a core/v1 ClusterIP Service and its selector in the selected namespace. API-assigned
addresses and object metadata are preserved during updates.

## Actions

* `:create` (default): create a missing Service or update changed managed fields.
* `:destroy`, `:delete`: remove the Service. An absent Service requires no change.

## Properties

Use the shared [connection properties](connection.md), plus:

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `port` | Integer | Required for create | Service port |
| `container_port` | Integer | `port` | Target container port |
| `protocol` | String | `TCP` | `TCP`, `UDP` or `SCTP` |
| `selector` | Hash, Array, String | `{}` | Declared Pod selector, using the label input formats |

```ruby
kube_service 'backend' do
  kubeconfig '/etc/chef/kubernetes.conf'
  namespace 'applications'
  port 80
  container_port 8080
  selector 'app=backend'
end
```

Deletion needs no port:

```ruby
kube_service 'backend' do
  kubeconfig '/etc/chef/kubernetes.conf'
  action :destroy
end
```
