variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "n8n"
}

variable "image_repository" {
  type    = string
  default = "n8nio/n8n"
}

variable "image_tag" {
  type    = string
  default = "2.11.0-arm64"
}

variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}

variable "service_type" {
  type    = string
  default = "NodePort"
}

variable "service_port" {
  type    = number
  default = 5678
}

variable "node_port" {
  type    = number
  default = 31678
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
  default = "2Gi"
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

variable "timezone" {
  type    = string
  default = "UTC"
}

variable "protocol" {
  type    = string
  default = "http"
}

variable "encryption_key" {
  type      = string
  sensitive = true
}

variable "encryption_key_secret_name" {
  type    = string
  default = "n8n-encryption-key"
}

variable "encryption_key_secret_key" {
  type    = string
  default = "encryptionKey"
}

variable "secure_cookie" {
  type    = bool
  default = false
}
