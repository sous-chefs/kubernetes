name             'kubernetes'
maintainer       'Andre Elizondo'
maintainer_email 'andre@chef.io'
license          'apache2'
description      'Manipulate Kubernetes resources'
long_description 'Deploy a Kubernetes cluster and create, destroy, and update Kubernetes Pods, Services, and Replication Controllers'
version          '1.0.0'

depends 'build-essential', '~> 2.2.3'
depends 'selinux', '~> 0.9.0'
depends 'docker', '~> 1.0.12'

supports 'rhel'