# frozen_string_literal: true

provides :kube_pod
unified_mode true

use '_partial/_connection'

property :containers, [Hash, Array], default: []
property :volumes, [Hash, Array], default: []

action :create do
  raise ArgumentError, 'containers is required for :create' if new_resource.containers.empty?

  spec = { containers: new_resource.containers.is_a?(Hash) ? [new_resource.containers] : new_resource.containers }
  spec[:volumes] = new_resource.volumes.is_a?(Hash) ? [new_resource.volumes] : new_resource.volumes if new_resource.property_is_set?(:volumes)
  manage_resource('pod', 'Pod', spec)
end

action :destroy do
  delete_resource('pod')
end

action :delete do
  delete_resource('pod')
end

action_class do
  include KubernetesCookbook::Helpers
end
