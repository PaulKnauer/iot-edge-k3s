include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

dependencies {
  paths = ["../registry", "../clock-server", "../mosquitto"]
}

terraform {
  source = "../../../modules/mqtt-mcp"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  node_port = 31882

  # Raspberry Pi pulls can take longer than Helm's default 5m timeout.
  helm_timeout_seconds = 900

  image_repository  = "192.168.2.201:32000/mqtt-mcp-server"
  image_tag         = get_env("MQTT_MCP_IMAGE_TAG", "latest")
  image_pull_policy = "Always"

  image_pull_secret_name   = get_env("REGISTRY_PULL_SECRET_NAME", "")
  create_image_pull_secret = get_env("MQTT_MCP_CREATE_IMAGE_PULL_SECRET", "false") == "true"
  registry_server          = "192.168.2.201:32000"
  registry_username        = get_env("REGISTRY_USERNAME", "")
  registry_password        = get_env("REGISTRY_PASSWORD", "")

  broker_url      = get_env("MQTT_MCP_BROKER_URL", "mqtt://mosquitto.mqtt.svc.cluster.local:1883")
  broker_username = get_env("MQTT_MCP_BROKER_USERNAME", "")
  broker_password = get_env("MQTT_MCP_BROKER_PASSWORD", "")
  topic_prefix    = get_env("MQTT_MCP_TOPIC_PREFIX", "clocks/commands")

  auth_mode        = get_env("MQTT_MCP_AUTH_MODE", "none")
  auth_token       = get_env("MQTT_MCP_AUTH_TOKEN", "")
  auth_credentials = get_env("MQTT_MCP_AUTH_CREDENTIALS", "")

  log_level                = get_env("MQTT_MCP_LOG_LEVEL", "INFO")
  rest_base_url            = get_env("MQTT_MCP_REST_BASE_URL", "http://clock-server-clock-server.clock.svc.cluster.local:8080")
  rest_auth_token          = get_env("MQTT_MCP_REST_AUTH_TOKEN", "")
  rest_forward_proto_https = get_env("MQTT_MCP_REST_FORWARD_PROTO_HTTPS", "true") == "true"
  rest_timeout_seconds     = get_env("MQTT_MCP_REST_TIMEOUT_SECONDS", "5.0")
}
