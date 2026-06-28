# Self-healing demo: pods vs deployments

# A bare pod has no controller watching it
kubectl run lonely --image=nginx
kubectl delete pod lonely        # stays dead, nothing recreates it

# A Deployment runs 3 pods and reconciles them
kubectl create deployment web --image=nginx --replicas=3
kubectl get pods
kubectl delete pod <one-web-pod-name>   # Deployment recreates it instantly
kubectl get pods -w
