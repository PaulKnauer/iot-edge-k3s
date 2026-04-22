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

variable "authelia_subdomain" {
  type    = string
  default = "authelia"
}

variable "default_redirection_url" {
  type    = string
  default = ""
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

variable "helm_timeout_seconds" {
  type    = number
  default = 600
}

variable "oidc_enabled" {
  type    = bool
  default = false
}

variable "oidc_hmac_secret" {
  type      = string
  sensitive = true
  default   = ""

  validation {
    condition     = !var.oidc_enabled || length(trimspace(var.oidc_hmac_secret)) >= 32
    error_message = "oidc_hmac_secret must be set to a random string of at least 32 characters when OIDC is enabled."
  }
}

variable "oidc_jwks_private_key" {
  type      = string
  sensitive = true
  default   = ""

  validation {
    condition     = !var.oidc_enabled || can(regex("-----BEGIN (RSA )?PRIVATE KEY-----", var.oidc_jwks_private_key))
    error_message = "oidc_jwks_private_key must be a PEM private key when OIDC is enabled."
  }
}

variable "oidc_client_id" {
  type    = string
  default = "test-client"
}

variable "oidc_client_name" {
  type    = string
  default = "Test Client"
}

variable "oidc_client_secret_hash" {
  type      = string
  sensitive = true
  default   = ""

  validation {
    condition     = !var.oidc_enabled || can(regex("^\\$[^$[:space:]]+\\$", var.oidc_client_secret_hash))
    error_message = "oidc_client_secret_hash must be a supported Authelia client secret value when OIDC is enabled."
  }
}

variable "oidc_client_grant_types" {
  type    = list(string)
  default = ["client_credentials"]
}

variable "oidc_client_scopes" {
  type    = list(string)
  default = ["profile"]
}

variable "oidc_client_authorization_policy" {
  type    = string
  default = "one_factor"
}
