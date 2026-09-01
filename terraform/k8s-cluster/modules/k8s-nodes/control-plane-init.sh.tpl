#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker wget 

systemctl enable docker
systemctl start docker

# --- containerd as the Kubernetes container runtime ---
dnf install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable containerd
systemctl restart containerd

# --- Kernel prerequisites for Kubernetes networking ---
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
sysctl --system

# --- Install kubeadm, kubelet, kubectl ---
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes
systemctl enable kubelet

# --- Initialize the control plane with a pre-generated, fixed token ---
# Using a fixed token (passed in via Terraform) instead of kubeadm's
# default auto-generated one avoids a timing problem: the worker instance
# boots independently and can't reliably fetch a token generated on the
# control plane after the fact. See worker-init.sh.tpl for the matching
# join command and its security trade-off (CA verification is skipped).
kubeadm init --token=${kubeadm_token} --pod-network-cidr=10.244.0.0/16

# --- Let ec2-user run kubectl without sudo ---
mkdir -p /home/ec2-user/.kube
cp -i /etc/kubernetes/admin.conf /home/ec2-user/.kube/config
chown ec2-user:ec2-user /home/ec2-user/.kube/config

# --- Install a pod network add-on (Flannel — simple, widely used) ---
export KUBECONFIG=/etc/kubernetes/admin.conf
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/master/Documentation/kube-flannel.yml

# --- Keep the token from expiring (default kubeadm tokens expire after
# 24h — fine for creating the cluster once, but we don't want it dying
# the next time this instance's user_data conceptually "runs" — it won't
# re-run, but this makes re-joins possible if you ever manually rerun) ---
kubeadm token create ${kubeadm_token} --ttl 0 --print-join-command || true
