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

provides :kube_replication_controller
unified_mode true

# the id that kubernetes will identify the controller with
property :id, String, name_property: true

# a hash or list of hashes with container/volume information that will be used when ensuring the states of replicas
property :containers, [Hash, Array], required: true
property :volumes, Hash, default: {}

# the disired number of pods that the controller will ensure exist
property :replicas, Integer, default: 1

# how the controller will check the number of replicas that exist, this is a label
property :selector, [Hash, Array, String], default: {}

# labels that will be added to the replica and pods_labels that will be added to the pods themselves
# selector labels will automatically be added to pod_labels if it does not already exist
property :labels, [Hash, Array, String], default: {}
property :pod_labels, [Hash, Array, String], default: {}

action :create do
  Chef::Log.fatal 'This resource is currently under active development and is not functioning at this time'

  Chef::Log.debug "checking for existing replication controller named #{new_resource.id}.."

  if !entity_exists?('replication_controller', new_resource.id)
    Chef::Log.debug "no existing replication controller named #{new_resource.id}"
    converge_by("create replication controller #{new_resource.id}") do
      Chef::Log.debug kube.create_replication_controller(request_hash(new_resource.id, rc_options))
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
    end
  end
end

action_class do
  include K8s::Client

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
            },
          },
          labels: parse_labels(new_resource.pod_labels).merge!(parse_labels(new_resource.selector)),
        },
      },
      labels: parse_labels(new_resource.labels),
    }

    unless new_resource.volumes.empty?
      options[:desiredState][:podTemplate][:desiredState][:manifest][:volumes] = new_resource.volumes.is_a?(Array) ? new_resource.volumes : Array[new_resource.volumes]
    end

    options
  end
end
