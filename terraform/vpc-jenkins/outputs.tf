output "jenkins_public_ip" {
  value = module.jenkins.public_ip
}

output "jenkins_url" {
  value = "http://${module.jenkins.public_ip}:8080"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
