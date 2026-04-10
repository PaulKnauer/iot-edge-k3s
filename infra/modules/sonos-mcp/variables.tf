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
