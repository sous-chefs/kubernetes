# Kubernetes Replication Controller (`kube_replication_controller`)

Replication controllers are used to maintain a consistent amount of a pod at any given time using selector labels

## Actions

- `create` - default. ensures the replication controller is created
- `destroy` - ensures the replication controller does not exist

## Properties

- `id` - name attribute. The identifier used when managing the replication controller
- `containers` - **required** a hash of container information that will be used when the replication controller needs to generate new pods
- `volumes` - a hash of volume information used in generating new pods
- `selector` - how the replication controller will ensure that enough replicas exist
- `pod_labels` - specify the labels added to the individual pods that are spawned off
- `labels` - specify the labels that will be added to the replication controller

## Examples

```ruby
kube_replication_controller "master-controller" do
  containers({
    name: 'redis-master',
    image: 'dockerfile/redis'
  })
  replicas 2
  selector 'role' => 'master','app' => 'redis'
  labels ['aww=yiss','motha-freakin=breadcrumbs']
  action [:destroy,:create]
end
```
