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

kube_pod "yup" do
  action :nothing
end

kube_service "redis-master" do
  port 500
  action [:destroy,:create]
  labels ['aww=yiss','this=is-awesome']
end

kube_service "redis-blah-blah" do
  port 1234
  container_port 5532
  action [:destroy,:create]
  labels 'aww' => 'yiss'
  selector 'aww=yiss'
end


kube_pod "test-group" do
  containers({
    name: 'redis-master',
    image: 'dockerfile/redis'
  })
  labels "aww=yiss"
  action [:destroy,:create]
end

kube_replication_controller "this-controls-the-things" do
  containers({
    name: 'controlled-by-the-things',
    image: 'dockerfile/redis'
  })
  pod_labels 'app=thisthing'
  selector 'controlled-by=thethings'
  replicas 0
  labels 'yup' => 'the-things'
  action [:destroy,:create]
end