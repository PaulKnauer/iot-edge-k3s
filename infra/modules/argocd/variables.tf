variable "kubeconfig_path" {
  type        = string
  description = "Path to the kubeconfig file for the target cluster"
}

variable "namespace" {
  type        = string
  default     = "argocd"
  description = "Kubernetes namespace to deploy ArgoCD into"
}

variable "chart_version" {
  type        = string
  default     = "7.8.0"
  description = "argo-cd Helm chart version"
}

variable "helm_timeout_seconds" {
  type        = number
  default     = 300
  description = "Helm release wait timeout in seconds"
}

variable "values" {
  type        = map(any)
  default     = {}
  description = "Additional Helm values merged into the ArgoCD release"
}
