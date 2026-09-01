output "control_plane_public_ip" {
  value = module.k8s_nodes.control_plane_public_ip
}

output "worker_public_ip" {
  value = module.k8s_nodes.worker_public_ip
}
