variable "kubeconfig_path" { type = string }

variable "namespace" {
  type    = string
  default = "ruview"
}

variable "image_repository" {
  type    = string
  default = "ruview-sensing-server"
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

variable "csi_source" {
  type    = string
  default = "auto"
}

variable "allowed_hosts" {
  type    = string
  default = ""
}

# Set to "1" for LAN/homelab where RUVIEW_API_TOKEN is not configured.
# The entrypoint blocks startup on 0.0.0.0 without a token unless this is "1".
variable "allow_unauthenticated" {
  type    = string
  default = "1"
}

variable "mqtt_enabled" {
  type    = bool
  default = false
}

variable "mqtt_host" {
  type    = string
  default = "localhost"
}

variable "mqtt_port" {
  type    = number
  default = 1883
}

variable "mqtt_password" {
  type      = string
  default   = ""
  sensitive = true
}

variable "mqtt_client_id" {
  type    = string
  default = "ruview-k3s"
}

variable "mqtt_prefix" {
  type    = string
  default = "ruview"
}

variable "http_service_type" {
  type    = string
  default = "NodePort"
}

variable "http_port" {
  type    = number
  default = 3000
}

variable "http_node_port" {
  type    = number
  default = 31800
}

variable "udp_service_type" {
  type    = string
  default = "NodePort"
}

variable "udp_port" {
  type    = number
  default = 5005
}

variable "udp_node_port" {
  type    = number
  default = 31805
}

variable "resources" {
  type    = map(any)
  default = {}
}

variable "helm_timeout_seconds" {
  type    = number
  default = 900
}
