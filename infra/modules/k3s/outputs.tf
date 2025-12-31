output "kubeconfig_path" {
  value = var.kubeconfig_path
}

output "cluster_endpoint" {
  value = var.cluster_endpoint
}

output "server0" {
  value = var.servers[0].host
}
