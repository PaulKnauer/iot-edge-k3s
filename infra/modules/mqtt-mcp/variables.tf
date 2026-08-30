variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "mqtt-mcp"
}

variable "image_repository" {
  type    = string
  default = "192.168.2.201:32000/mqtt-mcp-server"
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
  default = 31882
}

variable "helm_timeout_seconds" {
  type    = number
  default = 300
}

variable "log_level" {
  type    = string
  default = "INFO"
}

variable "broker_url" {
  type    = string
  default = "mqtt://mosquitto.mqtt.svc.cluster.local:1883"
}

variable "broker_username" {
  type    = string
  default = ""
}

variable "broker_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "topic_prefix" {
  type    = string
  default = "clocks/commands"
}

variable "auth_mode" {
  type    = string
  default = "none"

  validation {
    condition     = contains(["none", "static"], var.auth_mode)
    error_message = "auth_mode must be none or static."
  }
}

variable "auth_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "auth_credentials" {
  type      = string
  sensitive = true
  default   = ""
}

variable "rest_base_url" {
  type    = string
  default = "http://clock-server-clock-server.clock.svc.cluster.local:8080"
}

variable "rest_auth_token" {
  type      = string
  sensitive = true
  default   = ""
}

variable "rest_forward_proto_https" {
  type    = bool
  default = true
}

variable "rest_timeout_seconds" {
  type    = string
  default = "5.0"
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
