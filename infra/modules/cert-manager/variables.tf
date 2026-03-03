variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "cert-manager"
}

variable "chart_version" {
  type    = string
  default = "v1.17.1"
}

variable "helm_timeout_seconds" {
  type    = number
  default = 300
}
