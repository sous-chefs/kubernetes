name             'kubernetes'
maintainer       'Chef Software, Inc.'
maintainer_email 'cookbooks@chef.io'
license          'Apache-2.0'
description      'Resources for managing Kubernetes'
version          '1.0.0'

depends 'build-essential', '>= 2.2.3'

supports 'all'

source_url 'https://github.com/chef-cookbooks/kubernetes'
issues_url 'https://github.com/chef-cookbooks/kubernetes/issues'
chef_version '>= 12.9' if respond_to?(:chef_version)
