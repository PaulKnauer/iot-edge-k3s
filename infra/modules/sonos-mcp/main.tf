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

resource "helm_release" "sonos_mcp" {
  name      = "sonos-mcp"
  namespace = kubernetes_namespace_v1.sonos_mcp.metadata[0].name

  chart   = "${path.module}/charts/soniq"
  timeout = 300

  values = [
    yamlencode({
      image = {
        repository = var.image_repository
        tag        = var.image_tag
        pullPolicy = var.image_pull_policy
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
}
