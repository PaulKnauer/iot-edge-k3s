variable "servers" {
  type = list(object({
    name = string
    host = string
  }))
}

variable "agents" {
  type = list(object({
    name = string
    host = string
  }))
}

variable "ssh_user" { type = string }
variable "ssh_port" { type = number }
variable "ssh_private_key_path" { type = string }

variable "k3s_version" { type = string }

variable "k3s_token" {
  type      = string
  sensitive = true
}

variable "cluster_endpoint" {
  type = string
}

variable "kubeconfig_path" {
  type = string
}

variable "disable_traefik" {
  type    = bool
  default = true
}
