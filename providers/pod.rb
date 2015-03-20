include K8s::Client

use_inline_resources

action :create do

  Chef::Log.debug "checking for an existing pod named #{new_resource.id}.."

  if !entity_exists?('pod', new_resource.id)

    Chef::Log.debug "pod #{new_resource.id} does not exist"
    Chef::Log.debug "creating pod #{new_resource.id}.."
    Chef::Log.debug request_hash(new_resource.id,pod_options)
    Chef::Log.debug kube.create_pod(request_hash(new_resource.id,pod_options))
    new_resource.updated_by_last_action(true)

  else

    Chef::Log.debug "pod #{new_resource.id} already exists."

  end

end

action :destroy do

  Chef::Log.debug "checking for existing pod named #{new_resource.id}"

  if !entity_exists?('pod', new_resource.id)
    Chef::Log.debug "a pod with the name #{new_resource.id} does not exist"
  else
    Chef::Log.debug "found an existing pod with the name #{new_resource.id}, deleting.."
    Chef::Log.debug kube.delete_pod(new_resource.id)
    new_resource.updated_by_last_action(true)
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