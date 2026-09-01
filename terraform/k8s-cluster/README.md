# Terraform — Milestone 6: Cloud Kubernetes Cluster + CD

## Before you apply
1. Get your existing VPC and subnet IDs from vpc-jenkins:
   ```
   cd ../vpc-jenkins
   terraform output vpc_id
   # you'll also need a public subnet ID — check your vpc module's
   # public_subnet_ids output, or find it in the AWS console (VPC ->
   # Subnets, filter by your VPC)
   ```
2. Update `backend.tf`'s bucket/region/dynamodb_table to match your
   actual values (same ones from vpc-jenkins).
3. Create `terraform.tfvars` here with `vpc_id`, `subnet_id`, `my_ip`,
   `key_name`.

## Apply
```bash
cd terraform/k8s-cluster
terraform init
terraform plan   # read it — should show 2 EC2 instances + 1 security group
terraform apply
```

Boot + kubeadm init/join takes longer than the Jenkins box did —
budget 5-8 minutes before checking on it.

## Verify the cluster
```bash
ssh -i your-key.pem ec2-user@$(terraform output -raw control_plane_public_ip)
kubectl get nodes
# Should show 2 nodes: the control-plane and the worker, both "Ready"
# (may take a minute or two after boot for the worker to show Ready)
```

## Get the kubeconfig onto your own machine and into Jenkins
```bash
# From your local machine:
scp -i your-key.pem ec2-user@<control-plane-ip>:/home/ec2-user/.kube/config ./k8s-kubeconfig

# IMPORTANT: this kubeconfig's "server" field points at the control
# plane's PRIVATE IP by default. Edit the downloaded file and change
# the server: line to use the control plane's PUBLIC IP instead, so
# Jenkins (and your own laptop) can actually reach it from outside the VPC.
```

In Jenkins: Manage Jenkins -> Credentials -> Add Credentials -> Kind:
"Secret file" -> upload the edited `k8s-kubeconfig` file -> ID:
`kubeconfig-creds` (must match exactly what's in the Jenkinsfile).

## Test the manifests manually first (before trusting Jenkins with it)
```bash
export KUBECONFIG=./k8s-kubeconfig
kubectl get nodes   # should work from your own laptop now
kubectl apply -f k8s/configmap.yaml
# manually replace IMAGE_PLACEHOLDER in k8s/deployment.yaml first
kubectl apply -f k8s/deployment.yaml
kubectl apply -f k8s/service.yaml
kubectl get pods -w
```

## Then let Jenkins do it
Push a code change and watch the pipeline run through Deploy to
Kubernetes and Smoke Test. The Jenkinsfile's `sed` command
auto-substitutes `IMAGE_PLACEHOLDER` with the actual build's image tag,
so you don't edit `deployment.yaml` by hand for real pipeline runs —
only for the manual test above.

## Milestone 6 exit criteria
- [ ] `kubectl get nodes` shows both nodes Ready
- [ ] A `git push` results in a live rolling update on the cluster,
      fully hands-off — push, watch Jenkins, watch `kubectl get pods`
      roll over, hit the new version's `/health` via NodePort
- [ ] You can explain the CA-verification trade-off in the worker's
      join command if asked
