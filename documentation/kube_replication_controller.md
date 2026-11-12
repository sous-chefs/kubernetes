# kube_replication_controller

Manage an existing core/v1 ReplicationController API. This resource remains available for
existing users; Kubernetes recommends Deployments for most new applications.

## Actions

* `:create` (default): create or update the controller's managed fields and Pod template.
* `:destroy`, `:delete`: remove the controller and let Kubernetes delete its dependent Pods.

## Properties

Use the shared [connection properties](connection.md), plus:

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `containers` | Hash, Array | `[]` | Core/v1 containers; required for create |
| `volumes` | Hash, Array | `[]` | Core/v1 volumes |
| `replicas` | Integer | `1` | Desired number of Pods |
| `selector` | Hash, Array, String | `{ 'app' => id }` | Complete selector |
| `pod_labels` | Hash, Array, String | `{}` | Pod template labels; selector labels are included automatically |

```ruby
kube_replication_controller 'workers' do
  kubeconfig '/etc/chef/kubernetes.conf'
  namespace 'applications'
  containers [{ name: 'worker', image: 'busybox:stable', command: ['sleep', '3600'] }]
  replicas 2
  selector 'app=workers'
end
```
