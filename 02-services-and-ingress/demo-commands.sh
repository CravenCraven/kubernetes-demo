#!/usr/bin/env bash
# Services and Ingress demo, command by command.
# Routes by host and path: shop.local/ -> shop, api.local/v1 -> api.
# Reference, not a run-all script. Some steps are interactive.
# Replace 192.168.1.50 with your real node IP.

# 1. Confirm Traefik (the default ingress controller on k3s) is running
kubectl get pods -n kube-system | grep traefik

# 2. Deploy two apps and expose each with a Service
kubectl create deployment shop --image=nginx --replicas=3
kubectl expose deployment shop --port=80
kubectl create deployment api --image=traefik/whoami --replicas=2
kubectl expose deployment api --port=80
kubectl get deploy,svc,pods

# 3. Confirm each Service answers internally (reach it by name, scheme required)
kubectl run tmp --rm -it --image=busybox --restart=Never -- wget -qO- http://shop
kubectl run tmp --rm -it --image=busybox --restart=Never -- wget -qO- http://api

# 4. Route to them with one Ingress (create ingress.yaml FIRST)
kubectl apply -f ingress.yaml
kubectl get ingress

# 5. Test from outside. Host routing and host + path routing.
curl -H "Host: shop.local" http://192.168.1.50/
curl -H "Host: api.local"  http://192.168.1.50/v1

# 6. Prove the path rule: root on api.local matches nothing -> 404
curl -H "Host: api.local" http://192.168.1.50/

# Clean up
kubectl delete -f ingress.yaml
kubectl delete deployment shop api
kubectl delete svc shop api
