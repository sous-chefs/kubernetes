# frozen_string_literal: true

require 'spec_helper'
require 'securerandom'
require_relative '../libraries/helpers'

describe 'server-side apply against a real Kubernetes API', :real_api do
  before do
    skip 'Set KUBERNETES_REAL_TEST_KUBECONFIG to an isolated Kind kubeconfig' unless ENV['KUBERNETES_REAL_TEST_KUBECONFIG']
    context = Kubeclient::Config.read(ENV.fetch('KUBERNETES_REAL_TEST_KUBECONFIG')).context
    @client = Kubeclient::Client.new(context.api_endpoint, 'v1', ssl_options: context.ssl_options, auth_options: context.auth_options)
    @client.extend(KubernetesCookbook::ApplyPreview)
    @name = "chef-ssa-#{SecureRandom.hex(5)}"
    @intent = Struct.new(:id, :namespace, :labels, :field_manager, :force).new(@name, 'cookbook-test', { 'app' => 'test' }, 'chef-kubernetes', false)
    @harness = Object.new.extend(KubernetesCookbook::Helpers)
    client = @client
    intent = @intent
    @writes = []
    writes = @writes
    @harness.define_singleton_method(:kube) { client }
    @harness.define_singleton_method(:new_resource) { intent }
    @harness.define_singleton_method(:converge_by) do |description, &block|
      writes << description
      block.call
    end
  end

  after do
    @client&.delete_service(@name, 'cookbook-test')
  rescue Kubeclient::ResourceNotFoundError
    nil
  end

  def apply_other(spec)
    @client.apply_service({ apiVersion: 'v1', kind: 'Service',
                            metadata: { name: @name, namespace: 'cookbook-test', labels: { app: 'test' } }, spec: spec },
                          field_manager: 'other-client', force: false)
  end

  it 'acquires and relinquishes shared ownership without falsely reporting a second change' do
    spec = { ports: [{ port: 80, targetPort: 80, protocol: 'TCP' }], selector: { app: 'test' } }
    apply_other(spec)
    @harness.manage_resource('service', 'Service', spec)
    expect(@writes.length).to eq(1)
    @harness.manage_resource('service', 'Service', spec)
    expect(@writes.length).to eq(1)

    @intent.labels = {}
    @harness.manage_resource('service', 'Service', spec)
    expect(@writes.length).to eq(2)
    service = @client.get_service(@name, 'cookbook-test')
    expect(service.metadata.labels.app).to eq('test')
    ownership = service.metadata.managedFields.find { |entry| entry.manager == 'chef-kubernetes' }
    fields = JSON.parse(ownership.to_h.to_json)
    expect(fields.dig('fieldsV1', 'f:metadata', 'f:labels', 'f:app')).to be_nil
    @harness.manage_resource('service', 'Service', spec)
    expect(@writes.length).to eq(2)
  end

  it 'preserves a foreign-owned allocated NodePort while updating declared target ports' do
    original = apply_other(type: 'NodePort', ports: [{ port: 80, targetPort: 80, protocol: 'TCP' }])
    allocated = original.spec.ports.first[:nodePort]
    address = original.spec.clusterIP
    @intent.force = true
    @harness.manage_resource('service', 'Service', ports: [{ port: 80, targetPort: 8080, protocol: 'TCP' }])
    current = @client.get_service(@name, 'cookbook-test')
    expect(current.spec.ports.first[:nodePort]).to eq(allocated)
    expect(current.spec.clusterIP).to eq(address)
    expect(current.spec.ports.first[:targetPort]).to eq(8080)
  end

  it 'surfaces ownership conflicts without force' do
    apply_other(ports: [{ port: 80, targetPort: 80, protocol: 'TCP' }])
    expect do
      @harness.manage_resource('service', 'Service', ports: [{ port: 80, targetPort: 8080, protocol: 'TCP' }])
    end.to raise_error(Kubeclient::HttpError) { |error| expect(error.error_code).to eq(409) }
    expect(@writes).to be_empty
  end
end
