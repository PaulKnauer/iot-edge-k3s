#!/usr/bin/env bash
set -euo pipefail

SERVICE_NAME="${1:-}"
SOURCE_FILE="${2:-/tmp/registries.yaml}"
TARGET_FILE="/etc/rancher/k3s/registries.yaml"

if [[ -z "${SERVICE_NAME}" ]]; then
  echo "Usage: configure_registries.sh <k3s|k3s-agent> [source_file]" >&2
  exit 1
fi

restart_if_running() {
  if systemctl list-unit-files | grep -q "^${SERVICE_NAME}\\.service"; then
    if systemctl is-active --quiet "${SERVICE_NAME}"; then
      echo "Restarting ${SERVICE_NAME} to apply registry changes..."
      sudo systemctl restart "${SERVICE_NAME}"
    else
      echo "${SERVICE_NAME} service is installed but not active. No restart needed."
    fi
  else
    echo "${SERVICE_NAME} service not installed yet. Config will be used on install."
  fi
}

# Empty config means "no custom registries". Remove existing file if present.
if [[ ! -s "${SOURCE_FILE}" ]]; then
  if [[ -f "${TARGET_FILE}" ]]; then
    echo "Removing existing ${TARGET_FILE} (no registries config provided)."
    sudo rm -f "${TARGET_FILE}"
    restart_if_running
  else
    echo "No registries config provided and no existing ${TARGET_FILE}. Nothing to do."
  fi
  exit 0
fi

new_hash="$(sha256sum "${SOURCE_FILE}" | awk '{print $1}')"
old_hash=""
if [[ -f "${TARGET_FILE}" ]]; then
  old_hash="$(sha256sum "${TARGET_FILE}" | awk '{print $1}')"
fi

if [[ "${new_hash}" == "${old_hash}" ]]; then
  echo "Registry config unchanged at ${TARGET_FILE}. Nothing to do."
  exit 0
fi

echo "Updating ${TARGET_FILE}."
sudo install -D -m 0644 "${SOURCE_FILE}" "${TARGET_FILE}"
restart_if_running
