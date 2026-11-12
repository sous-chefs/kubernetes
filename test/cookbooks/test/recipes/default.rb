# frozen_string_literal: true

config_path = '/tmp/kitchen-kubeconfig'
namespace = 'cookbook-test'
containers = [{ name: 'pause', image: 'registry.k8s.io/pause:3.10' }]

%w(created updated).each do |state|
  kube_pod "#{state}-pod" do
    kubeconfig config_path
    namespace namespace
    containers containers
    labels 'phase' => 'managed'
  end

  kube_service "#{state}-service" do
    kubeconfig config_path
    namespace namespace
    port 9090
    container_port 8080
    selector 'app=test'
    labels 'phase' => 'managed'
  end

  kube_replication_controller "#{state}-controller" do
    kubeconfig config_path
    namespace namespace
    containers containers
    replicas 0
    selector 'app=test'
    labels 'phase' => 'managed'
  end
end

kube_pod 'removed-pod' do
  kubeconfig config_path
  namespace namespace
  action :destroy
end

kube_service 'removed-service' do
  kubeconfig config_path
  namespace namespace
  action :delete
end

kube_replication_controller 'removed-controller' do
  kubeconfig config_path
  namespace namespace
  action :destroy
end

ruby_block 'capture API evidence' do
  not_if { ::File.exist?('/tmp/kubernetes-evidence.json') }
  block do
    require 'kubeclient'
    context = Kubeclient::Config.read(config_path).context
    client = Kubeclient::Client.new(context.api_endpoint, 'v1', ssl_options: context.ssl_options, auth_options: context.auth_options)
    deadline = ::Time.now + 30
    evidence = nil
    loop do
      evidence = %w(pods services replication_controllers).to_h do |entity|
        [entity, client.public_send("get_#{entity}", namespace: namespace).map(&:to_h)]
      end
      break unless evidence.values.flatten.any? { |item| item.fetch(:metadata).fetch(:name).start_with?('removed-') }
      raise 'Timed out waiting for Kubernetes fixture deletion' if ::Time.now >= deadline

      sleep 0.2
    end
    evidence['api_version'] = client.get_pod('created-pod', namespace).apiVersion
    %w(pods services replication_controllers).each do |entity|
      evidence["other_#{entity}"] = client.public_send("get_#{entity}", namespace: 'cookbook-other').map(&:to_h)
    end
    ::File.write('/tmp/kubernetes-evidence.json', JSON.generate(evidence))
  end
end
