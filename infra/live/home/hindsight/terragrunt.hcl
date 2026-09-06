include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../ingress"]
}

terraform {
  source = "../../../modules/hindsight"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  namespace            = "hindsight"
  chart_version        = get_env("HINDSIGHT_CHART_VERSION", "0.8.2")
  helm_timeout_seconds = 900

  worker_id = get_env("HINDSIGHT_WORKER_ID", "hindsight-home")

  llm_provider = get_env("HINDSIGHT_LLM_PROVIDER", "deepseek")
  llm_model    = get_env("HINDSIGHT_LLM_MODEL", "deepseek-chat")
  llm_base_url = get_env("HINDSIGHT_LLM_BASE_URL", "https://api.deepseek.com/v1")
  llm_api_key  = get_env("HINDSIGHT_LLM_API_KEY", "")

  tenant_api_key           = get_env("HINDSIGHT_API_TENANT_API_KEY", "")
  control_plane_access_key = get_env("HINDSIGHT_CP_ACCESS_KEY", "")
  mcp_auth_token           = get_env("HINDSIGHT_API_MCP_AUTH_TOKEN", "")

  storage_class = "longhorn"
  storage_size  = get_env("HINDSIGHT_STORAGE_SIZE", "8Gi")

  postgresql_username = get_env("HINDSIGHT_POSTGRESQL_USERNAME", "hindsight")
  postgresql_password = get_env("HINDSIGHT_POSTGRESQL_PASSWORD", "hindsight")
  postgresql_database = get_env("HINDSIGHT_POSTGRESQL_DATABASE", "hindsight")

  nodeport_enabled        = true
  api_node_port           = 31888
  control_plane_node_port = 31889

  ingress_enabled    = true
  ingress_class_name = "nginx"
  web_host           = get_env("HINDSIGHT_WEB_HOST", "hindsight.k3s.home.arpa")
  api_host           = get_env("HINDSIGHT_API_HOST", "hindsight-api.k3s.home.arpa")

  ingress_proxy_body_size            = get_env("HINDSIGHT_INGRESS_PROXY_BODY_SIZE", "100m")
  ingress_proxy_read_timeout_seconds = tonumber(get_env("HINDSIGHT_INGRESS_PROXY_READ_TIMEOUT_SECONDS", "600"))
  ingress_proxy_send_timeout_seconds = tonumber(get_env("HINDSIGHT_INGRESS_PROXY_SEND_TIMEOUT_SECONDS", "600"))
}
