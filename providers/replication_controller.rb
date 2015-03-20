include K8s::Client

use_inline_resources

action :create do

  Chef::Log.debug "checking for existing replication controller named #{new_resource.id}.."

  if !entity_exists?('replication_controller', new_resource.id)
    Chef::Log.debug "no existing replication controller named #{new_resource.id}"
    Chef::Log.debug "creating replication controller #{new_resource.id}.."
    Chef::Log.debug kube.create_replication_controller(request_hash(new_resource.id,rc_options))
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug "an existing replication controller was found named #{new_resource.id}"
  end

end

action :destroy do

  Chef::Log.debug "checking for existing replication controller named #{new_resource.id}.."

  if !entity_exists?('replication_controller', new_resource.id)
    Chef::Log.debug "replication controller #{new_resource.id} does not exist"
  else
    Chef::Log.debug "found replication controller #{new_resource.id}, deleting.."
    Chef::Log.debug kube.delete_replication_controller(new_resource.id)
    new_resource.updated_by_last_action(true)
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