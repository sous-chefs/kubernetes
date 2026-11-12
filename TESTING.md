# Testing Kubernetes resources

Unit tests use ChefSpec and API doubles. Kitchen uses a real, isolated Kind API and Dokken
client containers. It does not connect to an existing user cluster.

## Local setup

Install Docker, Chef/Cinc Workstation, Kind 0.33.0 and kubectl. Use an explicit temporary
kubeconfig so the test setup does not change your normal Kubernetes context.

```shell
env KUBECONFIG=/private/tmp/kubernetes-kind.conf kind create cluster --name cookbook-kubernetes --image kindest/node:v1.35.8@sha256:07b2536e30b803ed61d1677a79df6115f798ce64c80f9e22f6ed45afd09323c0
kubectl --kubeconfig /private/tmp/kubernetes-kind.conf --context kind-cookbook-kubernetes apply --server-side --field-manager=chef-kubernetes -f test/support/fixtures.json
kind get kubeconfig --internal --name cookbook-kubernetes > /private/tmp/kubernetes-kitchen.conf
chmod 600 /private/tmp/kubernetes-kitchen.conf
chef install Policyfile.rb
env CHEF_LICENSE=accept-no-persist KITCHEN_LOCAL_YAML=kitchen.dokken.yml KITCHEN_KUBECONFIG=/private/tmp/kubernetes-kitchen.conf kitchen test default-ubuntu-2404 --destroy=always
```

The internal kubeconfig uses the cluster's Docker DNS name. Client containers join the `kind`
network and mount that file read-only. Never commit or upload the credential files.

The fixtures create only the `cookbook-test` and `cookbook-other` namespaces in this cluster.
They seed objects with drift and objects to delete. The suite verifies creation, correction of
managed fields, deletion and namespace isolation. A second converge must report no changes.
Reapply the fixture file before a new test run to restore the update/delete cases.

## Unit and ownership regression tests

```shell
bundle install
bundle exec rspec
env KUBERNETES_REAL_TEST_KUBECONFIG=/private/tmp/kubernetes-kind.conf bundle exec rspec spec/real_api_spec.rb
cookstyle
```

The optional real API specifications test shared field ownership, ownership-only convergence,
NodePort/address preservation and conflicts. They create uniquely named Services in the isolated
test namespace and remove them afterwards. Without the explicit environment variable, those
tests are excluded from the normal unit suite.

## Coverage and cleanup

CI creates a fresh Kind cluster for each maintained Linux client image. The same default suite
runs on every image. Native macOS/Windows Kitchen execution remains available through
`kitchen.exec.yml`, but requires a reachable test API and a locally adapted credential path.
Those native platforms are not claimed as hosted Kitchen coverage.

```shell
kind delete cluster --name cookbook-kubernetes
```
