kubectl get pods

kubectl get nodes

kubectl get services

kubectl create deployment nginx --image=nginx:latest --replicas=3
kubectl get pods

kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get services