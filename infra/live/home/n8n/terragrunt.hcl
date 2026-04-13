include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

terraform {
  source = "../../../modules/n8n"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  # Service exposure
  node_port = 31678

  # Longhorn-backed persistence
  storage_class = "longhorn"
  storage_size  = "2Gi"

  # n8n settings (set via env to avoid hardcoding secrets)
  encryption_key = get_env("N8N_ENCRYPTION_KEY", "")
  webhook_url    = "http://192.168.2.201:31678"
}
