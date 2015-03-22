#
# Copyright:: Copyright (c) 2015 Chef Software, Inc.
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

include K8s::Client

use_inline_resources

action :create do

  Chef::Log.debug "checking for existing replication controller named #{new_resource.id}.."

  if !entity_exists?('replication_controller', new_resource.id)
    Chef::Log.debug "no existing replication controller named #{new_resource.id}"
    converge_by("create replication controller #{new_resource.id}") do
      Chef::Log.debug kube.create_replication_controller(request_hash(new_resource.id,rc_options))
      new_resource.updated_by_last_action(true)
    end
  else
    Chef::Log.debug "an existing replication controller was found named #{new_resource.id}"
  end

end

action :destroy do

  Chef::Log.debug "checking for existing replication controller named #{new_resource.id}.."

  if !entity_exists?('replication_controller', new_resource.id)
    Chef::Log.debug "replication controller #{new_resource.id} does not exist"
  else
    Chef::Log.debug "found replication controller #{new_resource.id}"
    converge_by("delete replication controller #{new_resource.id}") do
      Chef::Log.debug kube.delete_replication_controller(new_resource.id)
      new_resource.updated_by_last_action(true)
    end
  end

end

def rc_options
  options = {
    desiredState: {
      replicas: new_resource.replicas,
      replicaSelector: parse_labels(new_resource.selector),
      podTemplate: {
        desiredState: {
          manifest: {
            version: kube_api_version,
            id: new_resource.id,
            containers: new_resource.containers.is_a?(Array) ? new_resource.containers : Array[new_resource.containers],
          }
        },
        labels: parse_labels(new_resource.pod_labels).merge!(parse_labels(new_resource.selector))
      }
    },
    labels: parse_labels(new_resource.labels)
  }

  if !new_resource.volumes.empty?
    options[:desiredState][:podTemplate][:desiredState][:manifest][:volumes] = new_resource.volumes.is_a?(Array) ? new_resource.volumes : Array[new_resource.volumes]
  end

  options
end