# k8s-storage-lab

Run Postgres twice. Delete a pod both times. Lose the whole database once, keep it the other time.

The only difference between the two runs is where Postgres writes its data directory: an `emptyDir` that dies with the pod, or a `PersistentVolumeClaim` that outlives it.

This README is the short runnable version. The full deep-dive walkthrough, with the output you should see at every step and a troubleshooting section, is the companion blog post.

## What you need

- A running cluster. k3s or k3d both ship `local-path` as the default StorageClass.
- `kubectl` pointed at it.

```bash
kubectl get storageclass
# local-path (default) should be listed
```

## Layout

```
manifests/
  01-ephemeral-postgres.yaml   # Postgres on emptyDir (dies with the pod)
  02-pvc.yaml                  # PersistentVolumeClaim on local-path
  03-persistent-postgres.yaml  # Postgres on that PVC (survives the pod)
```

## Part 1: ephemeral, watch the database vanish

```bash
kubectl apply -f manifests/01-ephemeral-postgres.yaml
kubectl rollout status deploy/pg-ephemeral

kubectl exec deploy/pg-ephemeral -- psql -U postgres -c "create table notes (id serial, body text);"
kubectl exec deploy/pg-ephemeral -- psql -U postgres -c "insert into notes (body) values ('first note'), ('second note');"
kubectl exec deploy/pg-ephemeral -- psql -U postgres -c "select * from notes;"
```

Now delete the pod. The Deployment brings a fresh one back.

```bash
kubectl delete pod -l app=pg-ephemeral
kubectl rollout status deploy/pg-ephemeral

kubectl exec deploy/pg-ephemeral -- psql -U postgres -c "select * from notes;"
# ERROR:  relation "notes" does not exist
```

The table is not empty, it is gone. The new pod got a clean `emptyDir`, so Postgres ran `initdb` from scratch. The data directory left with the pod.

## Part 2: persistent, watch it survive

```bash
kubectl apply -f manifests/02-pvc.yaml
kubectl apply -f manifests/03-persistent-postgres.yaml
kubectl rollout status deploy/pg-persistent

kubectl exec deploy/pg-persistent -- psql -U postgres -c "create table notes (id serial, body text);"
kubectl exec deploy/pg-persistent -- psql -U postgres -c "insert into notes (body) values ('first note'), ('second note');"
```

Delete the pod, same as before.

```bash
kubectl delete pod -l app=pg-persistent
kubectl rollout status deploy/pg-persistent

kubectl exec deploy/pg-persistent -- psql -U postgres -c "select * from notes;"
#  id |    body
# ----+-------------
#   1 | first note
#   2 | second note
```

Same deletion, opposite result. The new pod mounted the same claim and Postgres found its existing data directory.

## Where the data actually lives

The PVC is a real directory on the node's disk.

```bash
kubectl get pv
kubectl describe pv <volume-name> | grep -i path
# Path: /var/lib/rancher/k3s/storage/<pvc-id>/
```

On k3s that directory is on the node's real filesystem. On k3d the node is a container, so the path is inside the k3d node container instead.

## Gotchas

- **PVC stuck in `Pending` forever.** `local-path` uses `WaitForFirstConsumer`, so the volume is not provisioned until a pod actually mounts it. Apply the PVC alone and it sits Pending. That is expected, not broken. It binds when the Deployment schedules.

- **Rolling update deadlock on `ReadWriteOnce`.** A RWO volume attaches to one pod at a time. With the default RollingUpdate strategy the new pod tries to mount before the old pod lets go, and the rollout hangs with a multi-attach error. That is why `03-persistent-postgres.yaml` sets `strategy: Recreate`.

- **Deleting the PVC destroys the data.** `local-path` defaults to `reclaimPolicy: Delete`. Remove the PVC and the directory on the node is wiped. There is no undo. Deleting the pod is safe, deleting the claim is not. Do not conflate the two.

- **`emptyDir` is more fragile than it looks.** It survives a container crash and restart inside the same pod, but it is deleted the instant the pod is removed. A pod delete, a node drain, or a reschedule all take it with them.

- **`local-path` pins data to one node.** The PV carries node affinity, so the pod is forced back to the node holding the disk every time it reschedules. On a single node this is invisible. On multiple nodes the pod cannot move freely, and if that node's disk dies the data dies with it. There is no replication.

- **The storage request is not a hard limit.** `resources.requests.storage: 1Gi` is what gets recorded on the PVC, but `local-path` does not enforce it as a quota. You can write past it until the node's actual disk fills. Do not treat the number as a cap.

- **Mounting over a non-empty directory can break `initdb`.** Postgres refuses to initialize into a data directory that already contains files (for example a `lost+found` on a freshly formatted disk). `local-path` hands you a clean directory so this lab is fine, but on other provisioners point `PGDATA` at a subdirectory or use a `subPath` mount.

## Cleanup

```bash
kubectl delete -f manifests/01-ephemeral-postgres.yaml
kubectl delete -f manifests/03-persistent-postgres.yaml
kubectl delete -f manifests/02-pvc.yaml
kubectl get pvc,pv
```

Deleting the PVC releases the PV and `local-path` removes the directory on the node.
