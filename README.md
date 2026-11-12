# kubernetes cookbook

Manage Kubernetes Pods, Services and ReplicationControllers through the core/v1 API.
The cookbook connects to an existing cluster; it does not install Kubernetes.

## Requirements

* Chef Infra Client 17 or later.
* A supported Ruby platform with the build tools needed by kubeclient's native dependencies.
* An operator-controlled kubeconfig with permission to manage the selected resources and namespace.
* An existing Kubernetes cluster exposing core/v1.

Platform support remains independent of the cluster's operating system. Linux integration tests
cover maintained Debian, Ubuntu, RHEL derivatives, Amazon Linux, Fedora and openSUSE images.

## Resources

* [kube_pod](documentation/kube_pod.md)
* [kube_service](documentation/kube_service.md)
* [kube_replication_controller](documentation/kube_replication_controller.md)

All resources accept [connection properties](documentation/connection.md). They create missing
objects, update managed fields when they differ, and leave API defaults intact. Authentication,
validation, immutable-field and connection errors fail convergence.

```ruby
kube_service 'backend' do
  kubeconfig '/etc/chef/kubernetes.conf'
  namespace 'applications'
  port 80
  container_port 8080
  selector 'app=backend'
end
```

Use `:delete` or the existing `:destroy` action to remove an object from the selected namespace.
Deleting one object does not remove its namespace, credentials or objects in other namespaces.

## Upgrading

This is a full custom resource migration. Root node attributes and the removed v1beta1 payload
format are no longer supported. See [migration.md](migration.md) for connection and input changes.

## Testing

See [TESTING.md](TESTING.md) for the real Kind-backed Kitchen workflow. Tests exercise creation,
updates, deletion, namespace isolation and a second converge with no changes.
