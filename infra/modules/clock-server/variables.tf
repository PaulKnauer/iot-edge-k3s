variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "clock"
}

variable "image_repository" {
  type    = string
  default = "clock-server"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "image_pull_policy" {
  type    = string
  default = "IfNotPresent"
}

variable "image_pull_secret_name" {
  type    = string
  default = ""
}

variable "auth_secret_name" {
  type    = string
  default = "clock-server-auth"
}

variable "api_auth_credentials" {
  type      = string
  default   = ""
  sensitive = true
}

variable "api_auth_token" {
  type      = string
  default   = ""
  sensitive = true
}

variable "registry_server" {
  type    = string
  default = ""
}

variable "registry_username" {
  type    = string
  default = ""
}

variable "registry_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "registry_email" {
  type    = string
  default = ""
}

variable "service_type" {
  type    = string
  default = "ClusterIP"
}

variable "service_port" {
  type    = number
  default = 8080
}

variable "node_port" {
  type    = number
  default = null
}

variable "resources" {
  type    = map(any)
  default = {}
}

variable "extra_env" {
  type    = map(string)
  default = {}
}

variable "helm_timeout_seconds" {
  type    = number
  default = 900
}
