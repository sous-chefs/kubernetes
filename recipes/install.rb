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

include_recipe "#{cookbook_name}::default"

execute "yum-config-manager --enable rhui-REGION-rhel-server-extras"

package 'docker' do
  version '1.6.0-11.el7'
end

package 'kubernetes' do
  version '0.15.0-0.3.git0ea87e4.el7'
end

package 'etcd' do
  version '2.0.9-2.el7'
end

package 'flannel' do
  version '0.2.0-7.el7'
end