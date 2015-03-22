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

module K8s
  module Client

    ##
    #
    #  The primary method that will return the current active client
    #
    def kube
      @@kube ||= create_kube_client(self.kube_url,self.kube_api_version)
    end

    ##
    #
    #  There's probably a better way to do this, but this method will return the url used to access the kubernetes api
    #
    def kube_url
      "http://#{node['k8s']['master']['ip']}:#{node['k8s']['master']['port']}/api"
    end

    ##
    # 
    #   Return the current version of the kubernetes in use
    #
    #  TODO: as the v1beta3 becomes more of the standard, switch over to that one.
    #
    def kube_api_version
      "v1beta1"
    end

    def entity_exists?(entity_type, entity_name)
      begin
        !!self.kube.send("get_#{entity_type}", entity_name)
      rescue KubeException
        false
      end
    end

    ##
    #
    #  Repeatedly pass in the apiVersion info into each request, otherwise a 422 is returned.
    #
    def request_hash(name,options)
      h = {
        id: name,
        apiVersion: self.kube_api_version
      }.merge!(options)
      Chef::Log.debug h
      h
    end

    ##
    #
    #  Make an easier way for people to pass in labels instead of
    #  needing to pass in a hash each time.
    #  In this case users can pass in a normal hash, an array of labels, or a string
    #
    #  e.g ['app=my-app','db=that-db'] => {'app' => 'my-app', 'db' => 'that-db'}
    #     or "app=my-app,db=that-db" => {'app' => 'my-app', 'db' => 'that-db'}
    #
    #  TODO: add some validity checking for labels, in case someone passes something other than a key/value string/array
    #
    def parse_labels(labels)
      if labels.is_a? Hash
        labels
      elsif labels.is_a? Array
        Hash[labels.map { |i| i.split('=') }]
      elsif labels.is_a? String
        if labels.include?(',')
          Hash[labels.split(',').map { |i| i.split('=') }]
        else
          Hash[Array[labels.split('=')]]
        end
      end
    end

    private

    ##
    #
    #  Initiate a client and validate that it responds to requests.
    #
    def create_kube_client(url, version)
      begin
        require 'kubeclient'
      rescue LoadError
        Chef::Log.error("Missing gem 'kubeclient'. Use the default k8s recipe to install it.")
      end

      validate_endpoint(::Kubeclient::Client.new(url,version))

    end

    ##
    #
    #  Validate the kube_url by getting the endpoints.
    #
    def validate_endpoint(endpoint)
      begin
        Chef::Log.debug endpoint.get_endpoints
      rescue
        Chef::Log.error "Unable to connect to the kubernetes api at #{endpoint.api_endpoint.to_s}"
      end

      endpoint
    end

  end
end