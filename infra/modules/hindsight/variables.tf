variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "hindsight"
}

variable "chart_version" {
  type    = string
  default = "0.9.0"
}

variable "helm_timeout_seconds" {
  type    = number
  default = 900
}

variable "worker_id" {
  type    = string
  default = "hindsight-home"
}

variable "llm_provider" {
  type    = string
  default = ""
}

variable "llm_model" {
  type    = string
  default = ""
}

variable "llm_base_url" {
  type    = string
  default = ""
}

variable "llm_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "tenant_api_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "control_plane_access_key" {
  type      = string
  sensitive = true
  default   = ""
}

variable "mcp_auth_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "storage_class" {
  type    = string
  default = "longhorn"
}

variable "storage_size" {
  type    = string
  default = "8Gi"
}

variable "postgresql_username" {
  type    = string
  default = "hindsight"
}

variable "postgresql_password" {
  type      = string
  sensitive = true
  default   = "hindsight"
}

variable "postgresql_database" {
  type    = string
  default = "hindsight"
}

variable "control_plane_port" {
  type    = number
  default = 3000
}

variable "ingress_enabled" {
  type    = bool
  default = true
}

variable "ingress_class_name" {
  type    = string
  default = "nginx"
}

variable "web_host" {
  type    = string
  default = "hindsight.home.lab"
}

variable "api_host" {
  type    = string
  default = "hindsight-api.home.lab"
}

variable "ingress_proxy_body_size" {
  type    = string
  default = "100m"
}

variable "ingress_proxy_read_timeout_seconds" {
  type    = number
  default = 600
}

variable "ingress_proxy_send_timeout_seconds" {
  type    = number
  default = 600
}
