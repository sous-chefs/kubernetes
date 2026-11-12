# frozen_string_literal: true

require 'spec_helper'

describe 'Kubernetes core/v1 resources' do
  step_into :kube_pod, :kube_service, :kube_replication_controller
  platform 'ubuntu', '24.04'

  let(:client) { double('Kubernetes API') }
  let(:context) { double(api_endpoint: 'https://cluster.example/api', ssl_options: { verify_ssl: 1 }, auth_options: {}) }

  before do
    config = double('config', context: context)
    allow(Kubeclient::Config).to receive(:read).with('/tmp/test-kubeconfig').and_return(config)
    allow(Kubeclient::Client).to receive(:new).and_return(client)
    %w(pod service replication_controller).each do |entity|
      allow(client).to receive("get_#{entity}").and_raise(Kubeclient::ResourceNotFoundError.new(404, 'absent', nil))
      allow(client).to receive("apply_#{entity}")
    end
  end

  recipe do
    kube_pod 'web' do
      kubeconfig '/tmp/test-kubeconfig'
      namespace 'applications'
      containers(name: 'web', image: 'nginx:stable')
    end

    kube_service 'web' do
      kubeconfig '/tmp/test-kubeconfig'
      namespace 'applications'
      port 80
      container_port 8080
      selector 'app=web'
    end

    kube_replication_controller 'workers' do
      kubeconfig '/tmp/test-kubeconfig'
      namespace 'applications'
      containers [{ name: 'worker', image: 'busybox:stable' }]
      replicas 2
      selector ['app=workers']
    end
  end

  it 'creates Pods using core/v1 and the selected namespace' do
    chef_run
    expect(client).to have_received(:apply_pod) do |pod|
      expect(pod[:apiVersion]).to eq('v1')
      expect(pod[:metadata][:namespace]).to eq('applications')
      expect(pod[:spec][:containers].first[:name]).to eq('web')
    end
  end

  it 'creates Services with core/v1 ports and selectors' do
    chef_run
    expect(client).to have_received(:apply_service) do |service|
      expect(service[:spec][:ports].first[:targetPort]).to eq(8080)
      expect(service[:spec][:selector]['app']).to eq('web')
    end
  end

  it 'creates ReplicationControllers with a matching Pod template' do
    chef_run
    expect(client).to have_received(:apply_replication_controller) do |controller|
      expect(controller[:spec][:replicas]).to eq(2)
      expect(controller[:spec][:template][:metadata][:labels]['app']).to eq('workers')
    end
  end

  it 'passes TLS and authentication settings to the maintained client' do
    chef_run
    expect(Kubeclient::Client).to have_received(:new).with('https://cluster.example/api', 'v1',
                                                         ssl_options: { verify_ssl: 1 }, auth_options: {}).exactly(3).times
  end

  context 'when the API refuses access' do
    before do
      allow(client).to receive(:get_pod).and_raise(Kubeclient::HttpError.new(403, 'forbidden', nil))
    end

    it 'fails rather than treating the resource as absent' do
      expect { chef_run }.to raise_error(Kubeclient::HttpError, /forbidden/)
    end
  end
end
