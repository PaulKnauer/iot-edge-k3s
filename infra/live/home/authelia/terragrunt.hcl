include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

locals {
  domain          = "home.lab"
  https_node_port = 30443
}

terraform {
  source = "../../../modules/authelia"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  node_port = 31917
  domain    = local.domain

  default_redirection_url = "https://clock.${local.domain}:${local.https_node_port}"

  storage_class = "longhorn"
  storage_size  = "1Gi"

  # Secrets — set via environment variables before applying:
  #   export TF_VAR_authelia_jwt_secret="<random-32+-char-string>"
  #   export TF_VAR_authelia_session_secret="<random-32+-char-string>"
  #   export TF_VAR_authelia_storage_key="<random-32+-char-string>"
  #   export TF_VAR_authelia_admin_hash="$(docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'yourpassword' | grep 'Digest:' | awk '{print $2}')"
  #   export TF_VAR_authelia_oidc_hmac_secret="$(openssl rand -base64 48)"
  #   export TF_VAR_authelia_oidc_jwks_private_key="$(openssl genrsa 4096)"
  #   export TF_VAR_authelia_oidc_client_secret_hash="<Authelia-supported hashed client secret>"
  jwt_secret             = get_env("TF_VAR_authelia_jwt_secret", "")
  session_secret         = get_env("TF_VAR_authelia_session_secret", "")
  storage_encryption_key = get_env("TF_VAR_authelia_storage_key", "")
  admin_password_hash    = get_env("TF_VAR_authelia_admin_hash", "")

  oidc_enabled            = true
  oidc_hmac_secret        = get_env("TF_VAR_authelia_oidc_hmac_secret", "")
  oidc_jwks_private_key   = get_env("TF_VAR_authelia_oidc_jwks_private_key", "")
  oidc_client_id          = "test-client"
  oidc_client_name        = "Test Client"
  oidc_client_secret_hash = get_env("TF_VAR_authelia_oidc_client_secret_hash", "")
  oidc_client_grant_types = ["client_credentials"]
  oidc_client_scopes      = ["profile"]
}
