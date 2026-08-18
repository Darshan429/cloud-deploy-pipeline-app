#!/bin/bash
set -euxo pipefail

dnf update -y

# --- Docker ---
dnf install -y docker git
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# --- Java (required by Jenkins) ---
dnf install -y java-17-amazon-corretto

# --- Jenkins ---
wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.repo.key
dnf install -y jenkins

# Let Jenkins run docker builds without sudo
usermod -aG docker jenkins

systemctl enable jenkins
systemctl start jenkins
