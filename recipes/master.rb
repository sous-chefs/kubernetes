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
include_recipe "selinux::disabled"
include_recipe "#{cookbook_name}::install"

%w[etcd kube-apiserver kube-controller-manager kube-scheduler].each do |service|
  service service do
    action [:enable,:start]
  end
end

template '/etc/kubernetes/apiserver' do
    source 'apiserver.erb'
    notifies :restart, 'service[kube-apiserver]', :immediately
end