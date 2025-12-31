#!/usr/bin/env bash
set -euo pipefail

SERVER0_HOST="${1:-}"

if [[ -z "${INSTALL_K3S_VERSION:-}" ]]; then
  echo "INSTALL_K3S_VERSION not set" >&2
  exit 1
fi
if [[ -z "${K3S_TOKEN:-}" ]]; then
  echo "K3S_TOKEN not set" >&2
  exit 1
fi
if [[ -z "${SERVER0_HOST}" ]]; then
  echo "SERVER0_HOST required" >&2
  exit 1
fi

# Idempotency
if systemctl is-active --quiet k3s-agent; then
  echo "k3s-agent already active on this node. Skipping."
  exit 0
fi

echo "Ensuring swap is off..."
sudo swapoff -a || true
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab || true

echo "Installing k3s agent..."
curl -sfL https://get.k3s.io | sudo -E sh -s - agent --server "https://${SERVER0_HOST}:6443"

echo "Waiting for k3s-agent to become active..."
sudo systemctl enable --now k3s-agent
sudo systemctl is-active --quiet k3s-agent
echo "k3s agent installed."
