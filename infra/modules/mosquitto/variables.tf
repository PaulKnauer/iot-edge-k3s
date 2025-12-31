variable "kubeconfig_path" { type = string }

variable "namespace" {
  type    = string
  default = "mqtt"
}

variable "service_type" {
  type    = string
  default = "NodePort"
}

variable "node_port" {
  type    = number
  default = 31883
}

variable "mqtt_allow_anonymous" {
  type    = bool
  default = true
}

variable "mqtt_username" {
  type    = string
  default = "mqtt"
}

variable "mqtt_password" {
  type      = string
  default   = ""
  sensitive = true
}
