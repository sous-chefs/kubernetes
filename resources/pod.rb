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

actions :create, :destroy
default_action :create

provides :kube_pod

# the name that will be used to identify the pod
attribute :id, name_attribute: true, kind_of: String

# a hash/array of hashes of containers/volumes that kubernetes will add to the pod
attribute :containers, kind_of: [Hash,Array], required: true
attribute :volumes, default: {}, kind_of: Hash

# labels that will be added to the pod
attribute :labels, default: {}, kind_of: [Hash,Array,String]

