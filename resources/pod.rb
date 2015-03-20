actions :create, :destroy
default_action :create

provides :kube_pod

attribute :id, name_attribute: true, kind_of: String
attribute :containers, kind_of: [Hash,Array], required: true
attribute :volumes, default: {}, kind_of: Hash
attribute :labels, default: {}, kind_of: [Hash,Array,String]

