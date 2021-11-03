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

- Chef 14+

### Cookbooks

- build-essential

## Attributes

- `['kubernetes']['master']['ip']` - the address used when contacting the kubernetes api
- `['kubernetes']['master']['port']` - the port that will be used when contacting the kubernetes api
- `['kubernetes']['client_version']` - the version of the kubeclient gem to install

## Resources

## Containers and Volumes

The syntax used when specifying containers and volumes is specific to the kubernetes api, for examples on what these can/should look like please see the kubernetes [documentation](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/docs)/[examples](https://github.com/GoogleCloudPlatform/kubernetes/tree/master/examples).

## Labels

Theres a bit of magic in the helper library that allows you to specify labels as either a hash `'this' => 'that', 'app' => 'redis'`, an array of labels `['this=that','app=redis']`, or a comma delimited string `'this=that,app=redis'`. All three will be treated as the same thing when writing your resources.

## License and Author

- Author:: Andre Elizondo ([andre@chef.io](mailto:andre@chef.io))

Copyright 2015, Chef Software, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

```text
http://www.apache.org/licenses/LICENSE-2.0
```

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
