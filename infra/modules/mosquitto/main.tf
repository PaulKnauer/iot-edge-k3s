terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

resource "helm_release" "mosquitto" {
  name             = "mosquitto"
  namespace        = var.namespace
  create_namespace = true

  chart = "${path.module}/charts/mosquitto"

  values = [
    yamlencode({
      service = {
        type     = var.service_type
        nodePort = var.node_port
        port     = 1883
      }
      auth = {
        allowAnonymous = var.mqtt_allow_anonymous
        username       = var.mqtt_username
        password       = var.mqtt_password
      }
    })
  ]
}
