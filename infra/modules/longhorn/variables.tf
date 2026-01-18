variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "longhorn-system"
}

variable "chart_version" {
  type    = string
  default = "1.6.2"
}

variable "values" {
  type    = map(any)
  default = {}
}
