actions :create, :destroy
default_action :create

provides :kube_replication_controller

attribute :id, name_attribute: true, kind_of: String
attribute :containers, kind_of: [Hash,Array], required: true
attribute :volumes, default: {}, kind_of: Hash
attribute :replicas, default: 1, kind_of: Fixnum
attribute :selector, default: {}, kind_of: [Hash,Array,String]
attribute :labels, default: {}, kind_of: [Hash,Array,String]
attribute :pod_labels, default: {}, kind_of: [Hash,Array,String]