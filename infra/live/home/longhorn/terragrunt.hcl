include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

terraform {
  source = "../../../modules/longhorn"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  # Override as needed.
  # chart_version = "1.6.2"

  # values = {
  #   defaultSettings = {
  #     defaultReplicaCount = 2
  #   }
  # }
}
