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

locals {
  auth_secret_data = merge(
    var.api_auth_credentials != "" ? { API_AUTH_CREDENTIALS = var.api_auth_credentials } : {},
    var.api_auth_token != "" ? { API_AUTH_TOKEN = var.api_auth_token } : {}
  )
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

resource "kubernetes_secret_v1" "clock_server_auth" {
  count = length(local.auth_secret_data) > 0 ? 1 : 0

  metadata {
    name      = var.auth_secret_name
    namespace = var.namespace
  }

  data = local.auth_secret_data
  type = "Opaque"
}

resource "helm_release" "clock_server" {
  name             = "clock-server"
  namespace        = var.namespace
  create_namespace = true

  chart = "${path.module}/charts/clock-server"

  values = [
    yamlencode({
      image = {
        repository          = var.image_repository
        tag                 = var.image_tag
        pullPolicy          = var.image_pull_policy
        imagePullSecretName = var.image_pull_secret_name
      }
      env = {
        authSecretName = length(local.auth_secret_data) > 0 ? var.auth_secret_name : ""
        extra          = var.extra_env
      }
      service = {
        type     = var.service_type
        port     = var.service_port
        nodePort = var.node_port
      }
      resources = var.resources
    })
  ]

  timeout = var.helm_timeout_seconds

  depends_on = [
    kubernetes_secret_v1.registry_pull_secret,
    kubernetes_secret_v1.clock_server_auth,
  ]
}
