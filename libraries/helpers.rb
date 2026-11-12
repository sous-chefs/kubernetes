# frozen_string_literal: true

require 'json'
require 'uri'

module KubernetesCookbook
  # kubeclient 4.13 supports server-side apply, but does not expose its dryRun query option.
  # Keep real writes on its implementation; extend only per-client preview requests.
  # Transport adapted from kubeclient 4.13.0 (MIT); see THIRD_PARTY_LICENSES.
  module ApplyPreview
    def apply_entity(resource_name, resource, field_manager:, force: true, dry_run: false)
      return super(resource_name, resource, field_manager: field_manager, force: force) unless dry_run

      query = URI.encode_www_form(fieldManager: field_manager, force: force, dryRun: 'All')
      name = "#{resource[:metadata][:name]}?#{query}"
      prefix = build_namespace_prefix(resource[:metadata][:namespace])
      response = handle_exception do
        rest_client["#{prefix}#{resource_name}/#{name}"].patch(
          resource.to_json,
          { 'Content-Type' => 'application/apply-patch+yaml' }.merge(get_headers)
        )
      end
      format_response(@as, response.body)
    end
  end

  module Helpers
    def kube
      @kube ||= begin
        build_essential 'kubeclient native dependencies' do
          compile_time false
        end
        chef_gem 'kubeclient' do
          version new_resource.client_version
          compile_time false
        end
        gem 'kubeclient', new_resource.client_version
        require 'kubeclient'
        context = Kubeclient::Config.read(new_resource.kubeconfig).context(new_resource.context)
        client = Kubeclient::Client.new(context.api_endpoint, 'v1',
                                       ssl_options: context.ssl_options, auth_options: context.auth_options)
        client.extend(ApplyPreview)
      end
    end

    def parse_labels(labels)
      return labels.transform_keys(&:to_s).transform_values(&:to_s) if labels.is_a?(Hash)

      entries = labels.is_a?(Array) ? labels : labels.split(',')
      entries.to_h do |entry|
        key, value = entry.split('=', 2)
        raise ArgumentError, "Label must use key=value: #{entry}" if key.nil? || key.empty? || value.nil?

        [key, value]
      end
    end

    def existing_resource(entity)
      client = kube
      begin
        client.public_send("get_#{entity}", new_resource.id, new_resource.namespace)
      rescue ::Kubeclient::ResourceNotFoundError
        nil
      end
    end

    def canonical(resource)
      result = JSON.parse(JSON.generate(resource.to_h))
      result.delete('status')
      metadata = result.fetch('metadata')
      %w(resourceVersion generation).each { |key| metadata.delete(key) }
      ownership = Array(metadata['managedFields']).select do |entry|
        entry['manager'] == new_resource.field_manager && entry['operation'] == 'Apply' && !entry['subresource']
      end
      ownership = ownership.map { |entry| entry.reject { |key, _| key == 'time' } }
      metadata['managedFields'] = ownership.sort_by { |entry| [entry['apiVersion'].to_s, entry['operation'].to_s] }
      result
    end

    def manage_resource(entity, kind, spec)
      current = existing_resource(entity)
      desired = {
        apiVersion: 'v1', kind: kind,
        metadata: { name: new_resource.id, namespace: new_resource.namespace, labels: parse_labels(new_resource.labels) },
        spec: spec
      }
      options = { field_manager: new_resource.field_manager, force: new_resource.force }
      if current
        preview = kube.public_send("apply_#{entity}", desired, **options, dry_run: true)
        return if canonical(current) == canonical(preview)
      end

      converge_by("apply #{kind} #{new_resource.namespace}/#{new_resource.id}") do
        kube.public_send("apply_#{entity}", desired, **options)
      end
    end

    def delete_resource(entity)
      return unless existing_resource(entity)

      begin
        converge_by("delete #{entity} #{new_resource.namespace}/#{new_resource.id}") do
          kube.public_send("delete_#{entity}", new_resource.id, new_resource.namespace,
                           delete_options: new_resource.delete_options)
        end
      rescue ::Kubeclient::ResourceNotFoundError
        nil
      end
    end
  end
end
