include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../cert-manager", "../clock-server", "../nodered", "../registry", "../authelia", "../sonos-mcp"]
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

  https_node_port = 30443
  http_node_port  = 30080
}
