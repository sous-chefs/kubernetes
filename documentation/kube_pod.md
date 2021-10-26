# Kubernetes Pod (`kube_pod`)

Manage a standalone Kubernetes pod, there is no redundancy in a pod and is simply used to specify a group of containers to be jointly deployed on a host.

## Actions

- `create` - default. ensures the pod is created
- `destroy` - ensures the pod does not exist

## Properties

- `id` - name attribute. The identifier used when managing the pod
- `containers` - **required** a hash of container information that will be used when creating the pod
- `volumes` - a hash of volume information used when specifying storage for containers
- `labels` - specify the labels that will be added to the pod

## Examples

```ruby
kube_pod "my-pod" do
  containers({
    name: 'pod-member',
    image: 'my/image'
  })
  labels "aww=yiss"
  action [:destroy,:create]
end
```
