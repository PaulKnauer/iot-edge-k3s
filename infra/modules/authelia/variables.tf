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

  validation {
    condition     = length(trimspace(var.jwt_secret)) >= 32
    error_message = "jwt_secret must be set to a random string of at least 32 characters."
  }
}

variable "session_secret" {
  type      = string
  sensitive = true

  validation {
    condition     = length(trimspace(var.session_secret)) >= 32
    error_message = "session_secret must be set to a random string of at least 32 characters."
  }
}

variable "storage_encryption_key" {
  type      = string
  sensitive = true

  validation {
    condition     = length(trimspace(var.storage_encryption_key)) >= 32
    error_message = "storage_encryption_key must be set to a random string of at least 32 characters."
  }
}

variable "admin_password_hash" {
  description = "Argon2id password hash for the admin user. Generate with: docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'yourpassword'"
  type        = string
  sensitive   = true

  validation {
    condition     = can(regex("^\\$argon2(id|i|d)\\$", var.admin_password_hash))
    error_message = "admin_password_hash must be an Argon2 password hash generated outside Terraform."
  }
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
