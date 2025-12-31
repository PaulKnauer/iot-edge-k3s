locals {
  # Where we'll write the kubeconfig on your laptop
  kube_dir        = "${get_repo_root()}/infra/.kube"
  kubeconfig_path = "${local.kube_dir}/home-k3s.yaml"
}

# Keep state local for now (simple homelab).
# Later you can move to an S3/GCS backend.
terraform {
  extra_arguments "common_vars" {
    commands = ["plan", "apply", "destroy"]
  }
}

inputs = {
  kubeconfig_path = local.kubeconfig_path
}
