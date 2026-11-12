# frozen_string_literal: true

property :id, String, name_property: true
property :kubeconfig, String, required: true
property :context, [String, nil]
property :namespace, String, default: 'default'
property :client_version, String, default: '4.13.0'
property :labels, [Hash, Array, String], default: {}
property :field_manager, String, default: 'chef-kubernetes',
                                 callbacks: { 'must be a stable identifier of 1-128 letters, digits, dots, underscores or hyphens' =>
           proc { |value| value.match?(/\A[a-zA-Z0-9._-]{1,128}\z/) } }
property :force, [true, false], default: false
property :delete_options, Hash, default: {}
