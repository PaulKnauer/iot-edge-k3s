include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../cert-manager", "../clock-server", "../nodered", "../registry"]
}

terraform {
  source = "../../../modules/ingress"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  node_ip = "192.168.2.201"
  domain  = "home.lab"

  https_node_port = 30443
  http_node_port  = 30080
}
