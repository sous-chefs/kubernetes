actions :create, :destroy
default_action :create

provides :kube_service

attribute :id, name_attribute: true, kind_of: String
attribute :port, required: true, kind_of: Fixnum
attribute :container_port, kind_of: Fixnum
attribute :labels, default: {}, kind_of: [Hash,Array,String]
attribute :selector, default: {}, kind_of: [Hash,Array,String]