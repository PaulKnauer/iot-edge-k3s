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

  # Raspberry Pi pulls can take longer than Helm's default 5m timeout.
  helm_timeout_seconds = 900

  # Image built and pushed to local registry
  image_repository  = "192.168.2.201:32000/soniq-mcp"
  image_tag         = "v0.6.0"
  image_pull_policy = "Always"

  # Registry auth
  image_pull_secret_name   = get_env("REGISTRY_PULL_SECRET_NAME", "regcred")
  create_image_pull_secret = get_env("SONIQ_MCP_CREATE_IMAGE_PULL_SECRET", "false") == "true"
  registry_server          = "192.168.2.201:32000"
  registry_username        = get_env("REGISTRY_USERNAME", "")
  registry_password        = get_env("REGISTRY_PASSWORD", "")

  # Optional: set a default Sonos room (set via env to avoid hardcoding)
  default_room = get_env("SONIQ_MCP_DEFAULT_ROOM", get_env("SONOS_MCP_DEFAULT_ROOM", ""))

  # Optional tuning
  max_volume_pct = "80"
  tools_disabled = ""
  log_level      = "INFO"

  # Optional HTTP auth (v0.6.0). Keep secrets in env vars.
  auth_mode         = get_env("SONIQ_MCP_AUTH_MODE", "")
  auth_token        = get_env("SONIQ_MCP_AUTH_TOKEN", "")
  oidc_issuer       = get_env("SONIQ_MCP_OIDC_ISSUER", "")
  oidc_audience     = get_env("SONIQ_MCP_OIDC_AUDIENCE", "")
  oidc_jwks_uri     = get_env("SONIQ_MCP_OIDC_JWKS_URI", "")
  oidc_resource_url = get_env("SONIQ_MCP_OIDC_RESOURCE_URL", "")

  # Optional OIDC private CA support. Create the ConfigMap outside this module
  # before enabling the mount.
  ca_bundle_enabled         = get_env("SONIQ_MCP_OIDC_CA_BUNDLE_ENABLED", "false") == "true"
  ca_bundle_config_map_name = get_env("SONIQ_MCP_OIDC_CA_BUNDLE_CONFIG_MAP", "")
  ca_bundle_config_map_key  = get_env("SONIQ_MCP_OIDC_CA_BUNDLE_CONFIG_MAP_KEY", "ca.crt")
  ca_bundle_mount_path      = get_env("SONIQ_MCP_OIDC_CA_BUNDLE", "/etc/soniq/ca.crt")
}
