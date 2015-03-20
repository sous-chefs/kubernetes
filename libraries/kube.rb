

module K8s
  module Client

    def kube
      @@kube ||= create_kube_client(self.kube_url,self.kube_api_version)
    end

    def kube_url
      "http://#{node['k8s']['master']['ip']}:#{node['k8s']['master']['port']}/api"
    end

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
    #  e.g ['app=my-app','db=that-db'] => {'app' => 'my-app', 'db' => 'that-db'}
    #     or "app=my-app,db=that-db" => {'app' => 'my-app', 'db' => 'that-db'}
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

    def create_kube_client(url, version)
      begin
        require 'kubeclient'
      rescue LoadError
        Chef::Log.error("Missing gem 'kubeclient'. Use the default k8s recipe to install it.")
      end

      validate_endpoint(::Kubeclient::Client.new(url,version))

    end

    def validate_endpoint(endpoint)
      begin
        endpoint.get_endpoints
      rescue
        Chef::Log.error "Unable to connect to the kubernetes api at #{endpoint.api_endpoint.to_s}!"
      end

      endpoint
    end

  end
end