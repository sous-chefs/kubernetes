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

resource_name :kube_node

property :master_ip, String, required: true

action :create do
  # pull down flanneld container
  docker_image 'flannel' do
    repo 'quay.io/coreos/flannel'
    tag '0.5.0'
  end

  docker_container 'flannel' do
    network_mode 'host'
    repo 'quay.io/coreos/flannel'
    tag '0.5.0'
    privileged true
    binds ['/dev/net:/dev/net']
    restart_policy 'always'
    action :run
    command "/opt/bin/flanneld --etcd-endpoints=http://#{new_resource.master_ip}:4001"
  end

  ruby_block 'gather-flannel-env' do
    block do
      node.run_state[:flannel] = { bip: '', mtu: '' }
      flannel_id = `docker ps -a| grep flannel | cut -d ' ' -f 1`.strip
      env = `docker exec #{flannel_id} cat /run/flannel/subnet.env`
      raise 'Unable to gather flannel networking information!' if env.empty?
      env = env.split
      node.run_state[:flannel][:bip] = env[0].split('=')[1].strip
      node.run_state[:flannel][:mtu] = env[1].split('=')[1].strip
    end
    retries 5
  end

  package 'bridge-utils'

  execute 'delete-existing-docker-bridge' do
    command 'ifconfig docker0 down; brctl delbr docker0'
    only_if 'brctl show | grep -q docker0'
  end

  docker_service 'kubernetes' do
    bip lazy { node.run_state[:flannel][:bip] }
    mtu lazy { node.run_state[:flannel][:mtu] }
    action [:create, :start]
    notifies :run, 'docker_container[flannel]', :immediately
  end

  # pull down the kubernetes container
  docker_image 'hyperkube' do
    repo 'gcr.io/google_containers/hyperkube'
    tag 'v0.21.2'
  end

  docker_container 'kubelet' do
    network_mode 'host'
    repo 'gcr.io/google_containers/hyperkube'
    tag 'v0.21.2'
    binds ['/var/run/docker.sock:/var/run/docker.sock']
    command "/hyperkube kubelet --api_servers=http://#{new_resource.master_ip}:8080 --v=2 --address=0.0.0.0 --enable_server --hostname_override=#{node[:ipaddress]}"
    restart_policy 'always'
    action :run
  end

  docker_container 'proxy' do
    network_mode 'host'
    repo 'gcr.io/google_containers/hyperkube'
    tag 'v0.21.2'
    privileged true
    restart_policy 'always'
    command "/hyperkube proxy --master=http://#{new_resource.master_ip}:8080 --v=2"
    action :run
  end
end

action :destroy do
  %w(flannel kubelet proxy).each do |con|
    docker_container con do
      action :stop
    end
  end
end
