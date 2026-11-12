# frozen_string_literal: true

require 'chefspec'
require 'chefspec/policyfile'
require 'kubeclient'

RSpec.configure do |config|
  config.color = true               # Use color in STDOUT
  config.formatter = :documentation # Use the specified formatter
  config.log_level = :error         # Avoid deprecation notice SPAM
  config.filter_run_excluding real_api: true unless ENV['KUBERNETES_REAL_TEST_KUBECONFIG']
end
