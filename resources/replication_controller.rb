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

provides :kube_replication_controller

# the id that kubernetes will identify the controller with
attribute :id, name_attribute: true, kind_of: String

# a hash or list of hashes with container/volume information that will be used when ensuring the states of replicas
attribute :containers, kind_of: [Hash,Array], required: true
attribute :volumes, default: {}, kind_of: Hash

# the disired number of pods that the controller will ensure exist
attribute :replicas, default: 1, kind_of: Fixnum

# how the controller will check the number of replicas that exist, this is a label
attribute :selector, default: {}, kind_of: [Hash,Array,String]

# labels that will be added to the replica and pods_labels that will be added to the pods themselves
# selector labels will automatically be added to pod_labels if it does not already exist
attribute :labels, default: {}, kind_of: [Hash,Array,String]
attribute :pod_labels, default: {}, kind_of: [Hash,Array,String]