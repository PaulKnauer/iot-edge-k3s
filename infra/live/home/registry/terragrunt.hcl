include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../longhorn"]
}

terraform {
  source = "../../../modules/registry"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  service_type = "NodePort"
  node_port    = 32000

  # Longhorn-backed persistence (data replicated across nodes by Longhorn).
  storage_class = "longhorn"
  storage_size  = "10Gi"
  # Raspberry Pi pulls/volume attach can exceed Helm's default 5m timeout.
  helm_timeout_seconds = 900

  # Optional auth; pass as env var to avoid hardcoding credentials:
  # export TF_VAR_htpasswd="$(htpasswd -nbB registryuser 'strong-password')"
  # This string should be one line: "user:hash"
  htpasswd = get_env("TF_VAR_htpasswd", "")
}
