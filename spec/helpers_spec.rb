# frozen_string_literal: true

require 'spec_helper'
require_relative '../libraries/helpers'

describe KubernetesCookbook::Helpers do
  subject(:helper) { Object.new.extend(described_class) }

  before do
    allow(helper).to receive(:new_resource).and_return(double(field_manager: 'chef-kubernetes'))
  end

  def resource(fields, time = '2026-11-12T00:00:00Z')
    Kubeclient::Resource.new(
      metadata: { name: 'test', resourceVersion: '1', generation: 1,
                  managedFields: [{ manager: 'chef-kubernetes', operation: 'Apply', apiVersion: 'v1',
                                    fieldsType: 'FieldsV1', fieldsV1: fields, time: time }] },
      spec: { ports: [{ port: 80 }] }, status: { phase: 'Active' }
    )
  end

  it 'accepts the existing label input formats' do
    [{ app: 'web' }, ['app=web'], 'app=web'].each do |labels|
      expect(helper.parse_labels(labels)).to eq('app' => 'web')
    end
  end

  it 'keeps equal signs in label values and rejects malformed pairs' do
    expect(helper.parse_labels('app=a=b')).to eq('app' => 'a=b')
    expect { helper.parse_labels('missing-value') }.to raise_error(ArgumentError)
  end

  it 'ignores timestamps, versions, generations and status during comparison' do
    before = resource({ 'f:spec' => {} })
    after = resource({ 'f:spec' => {} }, '2026-11-12T01:00:00Z')
    after.metadata.resourceVersion = '2'
    after.metadata.generation = 2
    after.status.phase = 'Changed'
    expect(helper.canonical(before)).to eq(helper.canonical(after))
  end

  it 'detects ownership-only acquisition and relinquishment' do
    first = resource({ 'f:spec' => {} })
    second = resource({ 'f:spec' => {}, 'f:metadata' => { 'f:labels' => { 'f:app' => {} } } })
    expect(helper.canonical(first)).not_to eq(helper.canonical(second))
    expect(helper.canonical(second)).not_to eq(helper.canonical(first))
  end

  it 'ignores ownership changes by unrelated managers' do
    first = resource({ 'f:spec' => {} })
    second = resource({ 'f:spec' => {} })
    second.metadata.managedFields << { manager: 'controller', operation: 'Update', fieldsV1: { 'f:status' => {} } }
    expect(helper.canonical(first)).to eq(helper.canonical(second))
  end
end
