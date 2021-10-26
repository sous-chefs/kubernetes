# Kubernetes Service (`kube_service`)

Deploy a Kubernetes service, which can be used as a basic container load balancer that routes traffic based on selector labels

## Actions

- `create` - default. ensure the service exists
- `destroy` - ensure the service does not exist

## Properties

- `id` - name attribute. The identifier used when managing the service
- `port` - **required** the port that the service will listen on for traffic
- `container_port` - what port the service will route to on the selected containers _defaults to the port that the service is listening on_
- `selector` - labels that the service will use when choosing containers to route traffic to
- `labels` - labels that will be added to the service

## Examples

```ruby
kube_service "backend-service" do
  port 8005
  selector 'role' => 'backend'
end
```
