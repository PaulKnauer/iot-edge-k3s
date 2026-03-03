variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "qdrant"
}

variable "image_repository" {
  type    = string
  default = "qdrant/qdrant"
}

variable "image_tag" {
  type    = string
  default = "v1.13.4"
}

variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}

variable "http_port" {
  type    = number
  default = 6333
}

variable "grpc_port" {
  type    = number
  default = 6334
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
  default = "5Gi"
}

variable "storage_access_mode" {
  type    = string
  default = "ReadWriteOnce"
}

variable "resources" {
  type    = map(any)
  default = {}
}

variable "deployment_strategy" {
  type    = string
  default = "Recreate"
}
