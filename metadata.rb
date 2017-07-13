name             'kubernetes'
maintainer       'Andre Elizondo'
maintainer_email 'andre@chef.io'
license          'Apache-2.0'
description      'Resources for managing Kubernetes'
long_description 'Deploy a Kubernetes cluster and create, destroy, and update Kubernetes Pods, Services, and Replication Controllers'
version          '1.0.0'

depends 'build-essential', '>= 2.2.3'
depends 'selinux', '>= 0.9.0'
depends 'docker', '>= 2.3'
depends 'compat_resource', '>= 12.16'

supports 'redhat'
supports 'centos'

source_url 'https://github.com/andrewelizondo/kubernetes'
issues_url 'https://github.com/andrewelizondo/kubernetes/issues'
chef_version '>= 12.1' if respond_to?(:chef_version)
