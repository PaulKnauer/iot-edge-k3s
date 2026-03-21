include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

terraform {
  source = "../../../modules/authelia"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  node_port = 31917
  domain    = "home.lab"

  storage_class = "longhorn"
  storage_size  = "1Gi"

  # Secrets — set via environment variables before applying:
  #   export TF_VAR_authelia_jwt_secret="<random-32+-char-string>"
  #   export TF_VAR_authelia_session_secret="<random-32+-char-string>"
  #   export TF_VAR_authelia_storage_key="<random-32+-char-string>"
  #   export TF_VAR_authelia_admin_hash="$(docker run --rm authelia/authelia:latest authelia crypto hash generate argon2 --password 'yourpassword' | grep 'Digest:' | awk '{print $2}')"
  jwt_secret             = get_env("TF_VAR_authelia_jwt_secret", "")
  session_secret         = get_env("TF_VAR_authelia_session_secret", "")
  storage_encryption_key = get_env("TF_VAR_authelia_storage_key", "")
  admin_password_hash    = get_env("TF_VAR_authelia_admin_hash", "")
}
