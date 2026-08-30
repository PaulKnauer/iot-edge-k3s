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

resource "kubernetes_namespace_v1" "mqtt_mcp" {
  metadata {
    name = var.namespace
  }
}

resource "kubernetes_secret_v1" "registry_pull_secret" {
  count = (
    var.create_image_pull_secret &&
    var.image_pull_secret_name != "" &&
    var.registry_server != "" &&
    var.registry_username != "" &&
    var.registry_password != ""
  ) ? 1 : 0

  metadata {
    name      = var.image_pull_secret_name
    namespace = kubernetes_namespace_v1.mqtt_mcp.metadata[0].name
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        (var.registry_server) = {
          username = var.registry_username
          password = var.registry_password
          auth     = base64encode("${var.registry_username}:${var.registry_password}")
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}

resource "helm_release" "mqtt_mcp" {
  name      = "mqtt-mcp"
  namespace = kubernetes_namespace_v1.mqtt_mcp.metadata[0].name

  chart   = "${path.module}/charts/mqtt-mcp"
  timeout = var.helm_timeout_seconds

  values = [
    yamlencode({
      fullnameOverride = "mqtt-mcp"
      image = {
        repository          = var.image_repository
        tag                 = var.image_tag
        pullPolicy          = var.image_pull_policy
        imagePullSecretName = var.image_pull_secret_name
      }
      service = {
        type     = "NodePort"
        port     = 8000
        nodePort = var.node_port
      }
      config = {
        transport             = "http"
        httpHost              = "0.0.0.0"
        httpPort              = "8000"
        logLevel              = var.log_level
        brokerUrl             = var.broker_url
        brokerUsername        = var.broker_username
        topicPrefix           = var.topic_prefix
        authMode              = var.auth_mode
        restBaseUrl           = var.rest_base_url
        restForwardProtoHttps = var.rest_forward_proto_https
        restTimeoutSeconds    = var.rest_timeout_seconds
      }
      secret = {
        brokerPassword  = var.broker_password
        authToken       = var.auth_token
        authCredentials = var.auth_credentials
        restAuthToken   = var.rest_auth_token
      }
    })
  ]

  depends_on = [
    kubernetes_secret_v1.registry_pull_secret,
  ]
}
