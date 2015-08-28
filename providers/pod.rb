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
  Chef::Log.fatal "This resource is currently under active development and is not functioning at this time"

  Chef::Log.debug "checking for an existing pod named #{new_resource.id}.."

  if !entity_exists?('pod', new_resource.id)

    Chef::Log.debug "pod #{new_resource.id} does not exist"
    converge_by("create pod #{new_resource.id}") do
      Chef::Log.debug request_hash(new_resource.id,pod_options)
      Chef::Log.debug kube.create_pod(request_hash(new_resource.id,pod_options))
      new_resource.updated_by_last_action(true)
    end

  else

    Chef::Log.debug "pod #{new_resource.id} already exists."

  end

end

action :destroy do

  Chef::Log.debug "checking for existing pod named #{new_resource.id}"

  if !entity_exists?('pod', new_resource.id)
    Chef::Log.debug "a pod with the name #{new_resource.id} does not exist"
  else
    Chef::Log.debug "found an existing pod with the name #{new_resource.id}"
    converge_by("delete pod #{new_resource.id}") do
      Chef::Log.debug kube.delete_pod(new_resource.id)
      new_resource.updated_by_last_action(true)
    end
  end

end

def pod_options

  options = {
    desiredState: {
      manifest: {
        id: new_resource.id,
        version: kube_api_version,
        containers: new_resource.containers.is_a?(Array) ? new_resource.containers : Array[new_resource.containers],
      }
    },
    labels: parse_labels(new_resource.labels)
  }

  if !new_resource.volumes.empty?
    options[:desiredState][:manifest][:volumes] = new_resource.volumes.is_a?(Array) ? new_resource.volumes : Array[new_resource.volumes]
  end
  
  options

end