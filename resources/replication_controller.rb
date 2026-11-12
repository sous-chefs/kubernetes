# frozen_string_literal: true

provides :kube_replication_controller
unified_mode true

use '_partial/_connection'

property :containers, [Hash, Array], default: []
property :volumes, [Hash, Array], default: []
property :replicas, Integer, default: 1
property :selector, [Hash, Array, String], default: lazy { { 'app' => id } }
property :pod_labels, [Hash, Array, String], default: {}

action :create do
  raise ArgumentError, 'containers is required for :create' if new_resource.containers.empty?

  selector = parse_labels(new_resource.selector)
  pod_spec = { containers: new_resource.containers.is_a?(Hash) ? [new_resource.containers] : new_resource.containers }
  pod_spec[:volumes] = new_resource.volumes.is_a?(Hash) ? [new_resource.volumes] : new_resource.volumes if new_resource.property_is_set?(:volumes)
  manage_resource('replication_controller', 'ReplicationController',
                  replicas: new_resource.replicas, selector: selector,
                  template: {
                    metadata: { labels: parse_labels(new_resource.pod_labels).merge(selector) },
                    spec: pod_spec,
                  })
end

action :destroy do
  delete_resource('replication_controller')
end

action :delete do
  delete_resource('replication_controller')
end

action_class do
  include KubernetesCookbook::Helpers
end
