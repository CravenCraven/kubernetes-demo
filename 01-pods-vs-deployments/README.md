# Pods vs Deployments: Self-Healing

A bare pod is fragile. Delete it and it's gone for good. A Deployment runs a target number of pods and replaces any that die, with no manual action. That is self-healing, and it's why you run Deployments instead of bare pods.

## Demo

A bare pod stays dead:

    kubectl run lonely --image=nginx
    kubectl delete pod lonely
    kubectl get pods

A Deployment heals:

    kubectl create deployment web --image=nginx --replicas=3
    kubectl get pods
    kubectl delete pod <one-web-pod>
    kubectl get pods -w

## Why it works

A Deployment owns a ReplicaSet whose only job is to keep the desired number of pods running. When a pod dies, the ReplicaSet sees the count drop below target and creates a new one. The bare pod has nothing watching it.

## Cleanup

    kubectl delete deployment web
