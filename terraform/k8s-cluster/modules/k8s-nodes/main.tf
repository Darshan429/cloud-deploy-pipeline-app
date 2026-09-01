data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# kubeadm join tokens must be in the form [a-z0-9]{6}.[a-z0-9]{16}.
# Generating this once via Terraform (instead of letting kubeadm create
# one dynamically) is what makes automating the worker's join possible —
# see control-plane-init.sh.tpl and worker-init.sh.tpl for how it's used.
resource "random_string" "token_id" {
  length  = 6
  special = false
  upper   = false
}

resource "random_string" "token_secret" {
  length  = 16
  special = false
  upper   = false
}

locals {
  kubeadm_token = "${random_string.token_id.result}.${random_string.token_secret.result}"
}

resource "aws_security_group" "k8s" {
  name        = "${var.project_name}-k8s-sg"
  description = "Kubernetes cluster nodes"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    description = "Kubernetes API server from my IP (for kubectl)"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    description = "NodePort range, open broadly so the app is reachable"
    from_port   = 30000
    to_port     = 32767
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Nodes need to talk to each other freely (pod networking, kubelet,
  # etcd, etc.) — restricting this to "self" (other members of this same
  # security group) keeps it from being open to the whole internet while
  # still letting cluster-internal traffic flow.
  ingress {
    description = "All traffic between cluster nodes"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-k8s-sg"
  }
}

resource "aws_instance" "control_plane" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.control_plane_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.k8s.id]
  key_name               = var.key_name
  user_data = templatefile("${path.module}/control-plane-init.sh.tpl", {
    kubeadm_token = local.kubeadm_token
  })

  lifecycle {
    ignore_changes = [ami]
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-k8s-control-plane"
  }
}

resource "aws_instance" "worker" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.worker_instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.k8s.id]
  key_name               = var.key_name

  # The worker needs the control plane's private IP to join the cluster.
  # Passing it via templatefile keeps the join logic in one script.
  user_data = templatefile("${path.module}/worker-init.sh.tpl", {
    control_plane_ip = aws_instance.control_plane.private_ip
    kubeadm_token    = local.kubeadm_token
  })

  lifecycle {
    ignore_changes = [ami]
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-k8s-worker"
  }

  depends_on = [aws_instance.control_plane]
}

output "control_plane_public_ip" {
  value = aws_instance.control_plane.public_ip
}

output "worker_public_ip" {
  value = aws_instance.worker.public_ip
}
