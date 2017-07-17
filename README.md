# kubernetes Cookbook

[![Build Status](https://travis-ci.org/chef-cookbooks/kubernetes.svg?branch=master)](https://travis-ci.org/chef-cookbooks/kubernetes) [![Cookbook Version](https://img.shields.io/cookbook/v/kubernetes.svg)](https://supermarket.chef.io/cookbooks/kubernetes)

Resources for deploying various Kubernetes entities, these resources are designed to be ran on the kubernetes master but can be ran anywhere that has access to a kubernetes api by changing the `['kubernetes']['master']['ip']` attribute. These resources utilize the kubeclient ruby gem and run against the v1beta1 api.

Currently broken resources: (waiting on support for v1 api through kubeclient gem)

- Kubernetes Pod (`kube_pod`)
- Kubernetes Replication Controller (`kube_replication_controller`)
- Kubernetes Service (`kube_service`)

## Requirements

### Platforms

- All platforms where kubeclient gem can be installed

### Chef

- Chef 12.9+

### Cookbooks

- build-essential

## Attributes

- `['kubernetes']['master']['ip']` - the address used when contacting the kubernetes api
- `['kubernetes']['master']['port']` - the port that will be used when contacting the kubernetes api
- `['kubernetes']['client_version']` - the version of the kubeclient gem to install

## Resources

### Kubernetes Pod (`kube_pod`)

Manage a standalone Kubernetes pod, there is no redundancy in a pod and is simply used to specify a group of containers to be jointly deployed on a host.

#### Actions

- `create` - default. ensures the pod is created
- `destroy` - ensures the pod does not exist

#### Attribute Parameters

- `id` - name attribute. The identifier used when managing the pod
- `containers` - **required** a hash of container information that will be used when creating the pod
- `volumes` - a hash of volume information used when specifying storage for containers
- `labels` - specify the labels that will be added to the pod

#### Examples

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

### Kubernetes Replication Controller (`kube_replication_controller`)

Replication controllers are used to maintain a consistent amount of a pod at any given time using selector labels

#### Actions

- `create` - default. ensures the replication controller is created
- `destroy` - ensures the replication controller does not exist

#### Attribute Parameters

- `id` - name attribute. The identifier used when managing the replication controller
- `containers` - **required** a hash of container information that will be used when the replication controller needs to generate new pods
- `volumes` - a hash of volume information used in generating new pods
- `selector` - how the replication controller will ensure that enough replicas exist
- `pod_labels` - specify the labels added to the individual pods that are spawned off
- `labels` - specify the labels that will be added to the replication controller

#### Examples

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

### Kubernetes Service (`kube_service`)

Deploy a Kubernetes service, which can be used as a basic container load balancer that routes traffic based on selector labels

#### Actions

- `create` - default. ensure the service exists
- `destroy` - ensure the service does not exist

#### Attribute Parameters

- `id` - name attribute. The identifier used when managing the service
- `port` - **required** the port that the service will listen on for traffic
- `container_port` - what port the service will route to on the selected containers _defaults to the port that the service is listening on_
- `selector` - labels that the service will use when choosing containers to route traffic to
- `labels` - labels that will be added to the service

#### Examples

```ruby
kube_service "backend-service" do
  port 8005
  selector 'role' => 'backend'
end
```

## Containers and Volumes

The syntax used when specifying containers and volumes is specific to the kubernetes api, for examples on what these can/should look like please see the kubernetes [documentation](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/docs)/[examples](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples).

## Labels

Theres a bit of magic in the helper library that allows you to specify labels as either a hash `'this' => 'that', 'app' => 'redis'`, an array of labels `['this=that','app=redis']`, or a comma delimited string `'this=that,app=redis'`. All three will be treated as the same thing when writing your resources.

## License and Author

- Author:: Andre Elizondo ([andre@chef.io](mailto:andre@chef.io))

Copyright 2015, Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

```
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
