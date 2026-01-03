include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "k3s" {
  config_path = "../k3s"
}

terraform {
  source = "../../../modules/mosquitto"
}

inputs = {
  kubeconfig_path = dependency.k3s.outputs.kubeconfig_path

  # Mosquitto exposure (NodePort by default)
  service_type = "NodePort"
  node_port    = 31883

  # Optional: set these later if you want auth (recommended)
  # mqtt_allow_anonymous = false
  # mqtt_username        = "mqtt"
  # mqtt_password        = var.mqtt_password  (pass via env: TF_VAR_mqtt_password)
}
