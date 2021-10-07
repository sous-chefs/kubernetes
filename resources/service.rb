#
# Copyright:: 2015-2019, Chef Software, Inc.
# License:: Apache License, Version 2.0
# Authors:  Andre Elizondo (andre@chef.io)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

provides :kube_service
unified_mode true

# how kubernetes will identify the service
property :id, String, name_property: true

# the port that the service will be listening on
property :port, Integer, required: true

# the internal port that kubernetes will route from the service to the container
property :container_port, Integer

# labels added to the service itself
property :labels, [Hash, Array, String], default: {}

# labels that the service will use to select which containers to route to
property :selector, [Hash, Array, String], default: {}

action :create do
  Chef::Log.fatal 'This resource is currently under active development and is not functioning at this time'

  Chef::Log.debug "checking for an existing service named #{new_resource.id}.."

  if !entity_exists?('service', new_resource.id)
    Chef::Log.debug "service #{new_resource.id} does not exist"
    converge_by("create service #{new_resource.id}") do
      Chef::Log.debug kube.create_service(request_hash(new_resource.id, service_options))
    end
  else
    Chef::Log.debug "service #{new_resource.id} already exists"
  end
end

action :destroy do
  Chef::Log.debug "checking for existing service named #{new_resource.id}"

  if !entity_exists?('service', new_resource.id)
    Chef::Log.debug "service #{new_resource.id} does not exist"
  else
    Chef::Log.debug "found service named #{new_resource.id}"
    converge_by("delete service #{new_resource.id}") do
      Chef::Log.debug kube.delete_service(new_resource.id)
    end
  end
end

action_class do
  include K8s::Client

  def service_options
    {
      port: new_resource.port,
      containerPort: !new_resource.container_port.nil? ? new_resource.container_port : new_resource.port,
      selector: parse_labels(new_resource.selector),
      labels: parse_labels(new_resource.labels),
    }
  end
end
