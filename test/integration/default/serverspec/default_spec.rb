require 'spec_helper'

describe 'k8s::default' do

  # Serverspec examples can be found at
  # http://serverspec.org/resource_types.html
  
  it 'installs the kubeclient' do
    expect(package('kubeclient')).to be_installed
  end

end