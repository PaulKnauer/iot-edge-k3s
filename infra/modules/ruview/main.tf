terraform {
  required_version = ">= 1.5.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.12.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.24.0"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = var.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = var.kubeconfig_path
}

resource "kubernetes_secret_v1" "registry_pull_secret" {
  count = (
    var.image_pull_secret_name != "" &&
    var.registry_server != "" &&
    var.registry_username != "" &&
    var.registry_password != ""
  ) ? 1 : 0

  metadata {
    name      = var.image_pull_secret_name
    namespace = var.namespace
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_server) = {
          username = var.registry_username
          password = var.registry_password
          email    = var.registry_email
          auth     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "kubernetes_secret_v1" "mqtt_password" {
  count = var.mqtt_password != "" ? 1 : 0

  metadata {
    name      = "ruview-mqtt-password"
    namespace = var.namespace
  }

  data = {
    MQTT_PASSWORD = var.mqtt_password
  }

  type = "Opaque"
}

resource "kubernetes_namespace_v1" "ruview" {
  metadata {
    name = var.namespace
  }

  lifecycle {
    ignore_changes = [metadata[0].annotations, metadata[0].labels]
  }
}

resource "helm_release" "ruview" {
  name      = "ruview"
  namespace = var.namespace

  chart = "${path.module}/charts/ruview"

  values = [
    yamlencode({
      image = {
        repository          = var.image_repository
        tag                 = var.image_tag
        pullPolicy          = var.image_pull_policy
        imagePullSecretName = var.image_pull_secret_name
      }
      sensing = {
        source                = var.csi_source
        allowUnauthenticated  = var.allow_unauthenticated
        allowedHosts          = var.allowed_hosts
      }
      mqtt = {
        enabled    = var.mqtt_enabled
        host       = var.mqtt_host
        port       = var.mqtt_port
        secretName = var.mqtt_password != "" ? "ruview-mqtt-password" : ""
        clientId   = var.mqtt_client_id
        prefix     = var.mqtt_prefix
      }
      service = {
        http = {
          type     = var.http_service_type
          port     = var.http_port
          nodePort = var.http_node_port
        }
        udp = {
          type     = var.udp_service_type
          port     = var.udp_port
          nodePort = var.udp_node_port
        }
      }
      resources = var.resources
    })
  ]

  timeout          = var.helm_timeout_seconds
  cleanup_on_fail  = true

  depends_on = [
    kubernetes_namespace_v1.ruview,
    kubernetes_secret_v1.registry_pull_secret,
    kubernetes_secret_v1.mqtt_password,
  ]
}
