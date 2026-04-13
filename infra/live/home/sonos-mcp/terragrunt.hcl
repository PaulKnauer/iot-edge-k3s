include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

terraform {
  source = "../../../modules/sonos-mcp"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  # NodePort for local client access
  node_port = 31800

  # Image built and pushed to local registry
  image_repository  = "192.168.2.201:32000/soniq-mcp"
  image_tag         = "v0.5.0"
  image_pull_policy = "Always"

  # Registry auth
  image_pull_secret_name = get_env("REGISTRY_PULL_SECRET_NAME", "regcred")
  registry_server        = "192.168.2.201:32000"
  registry_username      = get_env("REGISTRY_USERNAME", "")
  registry_password      = get_env("REGISTRY_PASSWORD", "")

  # Optional: set a default Sonos room (set via env to avoid hardcoding)
  default_room = get_env("SONOS_MCP_DEFAULT_ROOM", "")

  # Optional tuning
  max_volume_pct = "80"
  tools_disabled = ""
  log_level      = "INFO"
}
