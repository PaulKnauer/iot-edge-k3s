include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../registry", "../mosquitto"]
}

terraform {
  source = "../../../modules/ruview"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  namespace              = "ruview"
  image_repository       = "192.168.2.201:32000/ruview-sensing-server"
  image_tag              = "4bf88e12-mqtt4"
  image_pull_policy      = "Always"
  image_pull_secret_name = get_env("REGISTRY_PULL_SECRET_NAME", "")

  # Pass registry credentials via environment variables.
  # export REGISTRY_USERNAME="registryuser"
  # export REGISTRY_PASSWORD="strong-password"
  registry_server   = "192.168.2.201:32000"
  registry_username = get_env("REGISTRY_USERNAME", "")
  registry_password = get_env("REGISTRY_PASSWORD", "")

  csi_source    = "auto"
  allowed_hosts = "192.168.2.201:31801"

  # LAN homelab — no bearer token; entrypoint security check bypassed explicitly.
  # To enforce auth instead: unset this and set RUVIEW_API_TOKEN env var.
  allow_unauthenticated = "1"

  # MQTT publisher → Mosquitto NodePort (ADR-115 non-fatal plaintext advisory)
  mqtt_enabled  = true
  mqtt_host     = "192.168.2.201"
  mqtt_port     = 31883
  mqtt_password = get_env("MQTT_PASSWORD", "")

  # HTTP UI/API — entrypoint hardcodes --http-port 3000 inside the image
  # UI: http://192.168.2.201:31801/ui/index.html
  http_service_type = "NodePort"
  http_port         = 3000
  http_node_port    = 31801

  # UDP CSI receiver — re-provision ESP32s to send to 192.168.2.201:31805
  # (replaces the current Mac target once the image is running in k3s)
  udp_service_type = "NodePort"
  udp_port         = 5005
  udp_node_port    = 31805

  # Raspberry Pi image pulls can exceed Helm's default 5m timeout
  helm_timeout_seconds = 900
}
