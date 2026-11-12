# frozen_string_literal: true

provides :kube_service
unified_mode true

use '_partial/_connection'

property :port, Integer
property :container_port, Integer
property :selector, [Hash, Array, String], default: {}
property :protocol, String, equal_to: %w(TCP UDP SCTP), default: 'TCP'

action :create do
  raise ArgumentError, 'port is required for :create' unless new_resource.port

  manage_resource('service', 'Service',
                  ports: [{ port: new_resource.port, targetPort: new_resource.container_port || new_resource.port,
                            protocol: new_resource.protocol }],
                  selector: parse_labels(new_resource.selector))
end

action :destroy do
  delete_resource('service')
end

action :delete do
  delete_resource('service')
end

action_class do
  include KubernetesCookbook::Helpers
end
