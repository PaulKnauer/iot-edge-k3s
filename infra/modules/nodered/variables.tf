variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "nodered"
}

variable "image_repository" {
  type    = string
  default = "nodered/node-red"
}

variable "image_tag" {
  type    = string
  default = "3.1.9"
}

variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}

variable "service_type" {
  type    = string
  default = "ClusterIP"
}

variable "service_port" {
  type    = number
  default = 1880
}

variable "node_port" {
  type    = number
  default = null
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

variable "credential_secret" {
  type      = string
  sensitive = true
}

variable "credential_secret_name" {
  type    = string
  default = "nodered-credential-secret"
}

variable "credential_secret_key" {
  type    = string
  default = "credentialSecret"
}

variable "projects_enabled" {
  type    = bool
  default = true
}

variable "pod_security_context" {
  type = object({
    runAsUser  = number
    runAsGroup = number
    fsGroup    = number
  })
  default = {
    runAsUser  = 1000
    runAsGroup = 1000
    fsGroup    = 1000
  }
}

variable "container_security_context" {
  type = object({
    runAsUser  = number
    runAsGroup = number
  })
  default = {
    runAsUser  = 1000
    runAsGroup = 1000
  }
}

variable "deployment_strategy" {
  type    = string
  default = "Recreate"
}
