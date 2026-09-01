# Kubernetes — Milestone 5: Local Validation on Minikube

## Setup
1. Install Minikube and kubectl if you haven't already.
2. Start Minikube: `minikube start`
3. In `k8s/deployment.yaml`, replace `IMAGE_PLACEHOLDER` with your real
   image: `darshan99015/clouddeploy-notes-api:latest`

## Deploy and test
```bash
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml

# Watch pods come up
kubectl get pods -w
# Wait for both to show "Running" and "1/1" ready

# Get the URL and test it
minikube service clouddeploy-notes-api --url
curl $(minikube service clouddeploy-notes-api --url)/health
```

## The self-healing proof (do this, don't skip it)
```bash
kubectl get pods
# copy one pod's name, then:
kubectl delete pod <pod-name>

# immediately re-run:
kubectl get pods
# you should see a NEW pod already being created to replace it —
# Kubernetes' Deployment controller noticed the replica count dropped
# below 2 and corrected it automatically, with zero action from you.
```

Record this — a screen recording or even just a couple of terminal
screenshots showing before/after `kubectl get pods` — this is your
concrete proof of self-healing for interviews and your README.

## Milestone 5 exit criteria
- [ ] Both pods reach `Running` and pass readiness (`1/1` ready)
- [ ] The app is reachable via `minikube service ... --url` and `/health`
      returns 200
- [ ] Deleting a pod manually results in Kubernetes automatically
      creating a replacement, with no action from you
- [ ] You can explain, without notes, what happens between
      `kubectl apply` and a pod reaching `Running` — including how the
      readiness probe gates traffic
