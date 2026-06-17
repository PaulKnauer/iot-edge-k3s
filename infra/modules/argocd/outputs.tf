output "admin_password" {
  description = "Base64-encoded initial admin password"
  value       = data.kubernetes_secret.argocd_admin.data["password"]
  sensitive   = true
}

output "server_service" {
  description = "ArgoCD server service name"
  value       = "argocd-server"
}

output "namespace" {
  description = "ArgoCD namespace"
  value       = var.namespace
}
