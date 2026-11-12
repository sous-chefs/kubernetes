# frozen_string_literal: true

evidence = json('/tmp/kubernetes-evidence.json').params

control 'kubernetes-core-v1' do
  title 'Resources are created and drift is corrected through the real API'
  describe evidence.fetch('api_version') do
    it { should eq 'v1' }
  end
  %w(created updated).each do |state|
    pod = evidence.fetch('pods').find { |item| item.dig('metadata', 'name') == "#{state}-pod" }
    service = evidence.fetch('services').find { |item| item.dig('metadata', 'name') == "#{state}-service" }
    controller = evidence.fetch('replication_controllers').find { |item| item.dig('metadata', 'name') == "#{state}-controller" }

    describe "Pod #{state}-pod" do
      subject { pod }
      it { should_not be_nil }
      it { expect(subject.dig(*%w(metadata labels phase))).to eq 'managed' }
      it { expect(subject.dig(*['spec', 'containers', 0, 'image'])).to eq 'registry.k8s.io/pause:3.10' }
      it { expect(subject.dig('spec', 'volumes').any? { |volume| volume.fetch('name').start_with?('kube-api-access-') }).to be true }
      it { expect(subject.dig('spec', 'containers', 0, 'volumeMounts')).not_to be_empty }
    end
    describe "Service #{state}-service" do
      subject { service }
      it { should_not be_nil }
      it { expect(subject.dig(*['spec', 'ports', 0, 'port'])).to eq 9090 }
      it { expect(subject.dig(*['spec', 'ports', 0, 'targetPort'])).to eq 8080 }
      it { expect(subject.dig(*%w(metadata labels))).to eq('phase' => 'managed') }
    end
    describe "ReplicationController #{state}-controller" do
      subject { controller }
      it { should_not be_nil }
      it { expect(subject.dig(*%w(spec replicas))).to eq 0 }
      it { expect(subject.dig(*%w(spec template metadata labels app))).to eq 'test' }
    end
  end
end

control 'kubernetes-removal-and-isolation' do
  title 'Deletion is complete and leaves other namespaces untouched'
  %w(pods services replication_controllers).each do |entity|
    describe evidence.fetch(entity).map { |item| item.dig('metadata', 'name') } do
      it { should_not include "removed-#{entity == 'replication_controllers' ? 'controller' : entity.delete_suffix('s')}" }
    end
  end
  %w(pods services replication_controllers).each do |entity|
    describe evidence.fetch("other_#{entity}").map { |item| item.dig('metadata', 'name') } do
      it { should include "removed-#{entity == 'replication_controllers' ? 'controller' : entity.delete_suffix('s')}" }
    end
  end
end
