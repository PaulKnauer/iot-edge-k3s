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

resource "kubernetes_namespace_v1" "sonos_mcp" {
  metadata {
    name = var.namespace
  }
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
    namespace = kubernetes_namespace_v1.sonos_mcp.metadata[0].name
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

resource "helm_release" "sonos_mcp" {
  name      = "sonos-mcp"
  namespace = kubernetes_namespace_v1.sonos_mcp.metadata[0].name

  chart   = "${path.module}/charts/soniq"
  timeout = 300

  values = [
    yamlencode({
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
        transport     = "http"
        httpHost      = "0.0.0.0"
        httpPort      = "8000"
        exposure      = "home-network"
        logLevel      = var.log_level
        maxVolumePct  = var.max_volume_pct
        toolsDisabled = var.tools_disabled
        configFile    = ""
      }
      secret = {
        defaultRoom = var.default_room
      }
    })
  ]

  depends_on = [
    kubernetes_secret_v1.registry_pull_secret,
  ]
}
