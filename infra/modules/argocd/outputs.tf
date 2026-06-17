output "server_service" {
  description = "ArgoCD server service name (Helm fullname: <release>-argo-cd-server)"
  value       = "argocd-argo-cd-server"
}

output "namespace" {
  description = "ArgoCD namespace"
  value       = var.namespace
}
