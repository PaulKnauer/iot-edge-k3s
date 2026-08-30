include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../cert-manager", "../clock-server", "../registry", "../authelia", "../sonos-mcp", "../mqtt-mcp", "../hindsight"]
}

terraform {
  source = "../../../modules/ingress"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  node_ip = "192.168.2.201"
  domain  = "home.lab"

  node_dns_names        = ["rpi4-1.local"]
  sonos_mcp_extra_hosts = ["rpi4-1.local"]
  mqtt_mcp_extra_hosts  = ["rpi4-1.local"]

  https_node_port = 30443
  http_node_port  = 30080

  hindsight_namespace = "hindsight"
  hindsight_web_host  = get_env("HINDSIGHT_WEB_HOST", "hindsight.home.lab")
  hindsight_api_host  = get_env("HINDSIGHT_API_HOST", "hindsight-api.home.lab")
}
