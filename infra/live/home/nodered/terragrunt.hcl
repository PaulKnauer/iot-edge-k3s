include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

terraform {
  source = "../../../modules/nodered"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  # Service exposure (adjust as needed)
  service_type = "NodePort"
  node_port    = 31880

  # Longhorn-backed persistence
  storage_class = "longhorn"
  storage_size  = "2Gi"

  # Node-RED settings (set via env to avoid hardcoding secrets)
  credential_secret = get_env("NODE_RED_CREDENTIAL_SECRET", "")
}
