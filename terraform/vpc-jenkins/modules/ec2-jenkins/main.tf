data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

# SSH (22) and the Jenkins UI (8080) are restricted to your IP only.
# Never open these to 0.0.0.0/0 — that's an internet-wide invitation.
resource "aws_security_group" "jenkins" {
  name        = "${var.project_name}-jenkins-sg"
  description = "Allow SSH and Jenkins UI from a single trusted IP"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH from my IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  ingress {
    description = "Jenkins UI from my IP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  # GitHub's webhook servers connect from GitHub's own IP ranges, not
  # yours — so the rule above alone blocks GitHub entirely. This opens
  # 8080 more broadly ONLY so GitHub's push-event webhook can reach
  # /github-webhook/. Trade-off, done deliberately: for a short-lived
  # portfolio demo this is acceptable; the more correct production fix
  # is to allow-list GitHub's published webhook CIDR ranges from
  # https://api.github.com/meta instead of 0.0.0.0/0.
  ingress {
    description = "GitHub webhook - broader than the rules above, on purpose, see comment above"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-jenkins-sg"
  }
}

resource "aws_instance" "jenkins" {
  ami                    = data.aws_ami.amazon_linux.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  key_name               = var.key_name
  user_data              = file("${path.module}/user_data.sh")

  lifecycle {
    ignore_changes = [ami]
  }

  root_block_device {
    volume_size = 30 # Jenkins + Docker images need more than the 8GB default
    volume_type = "gp3"
  }

  tags = {
    Name = "${var.project_name}-jenkins"
  }
}
