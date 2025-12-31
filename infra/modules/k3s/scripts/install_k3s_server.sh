#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-}"
SERVER0_HOST="${2:-}"

if [[ -z "${INSTALL_K3S_VERSION:-}" ]]; then
  echo "INSTALL_K3S_VERSION not set" >&2
  exit 1
fi
if [[ -z "${K3S_TOKEN:-}" ]]; then
  echo "K3S_TOKEN not set" >&2
  exit 1
fi
if [[ -z "${CLUSTER_ENDPOINT:-}" ]]; then
  echo "CLUSTER_ENDPOINT not set" >&2
  exit 1
fi

DISABLE_TRAEFIK="${DISABLE_TRAEFIK:-true}"

# Idempotency: if k3s already installed/running, exit
if systemctl is-active --quiet k3s; then
  echo "k3s already active on this node. Skipping."
  exit 0
fi

echo "Ensuring swap is off..."
sudo swapoff -a || true
sudo sed -i.bak '/ swap / s/^/#/' /etc/fstab || true

# Traefik disable flag
DISABLES=""
if [[ "${DISABLE_TRAEFIK}" == "true" ]]; then
  DISABLES="--disable traefik"
fi

COMMON_FLAGS="--write-kubeconfig-mode 644 --tls-san ${CLUSTER_ENDPOINT} ${DISABLES}"

if [[ "${MODE}" == "init" ]]; then
  echo "Installing k3s server (cluster-init)..."
  curl -sfL https://get.k3s.io | sudo -E sh -s - server --cluster-init ${COMMON_FLAGS}
elif [[ "${MODE}" == "join" ]]; then
  if [[ -z "${SERVER0_HOST}" ]]; then
    echo "SERVER0_HOST required for join" >&2
    exit 1
  fi
  echo "Installing k3s server (join)..."
  curl -sfL https://get.k3s.io | sudo -E sh -s - server --server "https://${SERVER0_HOST}:6443" ${COMMON_FLAGS}
else
  echo "Usage: install_k3s_server.sh {init|join} [server0_host]" >&2
  exit 1
fi

echo "Waiting for k3s server to become active..."
sudo systemctl enable --now k3s
sudo systemctl is-active --quiet k3s
echo "k3s server installed."
