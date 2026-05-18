variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "sonos-mcp"
}

variable "image_repository" {
  type    = string
  default = "192.168.2.201:32000/soniq-mcp"
}

variable "image_tag" {
  type    = string
  default = "latest"
}

variable "image_pull_policy" {
  type    = string
  default = "Always"
}

variable "node_port" {
  type    = number
  default = 31800
}

variable "helm_timeout_seconds" {
  type    = number
  default = 300
}

variable "log_level" {
  type    = string
  default = "INFO"
}

variable "max_volume_pct" {
  type    = string
  default = "80"
}

variable "tools_disabled" {
  type    = string
  default = ""
}

variable "default_room" {
  type      = string
  sensitive = true
  default   = ""
}

variable "auth_mode" {
  type    = string
  default = ""

  validation {
    condition     = contains(["", "none", "static", "oidc"], var.auth_mode)
    error_message = "auth_mode must be empty, none, static, or oidc."
  }
}

variable "auth_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "oidc_issuer" {
  type    = string
  default = ""
}

variable "oidc_audience" {
  type    = string
  default = ""
}

variable "oidc_jwks_uri" {
  type    = string
  default = ""
}

variable "oidc_resource_url" {
  type    = string
  default = ""
}

variable "ca_bundle_enabled" {
  type    = bool
  default = false
}

variable "ca_bundle_config_map_name" {
  type    = string
  default = ""
}

variable "ca_bundle_config_map_key" {
  type    = string
  default = "ca.crt"
}

variable "ca_bundle_mount_path" {
  type    = string
  default = "/etc/soniq/ca.crt"
}

variable "image_pull_secret_name" {
  type    = string
  default = ""
}

variable "create_image_pull_secret" {
  type    = bool
  default = false
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
  sensitive = true
  default   = ""
}
