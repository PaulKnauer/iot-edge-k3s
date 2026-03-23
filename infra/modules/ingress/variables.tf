variable "kubeconfig_path" {
  type = string
}

variable "ingress_namespace" {
  type    = string
  default = "ingress-nginx"
}

variable "node_ip" {
  type    = string
  default = "192.168.2.201"
}

variable "domain" {
  type    = string
  default = "home.lab"
}

variable "http_node_port" {
  type    = number
  default = 30080
}

variable "https_node_port" {
  type    = number
  default = 30443
}

variable "chart_version" {
  type    = string
  default = "4.12.1"
}

variable "helm_timeout_seconds" {
  type    = number
  default = 300
}

variable "clock_server_namespace" {
  type    = string
  default = "clock"
}

variable "clock_server_service" {
  type    = string
  default = "clock-server-clock-server"
}

variable "clock_server_port" {
  type    = number
  default = 8080
}

variable "nodered_namespace" {
  type    = string
  default = "nodered"
}

variable "nodered_service" {
  type    = string
  default = "nodered-nodered"
}

variable "nodered_port" {
  type    = number
  default = 1880
}

variable "registry_namespace" {
  type    = string
  default = "registry"
}

variable "registry_service" {
  type    = string
  default = "registry-docker-registry"
}

variable "registry_port" {
  type    = number
  default = 5000
}

variable "authelia_namespace" {
  type    = string
  default = "authelia"
}

variable "authelia_service" {
  type    = string
  default = "authelia"
}
