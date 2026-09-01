#!/bin/bash
set -euxo pipefail

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker

dnf install -y containerd
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/' /etc/containerd/config.toml
systemctl enable containerd
systemctl restart containerd

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

cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
EOF

dnf install -y kubelet kubeadm --disableexcludes=kubernetes
systemctl enable kubelet

# NOTE — deliberate trade-off, documented (same pattern as the GitHub
# webhook security group rule): --discovery-token-unsafe-skip-ca-verification
# skips verifying the control plane's CA certificate hash during join.
# This avoids needing to fetch that hash from the control plane at exactly
# the right boot moment across two independently-starting instances. Fine
# for a short-lived portfolio demo cluster; a real production setup would
# fetch and pass the actual --discovery-token-ca-cert-hash instead.
kubeadm join ${control_plane_ip}:6443 \
    --token ${kubeadm_token} \
    --discovery-token-unsafe-skip-ca-verification
