# kubectl Grammar Reference

The companion breakdown to [Portuguese Taught Me Kubernetes](./README.md). If a command is a sentence, this is the grammar book. Every kubectl command is the same shape:

```
kubectl [verb] [resource] [name] [flags]
```

- **verb** = what to do
- **resource** = what kind of thing to do it to
- **name** = which specific one (optional)
- **flags** = modifiers, always start with `-` or `--`

Read left to right: do this, to this kind of thing, this specific one, like so.

## Slot 1: the verb

The verb decides what happens. Two families.

**Read verbs (safe, change nothing):**

| verb | what it does |
| --- | --- |
| `get` | list things, one line each |
| `describe` | full detail on one thing, including events |
| `logs` | print what a container printed |
| `explain` | docs for a resource's fields |

**Write verbs (they change the cluster):**

| verb | what it does |
| --- | --- |
| `apply` | create or update from a YAML file |
| `create` | make something new |
| `delete` | remove something |
| `edit` | open the live config in your editor |
| `scale` | change replica count |
| `rollout` | manage or restart a deployment's rollout |
| `exec` | run a command inside a container |

Rule of thumb: `get` and `describe` can never hurt you. Run them constantly. Slow down on the write verbs.

## Slot 2: the resource

The resource is the noun. It answers "what kind of thing."

| full | short | what it is |
| --- | --- | --- |
| `pods` | `po` | the running thing |
| `deployments` | `deploy` | the spec that manages pods |
| `services` | `svc` | stable network endpoint for pods |
| `namespaces` | `ns` | a folder that isolates resources |
| `nodes` | `no` | the machines pods run on |
| `configmaps` | `cm` | non-secret config |
| `secrets` | (none) | secret config |
| `ingress` | `ing` | routes external traffic in |
| `persistentvolumeclaims` | `pvc` | a request for storage |

Short names save typing. `k get po` and `k get pods` are identical.

Don't memorize the table. Ask the cluster:

```
kubectl api-resources          # every resource type, short name, and API group
kubectl explain pod            # what fields a pod has
kubectl explain pod.spec       # drill into nested fields
```

## Slot 3: the name

The name narrows a verb to one specific object. Leave it off to hit all of them.

```
kubectl get pods               # all pods
kubectl get pod nginx-abc123   # just this one
```

Instead of a name, select a group by label with `-l`:

```
kubectl get pods -l app=nginx
kubectl delete pods -l app=nginx
```

## Slot 4: the flags

Flags tune the command. The ones you use constantly:

```
-n <namespace>                 # operate in this namespace
-A                             # across all namespaces (read verbs)
-o wide                        # extra columns: node, IP
-o yaml                        # the full object as YAML
-w                             # watch, live updates
--dry-run=client -o yaml       # show what WOULD happen, no change
```

If a command returns nothing and you expected results, you probably forgot `-n`.

## The sentence mappings

Every command lines up with a Portuguese sentence, slot for slot.

**Edit (the one that started it):**

```
Eu       edito  a foto        antiga
kubectl  edit   deployment    test
```

**Full sentence, every slot including a flag:**

```
Eu       como   a maçã        vermelha   rapidamente
kubectl  delete deployments   test       -n dev
```

**Drop the name, mean all of them:**

```
Eu vejo os pássaros     ->  the birds, the whole set
kubectl get pods        ->  every pod
```

**Swap the verb, keep the sentence:**

```
kubectl get pods
kubectl delete deployment test
kubectl apply -f app.yaml
```

Get, delete, apply. Same sentence, different verb.

## How to never be stuck

Three commands that answer their own questions:

```
kubectl <verb> --help          # every flag for any command
kubectl explain <resource>     # what fields a resource has
kubectl api-resources          # every resource, short name, API group
```

Reach for `--help` before a search engine. It's the correct docs for your exact version.
