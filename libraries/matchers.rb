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

if defined?(ChefSpec)
  #pod
  def create_kube_pod(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kube_pod, :create, resource_name)
  end

  def destroy_kube_pod(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kube_pod, :destroy, resource_name)
  end

  #replication controller
  def create_kube_replication_controller(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kube_replication_controller, :create, resource_name)
  end

  def destroy_kube_replication_controller(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kube_replication_controller, :destroy, resource_name)
  end

  #service
  def create_kube_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kube_service, :create, resource_name)
  end

  def destroy_kube_service(resource_name)
    ChefSpec::Matchers::ResourceMatcher.new(:kube_service, :destroy, resource_name)
  end

end