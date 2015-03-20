include K8s::Client

use_inline_resources

action :create do 
  
  Chef::Log.debug "checking for an existing service named #{new_resource.id}.."
  
  if !entity_exists?('service', new_resource.id)

    Chef::Log.debug "service #{new_resource.id} does not exist"
    Chef::Log.debug "creating service #{new_resource.id}.."
    Chef::Log.debug kube.create_service(request_hash(new_resource.id,service_options))
    new_resource.updated_by_last_action(true)
  else
    Chef::Log.debug "service #{new_resource.id} already exists"
  end

end

action :destroy do

  Chef::Log.debug "checking for existing service named #{new_resource.id}"

  if !entity_exists?('service', new_resource.id)
    Chef::Log.debug "service #{new_resource.id} does not exist"
  else
    Chef::Log.debug "found service named #{new_resource.id}, deleting.."
    Chef::Log.debug kube.delete_service(new_resource.id)
    new_resource.updated_by_last_action(true)
  end

end

def service_options
  {
    port: new_resource.port,
    containerPort: !new_resource.container_port.nil? ? new_resource.container_port : new_resource.port,
    selector: parse_labels(new_resource.selector),
    labels: parse_labels(new_resource.labels)
  }
end