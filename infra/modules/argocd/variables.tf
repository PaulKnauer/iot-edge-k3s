variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "argocd"
}

variable "chart_version" {
  type    = string
  default = "7.8.0"
}

variable "helm_timeout_seconds" {
  type    = number
  default = 300
}

variable "values" {
  type    = any
  default = {}
}
