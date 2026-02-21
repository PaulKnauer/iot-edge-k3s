variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "registry"
}

variable "chart_version" {
  type    = string
  default = "2.2.3"
}

variable "replica_count" {
  type    = number
  default = 1
}

variable "service_type" {
  type    = string
  default = "NodePort"
}

variable "service_port" {
  type    = number
  default = 5000
}

variable "node_port" {
  type    = number
  default = 32000
}

variable "persistence_enabled" {
  type    = bool
  default = true
}

variable "storage_class" {
  type    = string
  default = "longhorn"
}

variable "storage_size" {
  type    = string
  default = "50Gi"
}

variable "storage_access_mode" {
  type    = string
  default = "ReadWriteOnce"
}

variable "htpasswd" {
  type      = string
  default   = ""
  sensitive = true
}

variable "helm_timeout_seconds" {
  type    = number
  default = 900
}
