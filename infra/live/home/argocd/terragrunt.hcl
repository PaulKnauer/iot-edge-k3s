include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"

  mock_outputs = {
    kubeconfig_path = "${get_repo_root()}/infra/.kube/home-k3s.yaml"
  }
}

terraform {
  source = "../../../modules/argocd"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path
}
