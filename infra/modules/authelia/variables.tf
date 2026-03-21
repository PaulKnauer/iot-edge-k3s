variable "kubeconfig_path" {
  type = string
}

variable "namespace" {
  type    = string
  default = "authelia"
}

variable "domain" {
  type    = string
  default = "home.lab"
}

variable "node_port" {
  type    = number
  default = 31917
}

variable "jwt_secret" {
  type      = string
  sensitive = true
}

variable "session_secret" {
  type      = string
  sensitive = true
}

variable "storage_encryption_key" {
  type      = string
  sensitive = true
}

variable "admin_password_hash" {
  description = "Argon2id password hash for the admin user. Generate with: docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'yourpassword'"
  type        = string
  sensitive   = true
}

variable "storage_class" {
  type    = string
  default = "longhorn"
}

variable "storage_size" {
  type    = string
  default = "1Gi"
}

variable "chart_version" {
  type    = string
  default = "0.9.0"
}
