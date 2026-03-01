include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../registry"]
}

terraform {
  source = "../../../modules/clock-server"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  namespace              = "clock"
  image_repository       = "192.168.2.201:32000/clock-server"
  image_tag              = "0.0.1"
  image_pull_policy      = "Always"
  image_pull_secret_name = get_env("REGISTRY_PULL_SECRET_NAME", "")

  # Pass registry credentials via environment variables.
  # export REGISTRY_USERNAME="registryuser"
  # export REGISTRY_PASSWORD="strong-password"
  registry_server   = "192.168.2.201:32000"
  registry_username = get_env("REGISTRY_USERNAME", "")
  registry_password = get_env("REGISTRY_PASSWORD", "")

  # Clock-server requires one of these:
  # export CLOCK_SERVER_API_AUTH_CREDENTIALS="user:password"
  # or
  # export CLOCK_SERVER_API_AUTH_TOKEN="some-token"
  auth_secret_name     = "clock-server-auth"
  api_auth_credentials = get_env("CLOCK_SERVER_API_AUTH_CREDENTIALS", "")
  api_auth_token       = get_env("CLOCK_SERVER_API_AUTH_TOKEN", "")
  extra_env = merge(
    {
      TRUST_PROXY_TLS     = "true"
      MQTT_BROKER_URL     = "mqtt://192.168.2.201:31883"
      ALLOW_INSECURE_MQTT = "true"
      ENABLED_SENDERS     = "mqtt"
    },
    {}
  )

  service_type = "NodePort"
  service_port = 8080
  node_port    = 31881

  # Raspberry Pi pulls can take longer than Helm's default 5m timeout.
  helm_timeout_seconds = 900
}
