# Connection properties

These properties apply to all three resources.

| Property | Type | Default | Description |
| --- | --- | --- | --- |
| `id` | String | Resource name | Kubernetes object name |
| `kubeconfig` | String | Required | Path to an operator-controlled kubeconfig |
| `context` | String | Current context | Named context in that kubeconfig |
| `namespace` | String | `default` | Namespace to manage |
| `client_version` | String | `4.13.0` | kubeclient gem version |
| `labels` | Hash, Array, String | `{}` | Labels declared through server-side apply |
| `field_manager` | String | `chef-kubernetes` | Stable API field owner; 1-128 letters, digits, dots, underscores or hyphens |
| `force` | Boolean | `false` | Explicitly take conflicting field ownership |
| `delete_options` | Hash | `{}` | Kubernetes deletion options; default grace is preserved |

Labels accept a hash, an array such as `['app=web', 'tier=frontend']`, or a comma-separated
string such as `'app=web,tier=frontend'`. Keys and values become strings. Missing `=` is rejected.
Server-side apply tracks the fields this manager declares. Removing a previously declared label
relinquishes ownership and removes it if no other manager owns it. Labels owned by other clients
remain. Ownership conflicts fail convergence unless `force true` is explicitly selected.

Existing objects require GET and PATCH permissions. Preview requests use server dry-run, so
admission webhooks must support dry-run. Create, delete and patch permission requirements follow
the selected actions. Default Kubernetes shutdown grace is preserved; setting
`delete_options(gracePeriodSeconds: 0)` explicitly requests immediate deletion.

Kubeclient reads authentication and TLS settings from the kubeconfig. Use verified TLS and
credentials with only the permissions this cookbook needs. Kubeconfigs can execute credential
plugins, so use only files controlled by the operator.

The cookbook installs native build tools and the kubeclient gem when needed. It does not remove
shared build tools, client gems or kubeconfig files when deleting a Kubernetes object.
