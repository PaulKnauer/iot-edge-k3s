terraform {
  required_version = ">= 1.5.0"
}

locals {
  server0 = var.servers[0].host

  common_env = {
    INSTALL_K3S_VERSION = var.k3s_version
    K3S_TOKEN           = var.k3s_token
    CLUSTER_ENDPOINT    = var.cluster_endpoint
    DISABLE_TRAEFIK     = var.disable_traefik ? "true" : "false"
  }
}

# --- Server #1 (cluster-init) ---
resource "null_resource" "server_init" {
  triggers = {
    host         = local.server0
    k3s_version  = var.k3s_version
    endpoint     = var.cluster_endpoint
    disable_trfk = var.disable_traefik ? "1" : "0"
    # Don't include token in triggers
    script_hash = filesha256("${path.module}/scripts/install_k3s_server.sh")
  }

  connection {
    type        = "ssh"
    host        = local.server0
    user        = var.ssh_user
    port        = var.ssh_port
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /opt/iac",
      "echo 'Bootstrap server init: ${local.server0}'",
    ]
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_k3s_server.sh"
    destination = "/tmp/install_k3s_server.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_k3s_server.sh",
      "sudo -E INSTALL_K3S_VERSION='${var.k3s_version}' K3S_TOKEN='${var.k3s_token}' CLUSTER_ENDPOINT='${var.cluster_endpoint}' DISABLE_TRAEFIK='${local.common_env.DISABLE_TRAEFIK}' /tmp/install_k3s_server.sh init",
    ]
  }
}

# --- Server #2..N join ---
resource "null_resource" "servers_join" {
  for_each = {
    for s in slice(var.servers, 1, length(var.servers)) : s.name => s
  }

  triggers = {
    host         = each.value.host
    k3s_version  = var.k3s_version
    endpoint     = var.cluster_endpoint
    disable_trfk = var.disable_traefik ? "1" : "0"
    script_hash  = filesha256("${path.module}/scripts/install_k3s_server.sh")
  }

  depends_on = [null_resource.server_init]

  connection {
    type        = "ssh"
    host        = each.value.host
    user        = var.ssh_user
    port        = var.ssh_port
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_k3s_server.sh"
    destination = "/tmp/install_k3s_server.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_k3s_server.sh",
      "sudo -E INSTALL_K3S_VERSION='${var.k3s_version}' K3S_TOKEN='${var.k3s_token}' CLUSTER_ENDPOINT='${var.cluster_endpoint}' DISABLE_TRAEFIK='${local.common_env.DISABLE_TRAEFIK}' /tmp/install_k3s_server.sh join '${local.server0}'",
    ]
  }
}

# --- Agents join ---
resource "null_resource" "agents_join" {
  for_each = {
    for a in var.agents : a.name => a
  }

  triggers = {
    host        = each.value.host
    k3s_version = var.k3s_version
    server0     = local.server0
    script_hash = filesha256("${path.module}/scripts/install_k3s_agent.sh")
  }

  depends_on = [null_resource.server_init]

  connection {
    type        = "ssh"
    host        = each.value.host
    user        = var.ssh_user
    port        = var.ssh_port
    private_key = file(var.ssh_private_key_path)
  }

  provisioner "file" {
    source      = "${path.module}/scripts/install_k3s_agent.sh"
    destination = "/tmp/install_k3s_agent.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_k3s_agent.sh",
      "sudo -E INSTALL_K3S_VERSION='${var.k3s_version}' K3S_TOKEN='${var.k3s_token}' /tmp/install_k3s_agent.sh '${local.server0}'",
    ]
  }
}

# --- Fetch kubeconfig to your laptop and rewrite endpoint ---
resource "null_resource" "fetch_kubeconfig" {
  triggers = {
    server0          = local.server0
    cluster_endpoint = var.cluster_endpoint
    kubeconfig_path  = var.kubeconfig_path
  }

  depends_on = [null_resource.server_init]

  provisioner "local-exec" {
    command     = <<EOT
set -euo pipefail
mkdir -p "$(dirname "${var.kubeconfig_path}")"
scp -o StrictHostKeyChecking=accept-new -i "${var.ssh_private_key_path}" -P ${var.ssh_port} ${var.ssh_user}@${local.server0}:/etc/rancher/k3s/k3s.yaml "${var.kubeconfig_path}.tmp"
# Rewrite server endpoint
sed "s#https://127.0.0.1:6443#https://${var.cluster_endpoint}:6443#g" "${var.kubeconfig_path}.tmp" > "${var.kubeconfig_path}"
rm -f "${var.kubeconfig_path}.tmp"
echo "Wrote kubeconfig to ${var.kubeconfig_path}"
EOT
    interpreter = ["/bin/bash", "-lc"]
  }
}
