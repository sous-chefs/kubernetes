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

require 'spec_helper'

describe 'kubernetes::master' do
  context 'starts and enables the kubernetes master services' do
    let(:chef_run) do
      ChefSpec::ServerRunner.new.converge(described_recipe)
    end

    it 'starts and enables etcd' do
      expect(chef_run).to start_service('etcd')
      expect(chef_run).to enable_service('etcd')
    end

    it 'starts and enables the apiserver' do
      expect(chef_run).to start_service('kube-apiserver')
      expect(chef_run).to enable_service('kube-apiserver')
    end

    it 'starts and enables the controller-manager' do
      expect(chef_run).to start_service('kube-controller-manager')
      expect(chef_run).to enable_service('kube-controller-manager')
    end

    it 'starts and enables the scheduler' do
      expect(chef_run).to start_service('kube-scheduler')
      expect(chef_run).to enable_service('kube-scheduler')
    end

    it 'writes apiserver config' do
      expect(chef_run).to render_file('/etc/kubernetes/apiserver')
    end
  end
end
