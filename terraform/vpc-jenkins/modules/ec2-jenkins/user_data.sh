#!/bin/bash
set -euxo pipefail

dnf update -y

# --- Docker + wget (AL2023 doesn't ship wget by default — install it
# explicitly so later steps/manual debugging can rely on it too) ---
dnf install -y docker git wget
systemctl enable docker
systemctl start docker
usermod -aG docker ec2-user

# --- Java 21 + fontconfig (Jenkins currently requires Java 21+) ---
dnf install -y java-21-amazon-corretto fontconfig

# --- Jenkins ---
# NOTE: Jenkins moved Red Hat/openSUSE packages to a unified rpm-stable
# repo. The old /redhat-stable path now 404s. The current jenkins.repo
# file handles key verification itself — no separate rpm --import step.
curl -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/rpm-stable/jenkins.repo
dnf install -y jenkins

# Let Jenkins run docker builds without sudo
usermod -aG docker jenkins

systemctl enable jenkins
systemctl start jenkins