include "root" {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/k3s"
}

inputs = {
  # SSH
  ssh_user             = "ubuntu"
  ssh_port             = 22
  ssh_private_key_path = "~/.ssh/k3s-edge-iot"

  # k3s pin (adjust if you want)
  k3s_version = "v1.29.9+k3s1"

  # Cluster endpoint to put into kubeconfig + TLS SAN.
  # For maximum reliability, consider using an IP (DHCP reservation) instead of mDNS.
  cluster_endpoint = "rpi4-1.local"

  # IMPORTANT: provide this token via environment variable:
  # export TF_VAR_k3s_token="some-long-random-string"
  # (do NOT commit it)
  # k3s_token comes from var.k3s_token

  # 3 servers (HA control plane)
  servers = [
    { name = "rpi4-1", host = "rpi4-1.local" },
    { name = "rpi4-2", host = "rpi4-2.local" },
    { name = "rpi4-3", host = "rpi4-3.local" },
  ]

  # 1 worker
  agents = [
    { name = "rpi4-4", host = "rpi4-4.local" },
  ]

  # Optional: disable bundled addons you don't need
  disable_traefik = true
}
